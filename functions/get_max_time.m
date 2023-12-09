function [max_time, nR] = get_max_time(allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num)
%get max time according to allo
%   자세한 설명 위치
[N_Veh, N_Rsu] = size(t_comm);
num_RSU = [];
for a=1:N_Rsu
    num_RSU = [num_RSU, sum(allo==a)];
end

nR = num_RSU;
allo_comm = zeros(1, N_Veh);
allo_comp = zeros(1, N_Veh);

tmp_max_time = 0;

for i=1:N_Veh
    if allo(i) ~= N_Rsu+1
        for_tmp_max = delay_fun(num_RSU(allo(i)), RSU_Cpu_num(allo(i)), t_comp_RSU(i, allo(i)), t_comm(i, allo(i)));
    else
        for_tmp_max = t_comp_local(i);
    end
    
    if tmp_max_time < for_tmp_max
        tmp_max_time = for_tmp_max;
    end
end    

max_time = tmp_max_time;

end