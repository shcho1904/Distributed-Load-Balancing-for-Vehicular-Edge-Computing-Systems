function [rank_list] = rank_msg(k, expr, exc_indx)
%  evaluate k-th smallest number of expr

% assume that expr size is (1,N)

% eliminate exc_indx
temp = expr;
temp(exc_indx) = [];
rank_list = mink(temp, k);

end