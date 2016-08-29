function [ Tout ] = OptimizeGenetic(NG,NG0,t0,T,Refrigerants, varargin)
    Options = LazyOptions(varargin,DefaultOptions);
    
    s  = 0;
    x0 = [];
    d  = [];
    
    MyCascade = struct;
    for k = 1:length(T)
        MyCascade.(Refrigerants{k}) = T{k}; 
        s  = s + length(T{k});
        x0 = [x0 sort(T{k},'descend')];
        if isa(Refrigerants{k},'Mix')
            kritisk = celsius(Refrigerants{k}.Tcrit);
        else
            kritisk = celsius(Mix(Refrigerants{k}).Tcrit);
        end
        d = [d;kritisk*(ones(length(T{k}),1))];
    end
    
    tmin = min(x0);    
    x0 = x0(x0>tmin);
    d  = d(x0>tmin);
    s  = s-1;
    
    A = [];
    for i = 1:s-1
        A(i,i:(i+1)) = [-1 1];        
    end
    b = zeros(s-1,1);
    
    % Change this part
    A = [A;eye(s)];
    b = [b;d];
     
    %x0 = x0(:);
        
    fun = @(x) CalculateEverything(NG,NG0,t0, Tlike([x tmin],T),Refrigerants,Options)/3.6e3;               
    
    InitialList = ReadFromLog(Options,MyCascade,t0,'galog.txt',...
        'OptionMatch','none','AmbientTemperatureMatch','Approx');
    X0 = x0(:)';
    for i = 1:length(InitialList)
        y0 = [];
        for k = 1:length(InitialList{i})
            y0 = [y0 sort(InitialList{i}{k},'descend')];
        end
        y0 = y0(y0>min(y0));
        X0 = [X0;(y0(:))'];
    end
    
    orig_state = warning;
    warning('off','all');
          
    if CheckOption(Options,'OptimizePlot','on')
        gaoptions = gaoptimset('display',Options.GeneticDisplay,'InitialPopulation',X0,'PlotFcns',@gaplotbestfun,'Generations',Options.MaxGenerations);
    else
        gaoptions = gaoptimset('display',Options.GeneticDisplay,'InitialPopulation',X0,'Generations',Options.MaxGenerations);
    end
    
    problem.options = gaoptions;  
    problem.solver  = 'gamultiobj';
    problem.fitnessfcn = fun;        
    problem.Aineq = A;
    problem.bineq = b;
    problem.nvars = s;
    
    x = gamultiobj(problem);

    warning(orig_state);
    Tout = Tlike([x tmin],T);
    
    for k = 1:length(Tout)
        MyCascade.(Refrigerants{k}) = Tout{k}; 
    end
    AppendToLog(Options,MyCascade,t0,'galog.txt');
end