function [y] = xlogx(x)
% get value of xlog_2(x)
% if x=0, it returns 0 otherwise, it returns 0
    ind_zero = x==0;
    x = x+ind_zero;
    y = x.*log(x)/log(2);
end