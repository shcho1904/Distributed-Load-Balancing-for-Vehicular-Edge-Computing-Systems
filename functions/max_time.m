

tic
clear
addpath('functions');
N_ITER =  100;
DAMPING = 0.5;

load("data\common\link_data11.mat");
% 1:N_cases
for i = [1]
    %message passing
    [alpha, rho, alpha_his, rho_his] ...
        = mp_sol(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, N_ITER, DAMPING);

    [argvalue, argmin(:,:,i)] = min((alpha+rho)');

    mp_time = sum_time(argmin(:,:,i), t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    mp_allo = argmin(:,:,i);
    [gr_allo, gr_time] = bb(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh);
    [eq_allo, eq_time] = eq_load(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh);
    [km_allo, km_time] = kmeans_load(LOC_Veh_x, LOC_Rsu_x, N_Rsu_down, N_Rsu_up, N_Veh_down, N_Veh_up, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num, 3);
% should make time-sum function

    [mp_max, mp_n] = get_max_time(mp_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    [gr_max, gr_n] = get_max_time(gr_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    [eq_max, eq_n] = get_max_time(eq_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    [km_max, km_n] = get_max_time(km_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);

% ind_max = [squeeze(temp(temp_2)), squeeze(temp_2)];

end

mp_max
gr_max
eq_max
km_max

toc