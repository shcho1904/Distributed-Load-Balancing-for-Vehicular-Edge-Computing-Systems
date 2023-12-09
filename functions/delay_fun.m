function [value] = delay_fun(Stick_Veh_num, Cpu_num, exe_time, comm_time)
%delay_fun : evaluate waiting+processing time
    value = (floor(Stick_Veh_num./Cpu_num)+1) .* (1 - (Cpu_num./(2*Stick_Veh_num).*floor(Stick_Veh_num./Cpu_num))) .* exe_time + comm_time;

end