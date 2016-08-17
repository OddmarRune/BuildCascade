function [  ] = PlotProcess( Prosess, varargin )
    Options = LazyOptions(varargin,...
        'Cycle',{'yes','no'},...
        'ProcessName','');
    
    if isnumeric(Options.ProcessName)
        Options.ProcessName = sprintf('(%d)',Options.ProcessName);
    end        
    
    N = length(Prosess);
    H = zeros(1,N);
    P = zeros(1,N);
    T = {};
    for i = 1:N
        if isa(Prosess{i},'Fluid')
            H(i) = Prosess{i}.get('H');
            P(i) = Prosess{i}.get('P');
            T{i} = sprintf('  %d',i);
        else            
            H(i) = Prosess{i}.H;
            P(i) = Prosess{i}.P;
            T{i} = sprintf('  %d',i);
        end
    end
    if CheckOption(Options,'Cycle','yes')
        H(end+1) = H(1);
        P(end+1) = P(1);
        T{end+1} = '';
    end
    plot(H/1e3,P/1e5,'-o','LineWidth',1.5)
    text(H/1e3,P/1e5,T)
    text(mean(H)/1e3,geomean(P)/1e5,Options.ProcessName)
end

