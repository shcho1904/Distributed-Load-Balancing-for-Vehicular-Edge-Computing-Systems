function [best_allo, mu] = prim_dual(t_comm, t_comp_local, t_comp_RSU, RSU_Cpu_num, max_Veh, iter_num)
% comparing scheme : primal-dual algorithm
% Because of the difficulty to deal with
% p_a = \floor(n_a/k_a), I assume that p_a is consistent.
% First, find p_a using heuristic algorithm(e.g. greedy), initalizing mu_a
% as -0.25(mu should be negative if not, n_a will be 0, reason will be
% described below.)
% Second, find a* in vehicle section
% Thrid, update n_a using \sum T_{ia}x_{ia} and mu_a
% Finally, update mu, step size is 0.1

% Optimal Setting
% : step size : 0.001, initial mu = -0.2
%------------------


%initalize
[N_Veh, N_Rsu] = size(t_comm);
step_size = 0.0001;
[~, allo] = min([t_comm + t_comp_RSU, t_comp_local], [], 2);
mu = 0.4*ones(1, N_Rsu+1, iter_num+1);
%pd_allo_num = [allo_num(allo, N_Rsu-1), ones(1, N_Rsu-1, iter_num)]; %n_a
pd_allo_num = ones(1,N_Rsu+1, iter_num);
pd_allo_num(:,:,1) = allo_num(allo, N_Rsu);
%rsu_sum = zeros(1,N_Rsu);
best_allo = allo;
p = floor(allo_num(allo, N_Rsu-1)./RSU_Cpu_num);

%initialization
RSU_coef = max(round(sum(t_comp_local)./sum(t_comp_RSU) -1),1).*RSU_Cpu_num;
%dual_ans = [RSU_coef, max(0, N_Veh - sum(RSU_coef))]*(N_Veh >= sum(RSU_Cpu_num)+10) + [RSU_Cpu_num,max(0, N_Veh - sum(RSU_coef))]*(N_Veh < sum(RSU_Cpu_num)+10) ;
dual_ans = [RSU_coef, max(0, N_Veh - sum(RSU_coef))]*(N_Veh >= sum(RSU_Cpu_num)+10);

for iter = 1:iter_num
    %vehicle section
    for veh_index = 1:N_Veh
        [~, allo(veh_index)] = min([((2 - p.*RSU_Cpu_num./(allo_num(allo,N_Rsu-1)+1)).*(1+p)/2.*t_comp_RSU(veh_index,:) ...
            + t_comm(veh_index,:) - mu(:,1:N_Rsu,iter)), t_comp_local(veh_index) - mu(:,N_Rsu+1,iter)]);
    end
    
    %RSU section

    p = floor(allo_num(allo, N_Rsu-1)./RSU_Cpu_num);
    %calculate the difference between real number p and integer(p)
    delta = (pd_allo_num(:,1:N_Rsu,iter)./RSU_Cpu_num) - floor(pd_allo_num(:,1:N_Rsu,iter)./RSU_Cpu_num);
    
    %get 'n' : complementary slackness
    pd_allo_num(:,1:N_Rsu,iter+1) = min(mean((t_comp_RSU+t_comm)./(2*mu(:, 1:N_Rsu, iter) - t_comp_RSU./RSU_Cpu_num) + 0.5*delta.*RSU_Cpu_num.*t_comp_RSU), max_Veh);
    pd_allo_num(:,N_Rsu+1,iter+1) = dual_ans(N_Rsu+1);
    %mu update
    mu(:,:,iter+1) = mu(:,:,iter) + step_size * (pd_allo_num(:,:,iter+1) - allo_num(allo, N_Rsu));

    
    
    if sum_time(allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num) < sum_time(best_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num)
        best_allo = allo;
    end
end


end
