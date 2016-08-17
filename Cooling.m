function [ output ] = Cooling( Gas, InitialState, CoolingTemperatures, varargin)
    Options = LazyOptions(varargin, DefaultOptions);   
    
    [CoolingTemperatures, Order] = sort(CoolingTemperatures,'descend');
    
    if ~isa(Gas,'Mix')
        error('Wrong Input!')
    end
    
    States{1} = Gas.update('P',InitialState.P,'T',InitialState.T);
    
    DeltaH = {};
    UsingHeatExchangerNr = {};
    
    for i = 1:length(CoolingTemperatures)        
        if States{end}.T > kelvin(CoolingTemperatures(i)+Options.TemperatureDifference)                            
            States{end+1} = Gas.change('P', @(p) p - Options.PressureDrop, ...
                'T', kelvin(CoolingTemperatures(i)+Options.TemperatureDifference),...
                States{end});            
            DeltaH{end+1} = States{end-1}.H-States{end}.H;
            UsingHeatExchangerNr{end+1} = Order(i);
        end
    end
    
    output.States = States;
    output.DeltaH = DeltaH;
    output.UsingHeatExchangerNr = UsingHeatExchangerNr;
end