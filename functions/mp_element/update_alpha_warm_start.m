function [alpha_res, alpha_old_one, alpha_old_zero] = update_alpha_warm_start(alpha, rho, initial_alpha_one, initial_alpha_zero, t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, DAMPING)
%N_Rsu_local = number of RSU + 1 to contain Local Cpu
[fun_N_Veh, fun_N_Rsu_local] = size(alpha);
alpha_old = alpha;

%initialization
alpha_one = initial_alpha_one;
alpha_zero = initial_alpha_zero;

legit_matrix = (t_comm+t_comp_RSU)<10000;

%To avoid error when RSU's Max_Veh number is bigger than the whole number
%of vehicle
Ma = min(fun_N_Veh, max_Veh);

for i=1:fun_N_Veh
    for a=1:fun_N_Rsu_local-1
        if legit_matrix(i,a) == 1
            alpha_one_tmp = Inf;
            for u=1:Ma
                illegal_temp = 1 - legit_matrix(:,a);
                illegal_temp(i) = 1;
                illegal_temp = logical(illegal_temp);
                tmp = delay_fun(u, RSU_Cpu_num(a),t_comp_RSU(i,a), t_comm(i,a)) + sum(rank_msg(u-1, delay_fun(u, RSU_Cpu_num(a), t_comp_RSU(:,a), t_comm(:,a)) + rho(:,a), illegal_temp));
                if tmp < alpha_one_tmp
                    alpha_one_tmp = tmp;
                end
            end
            alpha_one(i,a) = alpha_one_tmp;
        end
    end
    %Check whether Local
    %alpha_one_Local_tmp = 0;
    %The reason why l start from 2 : to reduce computation, alpha_one
    %shares the same computation, alpha_one_Local_tmp = pi (below account)
    %for u=2:fun_N_Veh-1
        %tmp = sum(rank_msg(u-1, t_comp_local(i) + rho(:,a), i));
        %if tmp < alpha_one_Local_tmp
            %alpha_one_Local_tmp = tmp;
        %end
    %end
    %alpha_one(i, fun_N_Rsu_local) = min(alpha_one_Local_tmp,0);
    local_tmp_one = Inf;
    for u=1:fun_N_Veh
        tmp = t_comp_local(i) + sum(rank_msg(u-1, t_comp_local + rho(:,fun_N_Rsu_local), i));
        if local_tmp_one > tmp
            local_tmp_one = tmp;
        end
    end
    alpha_one(i,fun_N_Rsu_local) = local_tmp_one;
end

for i=1:fun_N_Veh
    for a=1:fun_N_Rsu_local-1
        if legit_matrix(i,a) == 1
            alpha_zero_tmp = 0;
            for u=1:Ma
                %tmp = delay_fun(u, RSU_Cpu_num(a),t_comp_RSU(i,a), t_comm(i,a)) + sum(rank_msg(u, delay_fun(u, RSU_Cpu_num(a), t_comp_RSU(:,a), t_comm(:,a)) + rho(:,a), i));
                tmp = sum(rank_msg(u, delay_fun(u, RSU_Cpu_num(a), t_comp_RSU(:,a), t_comm(:,a)) + rho(:,a), i));
                if tmp < alpha_zero_tmp
                    alpha_zero_tmp = tmp;
                end
            end
            alpha_zero(i,a) = alpha_zero_tmp;
        end
    end
    %Check whether Local
    %To remove redundancy : min(0,pi) - min(-f_{ia}, pi, \sum rank^l
    %[f+\rho]
    local_tmp_zero = 0;
    for u=1:fun_N_Veh
        %tmp = t_comp_local(i) + sum(rank_msg(u, t_comp_local + rho(:,fun_N_Rsu_local), i));
        tmp = sum(rank_msg(u, t_comp_local + rho(:,fun_N_Rsu_local), i));
        if tmp < local_tmp_zero
            local_tmp_zero = tmp;
        end
    end
    alpha_zero(i, fun_N_Rsu_local) = local_tmp_zero;
    %alpha_zero(i, fun_N_Rsu_local) = min(min(min(alpha_one_Local_tmp), -t_comp_local(i)), sum(rank_msg(Ma, t_comp_local, i)));
end
alpha_old_one = alpha_one;
alpha_old_zero = alpha_zero;
alpha = alpha_one - alpha_zero;
alpha_res = alpha*DAMPING + (1-DAMPING)*alpha_old;
end