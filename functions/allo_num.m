function [allocated_num] = allo_num(allo, N_Rsu)
% return each RSU's allocated vehicles' number
% input : allo, N_Rsu
num_RSU = [];
for a=1:N_Rsu+1
    num_RSU = [num_RSU, sum(allo==a)];
end

allocated_num = num_RSU;
end