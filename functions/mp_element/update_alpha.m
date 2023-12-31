function [alpha_res] = update_alpha(alpha, rho, t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, DAMPING)
%N_Rsu_local = number of RSU + 1 to contain Local Cpu
[fun_N_Veh, fun_N_Rsu_local] = size(alpha);
alpha_old = alpha;

%initialization
alpha_one = zeros(fun_N_Veh, fun_N_Rsu_local);
alpha_zero = zeros(fun_N_Veh, fun_N_Rsu_local);

%preventing numerical issues
legit_matrix = (t_comm+t_comp_RSU)<10000;

%To avoid error when RSU's Max_Veh number is bigger than the whole number
%of vehicle
Ma = min(fun_N_Veh, max_Veh);

%alpha(1)
for i=1:fun_N_Veh
    for a=1:fun_N_Rsu_local-1
        if legit_matrix(i,a) == 1
            alpha_one_tmp = Inf;
            for u=1:Ma
                %numerical issue
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

    %local computing mode update
    local_tmp_one = Inf;
    for u=1:fun_N_Veh
        tmp = t_comp_local(i) + sum(rank_msg(u-1, t_comp_local + rho(:,fun_N_Rsu_local), i));
        if local_tmp_one > tmp
            local_tmp_one = tmp;
        end
    end
    alpha_one(i,fun_N_Rsu_local) = local_tmp_one;
end

%alpha(0)
for i=1:fun_N_Veh
    for a=1:fun_N_Rsu_local-1
        if legit_matrix(i,a) == 1
            alpha_zero_tmp = 0;
            for u=1:Ma
                tmp = sum(rank_msg(u, delay_fun(u, RSU_Cpu_num(a), t_comp_RSU(:,a), t_comm(:,a)) + rho(:,a), i));
                if tmp < alpha_zero_tmp
                    alpha_zero_tmp = tmp;
                end
            end
            alpha_zero(i,a) = alpha_zero_tmp;
        end
    end

    %local computing mode update
    local_tmp_zero = 0;
    for u=1:fun_N_Veh
        tmp = sum(rank_msg(u, t_comp_local + rho(:,fun_N_Rsu_local), i));
        if tmp < local_tmp_zero
            local_tmp_zero = tmp;
        end
    end
    alpha_zero(i, fun_N_Rsu_local) = local_tmp_zero;
end
alpha = alpha_one - alpha_zero;
alpha_res = alpha*DAMPING + alpha_old*(1 - DAMPING);
end
