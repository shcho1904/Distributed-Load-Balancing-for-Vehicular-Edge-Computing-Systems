function [allo, total_time] = BE(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh)
%   Compared Scheme : Greedy
%   First, check the RSU's maximum constraint and current allocation
%   Second, if there the RSU is not available, choose second best RSU or
%   Local CPU, in this algorithm, I'll not consider waiting time
[N_Veh, N_Rsu] = size(t_comm);
allo = zeros(1,N_Veh);

min_time = Inf;

for iter = 1:5
    for flip=0:N_Veh-1
        tmp_allo = (N_Rsu+1)*ones(1,N_Veh);
        for i=circshift(1:N_Veh,flip)
            illegal = zeros(1,N_Rsu+1);
            while 1
                %delay_coefficient = max((allo_num(tmp_allo, N_Rsu)+1)./[RSU_Cpu_num,1] + illegal, 1)/2;
                %delay_coefficient = ones(1,N_Rsu);
                delay_coefficient = max((allo_num(tmp_allo, N_Rsu)+1)./[RSU_Cpu_num,1] + illegal, 1);
                [argvalue, argmin] = min([t_comp_RSU(i,:).*delay_coefficient(1:N_Rsu) + t_comm(i,:) t_comp_local(i)]);
                %[argvalue, argmin] = min([t_comp_RSU(i,:).*delay_coefficient(1:N_Rsu) + t_comm(i,:) t_comp_local(i)] + illegal);

                if (sum(tmp_allo==argmin) >= max_Veh) && (argmin ~= N_Rsu+1)
                    illegal(argmin) = Inf;
                else
                    tmp_allo(i) = argmin;
                    break;
                end
            end
        end

        for veh_index = 1:N_Veh
            RSU_index = tmp_allo(veh_index);
            allocated_RSU_num = allo_num(tmp_allo(veh_index), N_Rsu);

            if RSU_index <= N_Rsu
                if delay_fun(allocated_RSU_num, RSU_Cpu_num(RSU_index), t_comp_RSU(veh_index, RSU_index), t_comm(veh_index, RSU_index)) > t_comp_local(veh_index)
                    tmp_allo(veh_index) = N_Rsu+1;
                end
            end
        end


        tmp_time = sum_time(tmp_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
        if min_time > tmp_time
            min_time = tmp_time;
            allo = tmp_allo;
        end
    end
end
total_time = min_time;
end
