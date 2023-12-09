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
for iter_one=1:10000
    tic
    clearvars -except N_ITER DAMPING iter_one not_conv max_Veh
    model_load_path = 'data/average_delay/data';
    model_load_path = [model_load_path num2str(iter_one)];
    load(model_load_path);

    %message passing
     [alpha, rho, alpha_his, rho_his] ...
         = mp_sol(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, N_ITER, 1);
     [~, mp_allo_his] = min(alpha_his+rho_his, [], 2);
     
     [mp_time, mp_min_index] = min(time_his);
     mp_allo = mp_allo_his(:,:,mp_min_index);
    
 
     [rm_allo, rm_time] = RM(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh);
     [be_allo, be_time] = BE(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh);
     [my_allo, my_time] = MY(LOC_Veh_x, LOC_Veh_y, LOC_Rsu_x, LOC_Rsu_y, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num, Rsu_Cpu, Veh_max_time, max_Veh);
     [pm_allo, mu] = prim_dual(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, 30);
     pm_time = sum_time(pm_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);

    model_save_path = 'data/average_delay/data';
    model_save_path = [model_save_path num2str(iter_one)];
    save(model_save_path)
    toc
end


