function [ X ] = Tlike( x , T)
    c = 1;
    x = (x(:))';
    X = {};
    for k = 1:length(T)     
        d = length(T{k})-1;
        X{k} = x(c:(c+d));
        c = c+d+1;
    end
end

