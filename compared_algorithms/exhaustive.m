tic
exh_time = Inf;
exh_allo = zeros(1, N_Veh);
for i1=1:N_Rsu+1
    for i2=1:N_Rsu+1
        for i3=1:N_Rsu+1
            for i4=1:N_Rsu+1
                for i5=1:N_Rsu+1
                    for i6=1:N_Rsu+1
                        for i7=1:N_Rsu+1
                            for i8=1:N_Rsu+1
                                for i9=1:N_Rsu+1
                                    for i10=1:N_Rsu+1
                                        temp_allo = [i1, i2, i3, i4, i5, i6, i7, i8, i9, i10];
                                        temp_time = sum_time(temp_allo, t_comm, t_comp_RSU, t_comp_local, RSU_Cpu_num);
                                        if temp_time < exh_time
                                            exh_time = temp_time;
                                            exh_allo = temp_allo;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
toc


