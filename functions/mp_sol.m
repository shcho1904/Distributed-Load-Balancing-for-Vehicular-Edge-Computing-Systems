function [best_alpha, best_rho, alpha_his, rho_his] = mp_sol(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, Max_Veh, N_ITER, DAMPING)
% INF = 10^6
[N_Veh, N_Rsu] = size(t_comm);
%Rsu + Local cpu
N_Rsu_local = N_Rsu + 1;

alpha = zeros(N_Veh, N_Rsu_local);
rho = zeros(N_Veh, N_Rsu_local);

alpha_his = zeros(N_Veh, N_Rsu_local, N_ITER);
rho_his = zeros(N_Veh, N_Rsu_local, N_ITER);

mp_time_best = inf;
best_alpha = zeros(N_Veh, N_Rsu_local);
best_rho = zeros(N_Veh, N_Rsu_local);

for iter = 1:N_ITER
    alpha = update_alpha(alpha, rho, t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, Max_Veh, DAMPING);
    rho = update_rho(rho, alpha, DAMPING, t_comm, t_comp_RSU);
    alpha_his(:,:,iter) = alpha;
    rho_his(:,:,iter) = rho;
    [trash, mp_tmp_allo] = min((alpha+rho),[],2);
    mp_time = sum_time(mp_tmp_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    
    %mp's solution can oscillate between candidates (usually converge or 2 candidates)
    if mp_time < mp_time_best
        mp_time_best = mp_time;
        cand_alpha = alpha;
        cand_rho = rho;
    end
end

best_alpha = cand_alpha;
best_rho = cand_rho;
end

