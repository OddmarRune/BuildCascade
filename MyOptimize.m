function [ Tout ] = MyOptimize(NG,NG0,t0,T,Refrigerants, varargin)
    Options = LazyOptions(varargin,DefaultOptions);
            
    t    = sort(cell2mat(T),'descend');
    s    = length(t);
    tmin = t(end);
    
    x0 = t(1:end-1);
             
    fun = @(x) CalculateEverything(NG,NG0,t0, Tlike([x tmin],T),Refrigerants,Options)/3.6e3;               
        
    orig_state = warning;
    warning('off','all');
              
    %x = fminsearch(fun,x0,optimset('PlotFcns',@optimplotfval));
    x = fminsearch(fun,x0);
    %x = fminunc(fun,x0,optimset('PlotFcns',@optimplotfval));

    warning(orig_state);
    Tout = Tlike([x tmin],T);
end

