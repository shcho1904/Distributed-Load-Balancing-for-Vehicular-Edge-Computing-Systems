function [allo, total_time] = kmeans_load(LOC_Veh_x, LOC_Veh_y, LOC_Rsu_x, LOC_Rsu_y, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num, RSU_Cpu_frequency, time_thres, max_Veh)
%kmeans clustering
%   1. Make N_Rsu cluster
%   2. allocate RSU to closest kmeans center

[N_Veh, N_Rsu] = size(t_comm);

Avg_Rsu_Cpu_num = sum(RSU_Cpu_num)/N_Rsu;
set_size = floor(N_Rsu/3);

LOC_Veh = [LOC_Veh_x', LOC_Veh_y'];
LOC_Rsu = [LOC_Rsu_x' LOC_Rsu_y'];

[idx, C] = kmeans(LOC_Veh, set_size);
%time_list = [t_comm+t_comp_RSU t_comp_local];

min_time = Inf;
eq_veh_num = min(max_Veh, floor(Avg_Rsu_Cpu_num*1.4)+2);
%eq_veh_num = max_Veh;

for flip=0:N_Veh-1
    %center allocation
    tmp_allo = zeros(1,N_Rsu);
    tmp_dist = pdist2(C, LOC_Rsu);
    tmp_veh_allo = zeros(1, N_Veh);
    for i=circshift(1:set_size,flip)
        while 1
            [argvalue, argmin] = min(tmp_dist(i,:));
            if (sum(tmp_allo==argmin) == 1)
                tmp_dist(i,argmin) = Inf;
            else
                tmp_allo(i) = argmin;
                break;
            end
        end
    end
    
    for k=1:N_Veh
        tmp_veh_allo(k) = tmp_allo(idx(k));
        if (t_comm(k, tmp_veh_allo(k)) > time_thres) || (t_comp_RSU(k, tmp_veh_allo(k)) > time_thres)
            tmp_veh_allo(k) = N_Rsu + 1;
        end
    end
    
%     for veh_index = 1:N_Veh
%         RSU_index = tmp_veh_allo(veh_index);
%         allocated_RSU_num = allo_num(tmp_veh_allo(veh_index), N_Rsu);
%         
%         if RSU_index <= N_Rsu
%             if delay_fun(allocated_RSU_num, RSU_Cpu_num(RSU_index), t_comp_RSU(veh_index, RSU_index), t_comm(veh_index, RSU_index)) > t_comp_local(veh_index)
%                 tmp_veh_allo(veh_index) = N_Rsu+1;
%             end
%         end
%     end
    
    %move over-allocated vehicle from RSU to Local Cpu
    tmp_allo_num = allo_num(tmp_veh_allo, N_Rsu);
    if sum(tmp_allo_num > eq_veh_num) ~= 0
        exceed_Rsu = max(0, tmp_allo_num(1:N_Rsu) - eq_veh_num);
        for RSU_list_index = 1:N_Rsu
            if exceed_Rsu(RSU_list_index) ~= 0
                [~,illegal_index] = sort((t_comp_local./(t_comp_RSU(:,RSU_list_index) + t_comm(:,RSU_list_index)))'./(tmp_veh_allo==RSU_list_index));
                minimum_illegal_list = illegal_index(1:exceed_Rsu(RSU_list_index));
                tmp_veh_allo(minimum_illegal_list) = N_Rsu+1;
            end
        end
    end
    
    for i=1:N_Veh
        delay_coefficient = max((allo_num(tmp_veh_allo, N_Rsu)+1)./[RSU_Cpu_num,1], 1);
        if tmp_veh_allo(i) ~= N_Rsu+1 && (sum(RSU_Cpu_frequency,2)/(N_Rsu*10^9) < 3.15)
            if (t_comp_RSU(i,tmp_veh_allo(i)) * delay_coefficient(tmp_veh_allo(i)) + t_comm(i,:) > t_comp_local(i)) 
                tmp_veh_allo(i) = N_Rsu+1;
            end
        end
    end
    
    
    tmp_time = sum_time(tmp_veh_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    
    if min_time > tmp_time
        min_time = tmp_time;
        allo = tmp_veh_allo;
    end
    
    total_time = min_time;
end
end
