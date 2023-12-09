function [rank_list] = modified_rank_msg(k, expr, exc_indx)
%  evaluate k-th smallest number of expr

% assume that expr size is (1,N)

% eliminate exc_indx
temp = expr;
temp(exc_indx) = [];

% remove inf, -inf, NaN
temp = rmmissing(temp);
temp(temp > 50 & temp <-50) = [];
if k ~= 0
    rank_list = maxk(temp, k);
else
    rank_list = 0;
end

end