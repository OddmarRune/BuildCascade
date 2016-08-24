function [ MyMap ] = MyColorMap( colors, N )
    if ~iscell(colors) && isnumeric(colors)
        [a,b] = size(colors);
        if b == 3
            for i = 1:a
                Colors{i} = colors(i,:);
            end
        elseif a == 3
            for i = 1:b
                Colors{i} = colors(:,i)';
            end
        else
            error('Wrong Input');
        end
    else
        Colors = colors;
    end
        
    MyMap = Colors{1};
    if nargin<2
        N = 100;
    end
    for k = 2:length(Colors)
        for i = 1:N
            MyMap(end+1,:) = ((N-i)*Colors{k-1}+i*Colors{k})/N;
        end    
    end
end