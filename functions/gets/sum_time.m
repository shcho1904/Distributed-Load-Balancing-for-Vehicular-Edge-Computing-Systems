function [total_time] = sum_time(allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num)
%   Calculating allocated user's time
[N_Veh, N_Rsu] = size(t_comm);
total_time = 0;
%   Get # of Vehicle sticked to each RSU
num_RSU = [];
for a=1:N_Rsu
    num_RSU = [num_RSU, sum(allo==a)];
end
for i=1:N_Veh
    if allo(i) == N_Rsu+1
        total_time = total_time + t_comp_local(i);
    else
        total_time = total_time + delay_fun(num_RSU(allo(i)), RSU_Cpu_num(allo(i)), t_comp_RSU(i,allo(i)), t_comm(i,allo(i)));
    end
end    
end