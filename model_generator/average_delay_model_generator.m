addpath(genpath('functions'));
addpath(genpath('data'));
addpath(genpath('opt_sol'));
addpath(genpath('compared_algorithms'));
clearvars -except count

max_Veh = 20;

% rng(7);
N_cases = 3;

Bp = 2*10^6; %allocated channel bandwidth to vehicle-i
Noise_delta = 2*10^(-13);
Distance = 1000;
Veh_power = 0.1;
Veh_max_time = 2;

N_Line = 6;
Each_Road_width = 2;
DAMPING = 0.5;
N_Rsu = 7;
LOC_Rsu_x = zeros([N_Rsu, N_cases]);
Max_dist = 300;


RSU_Cpu_num = 3+1*randi(5,1,N_Rsu);
%RSU_Cpu_num = 8*ones(1,N_Rsu);
Rsu_Cpu = (4+4*rand(1,N_Rsu))*10^9;

Road_width = N_Line * Each_Road_width;
Veh_Y_List = linspace(Each_Road_width/2, Road_width - Each_Road_width/2, N_Line);

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

num_per_file = 1000;
for interval = 1:10
    for iter_model = 1+num_per_file*(interval-1):num_per_file*interval
        N_Veh = interval*10;
        t_comm = zeros([N_Veh, N_Rsu, N_cases]);
        t_comp_RSU = zeros([N_Veh, N_Rsu, N_cases]);
        t_comp_local = zeros([N_Veh, N_cases]);
        LOC_Veh_x = zeros([N_Veh, N_cases]);
        Veh_RSU_Dist = zeros([N_Veh, N_Rsu, N_cases]);
        
        alpha_channel = 0.9 + 0.2*rand(1);
        Num_Line_Veh = zeros([1,N_Line]);
        Num_Line_Veh(1) = randi([0, N_Veh]);
        
        %generate each number of vehicle located at each line
        for i=2:N_Line-1
            Num_Line_Veh(i) = randi([0, N_Veh - sum(Num_Line_Veh(1:i-1))]);
        end
        Num_Line_Veh(N_Line) = N_Veh - sum(Num_Line_Veh(1:N_Line-1));
        
        %Vehicle x,y coordinate generation(each direction)
        LOC_Veh_x = [];
        LOC_Veh_y = [];
        for i=1:N_Line
            LOC_Veh_x = [LOC_Veh_x Distance*rand(1,Num_Line_Veh(i))];
            LOC_Veh_y = [LOC_Veh_y repmat(Veh_Y_List(i), 1, Num_Line_Veh(i))];
        end
        
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
        data_comm = (ones(1, N_Veh))*10^6;
        
        %Each Vehicle's Needed computation cycle(computational intensity)
        Veh_CPU_Need_cycle = (1.2*ones(1,N_Veh)).*(0.9+0.2*rand(1,N_Veh)) * 10^9;
        
        %CPU Performance(Cpu clock)
        Veh_Local_Cpu = (2 + 1*rand(1,N_Veh)) * 10^9;
        
        %communication time
        t_comm = zeros([N_Veh, N_Rsu]);
        
        %eliminate vehicle located beyond the covered are
        
        t_comp_local = (Veh_CPU_Need_cycle ./ Veh_Local_Cpu)';
        t_comp_RSU = zeros([N_Veh, N_Rsu]);
        
        for i = 1:N_Veh %vehicle : i, RSU : j
            for j = 1:N_Rsu
                t_comp_RSU(i,j) = Veh_CPU_Need_cycle(i)/Rsu_Cpu(j);
                t_comm(i,j) = data_comm(i)./rate(i,j);
                
                %eliminate vehicle over thread computation time
                if delay_fun(max_Veh, RSU_Cpu_num(j), t_comp_RSU(i,j), t_comm(i,j)) > Veh_max_time && RSU_Veh_dist(i,j) > Max_dist
                    t_comp_RSU(i,j) = Inf;
                end
            end
        end
        
        current = pwd;
        model_save_path = [current '/data/average_delay/model' num2str(iter_model)];
        save(model_save_path);
        %windows path
        %     save_path = 'data\cdf_data\cdf_linking_data';
        %macos path
        %     save_path = 'data/cdf_data/model';
        %     save_path = [save_path num2str(iter)];
        %     save(save_path);
    end
end
