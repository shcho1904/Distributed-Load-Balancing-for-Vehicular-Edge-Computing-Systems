function [alpha, rho, alpha_his, rho_his] = mp_sol(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, Max_Veh, N_ITER, DAMPING)
% INF = 10^6
[N_Veh, N_Rsu] = size(t_comm);
%Rsu + Local cpu
N_Rsu_local = N_Rsu + 1;

alpha = zeros(N_Veh, N_Rsu_local);
rho = zeros(N_Veh, N_Rsu_local);

alpha_his = zeros(N_Veh, N_Rsu_local, N_ITER);
rho_his = zeros(N_Veh, N_Rsu_local, N_ITER);

for iter = 1:N_ITER
    alpha = update_alpha(alpha, rho, t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, Max_Veh, DAMPING);
    rho = update_rho(rho, alpha, DAMPING, t_comm, t_comp_RSU);
    alpha_his(:,:,iter) = alpha;
    rho_his(:,:,iter) = rho;
end

end

