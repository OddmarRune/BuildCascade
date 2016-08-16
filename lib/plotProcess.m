function [  ] = plotProcess( Pro, nr, cycle )
    if nargin<3
        cycle = true;
    end
    if nargin<2
        myNr = '';
    else
        if nr > 0
            myNr = sprintf('(%d)',nr);
        else
            myNr = '';
        end
    end
    
    N = length(Pro);
    H = zeros(1,N);
    P = zeros(1,N);
    T = {};
    for i = 1:N
        if isa(Pro{i},'Fluid')
            H(i) = Pro{i}.get('H');
            P(i) = Pro{i}.get('P');
            T{i} = sprintf('  %d',i);
        else
            H(i) = Pro{i}.H;
            P(i) = Pro{i}.P;
            T{i} = sprintf('  %d',i);
        end
    end
    if cycle
        H(end+1) = H(1);
        P(end+1) = P(1);
        T{end+1} = '';
    end
    plot(H/1e3,P/1e5,'-o','LineWidth',1.5)
    text(H/1e3,P/1e5,T)
    text(mean(H)/1e3,geomean(P)/1e5,myNr)
end

