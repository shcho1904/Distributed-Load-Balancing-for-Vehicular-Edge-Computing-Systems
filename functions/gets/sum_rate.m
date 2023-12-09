function [Rate_sum] = sum_rate(allo, Rate_1, Rate_2, Rate_3, ind_2)
[N_users,N_resources] = size(allo);
mode = sum(allo, 1);
Rate_sum = 0;
num = [1:N_users]';
R1 = 0;
R2 = 0;
R3 = 0;

for a = 1:N_resources
    max_nums = num(allo(:,a) == 1);
    if mode(a) == 1
        Rate_sum = Rate_sum + sum(Rate_1(:,a).*allo(:,a));
    end
    if mode(a) == 2
        if ind_2(max_nums(1)) ~= 0
            R1 = Rate_2(max_nums(1),a) + Rate_3(max_nums(2),a);
        end
        if ind_2(max_nums(2)) ~= 0
            R2 = Rate_2(max_nums(2),a) + Rate_3(max_nums(1),a);
        end
        if ind_2(max_nums(1)) == 0 && ind_2(max_nums(2)) == 0
            R3 = Rate_2(max_nums(1),a) + Rate_2(max_nums(2),a);
        end
        Rate_sum = Rate_sum + max([R1; R2; R3]);
        R1 = 0;
        R2 = 0;
        R3 = 0;
    end
    if mode(a) == 3
        Rate_sum = Rate_sum + sum(Rate_3(:,a).*allo(:,a));
    end
%     if mode(a) > 3
%         Rate_sum = Rate_sum + sum(Rate_3(:,a).*allo(:,a))/mode(a)*3;
%     end
end
end

