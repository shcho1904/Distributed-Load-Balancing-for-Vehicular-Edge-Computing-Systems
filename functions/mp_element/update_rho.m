function rho_res = update_rho(rho, alpha, DAMPING, t_comm, t_comp_RSU)
[fun_N_Veh, fun_N_Rsu] = size(rho);
rho_old = rho;
legit_matrix = (t_comm+t_comp_RSU)<10000;
legit_matrix = cat(2, legit_matrix, ones(fun_N_Veh,1));
%don't add 1 to N_Rsu because 
for i = 1:fun_N_Veh
    for a = 1:fun_N_Rsu
        if legit_matrix(i,a) == 1
            temp = alpha(i, :);
            rem_element = legit_matrix(i,:)==0;
            rem_element(a) = 1;
            temp(rem_element) = [];
            %temp(a) = [];
            %temp(legit_matrix(i,:) == 0) = [];
            if isempty(temp) == 0
                rho(i, a) = -min(temp);
            end
        end
    end
end

rho_res = DAMPING*rho + (1 - DAMPING) * rho_old;
end