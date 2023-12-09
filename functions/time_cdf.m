function [] = time_cdf(allo, t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num)
%UNTITLED 이 함수의 요약 설명 위치
%   자세한 설명 위치
[N_Veh, N_Rsu] = size(t_comm);
time_list = zeros(1, N_Veh);

num_RSU = [];
for a=1:N_Rsu
    num_RSU = [num_RSU, sum(allo==a)];
end

for i=1:N_Veh
    if allo(i) ~= N_Rsu+1
        time_list(i) = delay_fun(num_RSU(allo(i)), RSU_Cpu_num(allo(i)), t_comp_RSU(i, allo(i)), t_comm(i, allo(i)));
    else
        time_list(i) = t_comp_local(i);
    end
end

sort_list = sort(time_list);

prob = 1:N_Veh;
prob = prob./N_Veh;

prob_front_pad = zeros(1,floor(N_Veh/5));
prob_end_pad = ones(1,floor(N_Veh/5));

list_front_pad = linspace(0, min(sort_list), floor(N_Veh/5));
list_end_pad = linspace(max(sort_list), max(sort_list)*1.5, floor(N_Veh/5));

sort_list = [list_front_pad sort_list list_end_pad];
prob = [prob_front_pad prob prob_end_pad];

plot(sort_list, prob)

end