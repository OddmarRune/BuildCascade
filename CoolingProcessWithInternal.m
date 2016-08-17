function [ Processes ] = CoolingProcessWithInternal(  ExternalTemperatures, ...
                            Temperatures, Refrigerant, varargin  )
    
    Options = LazyOptions(varargin, DefaultOptions);
    
    InternalOptions = Options;
    InternalOptions.EvaporatorPressureDrop = 0.0e5;

    if isa(Refrigerant,'Mix')
        % Ok        
    elseif isa(Refrigerant,'char')
        Refrigerant = Mix(Refrigerant);
    else
        error('Wrong Refrigerant input')
    end
    
    Temperatures = sort(Temperatures,'descend');
    m = length(Temperatures);        
     
    Processes.Circuits{1} = SimpleCoolingProcess(...
        ExternalTemperatures,Temperatures(1),Refrigerant,Options);
    Processes.Temperatures = Processes.Circuits{1}.Temperature;
    
    for c = 2:m
        Processes.Circuits{c} = SimpleCoolingProcessWithInternal(...
            ExternalTemperatures,Temperatures(1:c-1),Temperatures(c),Refrigerant,InternalOptions);
        Processes.Temperatures(c) = Processes.Circuits{c}.Temperature;
    end        

    Processes.Refrigerant = Refrigerant;    
end