function [t_comm, t_comp_local, t_comp_RSU, LOC_Veh_x, LOC_Veh_y, LOC_Rsu_x, LOC_Rsu_y, Veh_RSU_Dist] ...
    = test_random_position(N_Veh, N_Rsu, N_Line, Each_Road_width, Bp, Distance, alpha_channel, Veh_max_time, max_Veh, RSU_Cpu_num, Rsu_Cpu)
%  generate model and simulataneously get communication and computation
%  time

%Road generation
%3GPP TR 37.885
%number of Line = 6
%Line width = 4m
Road_width = N_Line * Each_Road_width;
Veh_Y_List = linspace(Each_Road_width/2, Road_width - Each_Road_width/2, N_Line);
Num_Line_Veh = zeros([1,N_Line]);
Num_Line_Veh(1) = randi([0, N_Veh]);

%generate each number of vehicle located at each line
for i=2:N_Line-1
    Num_Line_Veh(i) = randi([0, N_Veh - sum(Num_Line_Veh(1:i-1))]);
end
Num_Line_Veh(N_Line) = N_Veh - sum(Num_Line_Veh(1:i-1));

%Vehicle x,y coordinate generation(each direction)
temp_LOC_Veh_x = [];
temp_LOC_Veh_y = [];
for i=1:N_Line
    temp_LOC_Veh_x = [temp_LOC_Veh_x Distance*rand(1,Num_Line_Veh(i))];
    temp_LOC_Veh_y = [temp_LOC_Veh_y repmat(Veh_Y_List(i), 1, Num_Line_Veh(i))];
end

LOC_Veh_x = temp_LOC_Veh_x;
LOC_Veh_y = temp_LOC_Veh_y;
%RSU x,y coordinate generation(each direction)

%default : zigzag
%1. RSU : odd number
%*------*------*
%---*-------*---
%2. even number
%*------*------*
%*------*------*
if mod(N_Rsu,2) == 1
    LOC_Rsu_up_x = linspace(0, Distance, floor(N_Rsu/2)+1);
    tmp_Rsu_down_x = linspace(0, Distance, floor(N_Rsu/2)+2);
    LOC_Rsu_down_x = tmp_Rsu_down_x(2:floor(N_Rsu/2)+1);
    LOC_Rsu_up_y = Road_width * ones(1, floor(N_Rsu/2)+1);
    LOC_Rsu_down_y = zeros(1, floor(N_Rsu/2));
else
    LOC_Rsu_up_x = linspace(0, Distance, floor(N_Rsu/2));
    LOC_Rsu_down_x = linspace(0, Distance, floor(N_Rsu/2));
    LOC_Rsu_up_y = Road_width * ones(1, floor(N_Rsu/2));
    LOC_Rsu_down_y = zeros(1, floor(N_Rsu/2));
end
LOC_Rsu_x = [LOC_Rsu_up_x LOC_Rsu_down_x];
LOC_Rsu_y = [LOC_Rsu_up_y LOC_Rsu_down_y];

%Calculate distance between each vehicle and RSU
RSU_Veh_dist_shape = [N_Veh, N_Rsu];
RSU_Veh_dist = zeros([RSU_Veh_dist_shape]);

Veh_power = 0.1;
Noise_delta = 2*10^(-13);

for i = 1:N_Veh %vehicle : i, RSU : j
    for j = 1:N_Rsu
        RSU_Veh_dist(i, j) = sqrt((LOC_Veh_y(i) - LOC_Rsu_y(j))^2 + (LOC_Veh_x(i) - LOC_Rsu_x(j))^2);
    end
end

%calculate SNR
log_channel_gain = log(4.11) + 2.8*(log(3*10^8) - log(4*pi*915*10^6.*RSU_Veh_dist)) + log(Veh_power) - log(Noise_delta);
rate = Bp * log2(1 + alpha_channel * exp(1).^log_channel_gain);

Veh_RSU_Dist = RSU_Veh_dist;
%generate computation model
data_comm = (800+400*rand(1, N_Veh))*1000;

%Each Vehicle's Needed computation cycle(computational intensity)
Veh_CPU_Need_cycle = (1.5 + 0.25*randi([0,2], [1,N_Veh])).*(0.9+0.2*rand(1,N_Veh)) * 10^9;

%CPU Performance(Cpu clock)
Veh_Local_Cpu = (2 + rand(1,N_Veh)) * 10^9;

%communication time
t_comm = zeros([N_Veh, N_Rsu]);

%eliminate vehicle located beyond the covered area

t_comp_local = (Veh_CPU_Need_cycle ./ Veh_Local_Cpu)';
t_comp_RSU = zeros([N_Veh, N_Rsu]);

for i = 1:N_Veh %vehicle : i, RSU : j
    for j = 1:N_Rsu
        t_comp_RSU(i,j) = Veh_CPU_Need_cycle(i)/Rsu_Cpu(j);
        t_comm(i,j) = data_comm(i)./rate(i,j);

        %eliminate vehicle over thread computation time
        if delay_fun(max_Veh, RSU_Cpu_num(j), t_comp_RSU(i,j), t_comm(i,j)) > Veh_max_time
            t_comp_RSU(i,j) = Inf;
        end
    end
end



end