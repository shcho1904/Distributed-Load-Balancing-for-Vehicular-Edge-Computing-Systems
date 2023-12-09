clear
addpath('data_collector');
addpath('model_generator');
addpath('functions');
addpath('data');
addpath('compared_algorithms');
addpath('functions/gets');
addpath('functions/mp_element');
N_ITER = 30;

not_conv = 0;
for iter_one=2001:3000
    tic
    clearvars -except N_ITER DAMPING iter_one not_conv max_Veh
    model_load_path = 'data/fre_change_final_revise/data';
    model_load_path = [model_load_path num2str(iter_one)];
    load(model_load_path);
    % 1:N_cases
    %message passing
%     [alpha, rho, alpha_his, rho_his] ...
%         = mp_sol(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, N_ITER, 1);
%     [~, mp_allo_his] = min(alpha_his+rho_his, [], 2);
%     time_his = zeros(1,N_ITER);
%     for i = 1:N_ITER
%         time_his(i) = sum_time(mp_allo_his(:,:,i), t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
%     end
%     
%     [mp_time, mp_min_index] = min(time_his);
%     mp_allo = mp_allo_his(:,:,mp_min_index);
%     
%     [ro_alpha, ro_rho] = mp_sol_rsu_only(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, N_ITER, 1);
%     [ro_argvalue, ro_mp_allo] = min(ro_alpha + ro_rho, [], 2);
%     ro_mp_time = sum_time(ro_mp_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
%     
%     [eq_allo, eq_time] = eq_load(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh);
%     [gr_allo, gr_time] = bb(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh);
    [km_allo, km_time] = kmeans_load(LOC_Veh_x, LOC_Veh_y, LOC_Rsu_x, LOC_Rsu_y, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num, Rsu_Cpu, Veh_max_time, max_Veh);
%     [pm_allo, mu] = prim_dual(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, 30);
%     pm_time = sum_time(pm_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    % mp_time
    % gr_time
    % eq_time
    % km_time
    
%     mp_max_time = get_max_time(mp_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
%     gr_max_time = get_max_time(gr_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
%     eq_max_time = get_max_time(eq_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
%     km_max_time = get_max_time(km_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
    clear vehicle_data
    
    model_save_path = 'data/fre_change_final_revise/data';
    model_save_path = [model_save_path num2str(iter_one)];
    save(model_save_path)
    toc
end


