function [ Tout ] = MyOptimize(NG,NG0,t0,T,Refrigerants, varargin)
    Options = LazyOptions(varargin,DefaultOptions);
                
    MyCascade = struct;
    for k = 1:length(T)
        MyCascade.(Refrigerants{k}) = T{k}; 
    end
    
        
    
    t    = sort(cell2mat(T),'descend');
    s    = length(t);
    tmin = t(end);
    
    x0 = t(1:end-1);
             
    fun = @(x) CalculateEverything(NG,NG0,t0, Tlike([x tmin],T),Refrigerants,Options)/3.6e3;               
    
    InitialList = ReadFromLog(Options,MyCascade,t0,'galog.txt',...
        'AmbientTemperatureMatch','Approx');

    f = fun(x0);
    for i = 1:length(InitialList)
        y0 = [];
        for k = 1:length(InitialList{i})
            y0 = [y0 sort(InitialList{i}{k},'descend')];
        end
        y0 = y0(y0>min(y0));
        if fun(y0)<f
            x0 = y0;
            f = fun(y0);
        end
    end
        
    orig_state = warning;
    warning('off','all');
              
    x = fminsearch(fun,x0,optimset('PlotFcns',@optimplotfval));
    %x = fminsearch(fun,x0);
    
    %x = fminunc(fun,x0,optimset('PlotFcns',@optimplotfval));

    warning(orig_state);
    Tout = Tlike([x tmin],T);
        
    for k = 1:length(Tout)
        MyCascade.(Refrigerants{k}) = Tout{k}; 
    end
    AppendToLog(Options,MyCascade,t0,'galog.txt');
end

