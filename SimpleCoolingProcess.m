function [ Process ] = SimpleCoolingProcess( ExternalTemperatures,...
                                             Temperature, ...
                                             Refrigerant, ...
                                             varargin )
                                         
    Options = LazyOptions(varargin, DefaultOptions);

    [ ExternalTemperatures, HeatExchangerNr ] = sort(ExternalTemperatures,'ascend');
    N = length(ExternalTemperatures);
    
    if Temperature>=ExternalTemperatures(1)
        error('Temperature Higher than External Temperature')
    end
    
    Process.MyHeatExchangerNr = N + 1;
    
    if isa(Refrigerant,'Mix')
        % Ok        
    elseif isa(Refrigerant,'char')
        Refrigerant = Mix(Refrigerant);
    else
        error('Wrong Refrigerant input')
    end
    
    Process.OutBoiler = Refrigerant.update('T',kelvin(Temperature),'Q',1.0);
    
    % Adding Pressure Drop Boiler
    Process.OutBoiler = Refrigerant.change(...
            'P',@(p) p-Options.EvaporatorPressureDrop,'Q',1.0,Process.OutBoiler);
    
    FirstUsable = find((ExternalTemperatures+Options.TemperatureDifference)>Temperature,1);
    Process.UsedHeatExchangers(1) = HeatExchangerNr(FirstUsable);
       
    if CheckOption(Options,'OverHeating','on')            
        if CheckOption(Options,'OverHeatTo','NextExternalTempetarure')
            OverHeatingTemperature = kelvin(ExternalTemperatures(1));
        elseif CheckOption(Options,'OverHeatTo','AmbientTemperature')
            OverHeatingTemperature = kelvin(ExternalTemperatures(end));
        elseif CheckOption(Options,'OverHeatTo','NextTemperature')
            OverHeatingTemperature = kelvin(ExternalTemperatures(1));
        end
        Process.OverHeating = Refrigerant.change(...
            'P',@(p) p-Options.OverHeatingPressureDrop,...
            'T',OverHeatingTemperature,...
            Process.OutBoiler);        
    else
        Process.OverHeating = Process.OutBoiler;
    end

    Process.OutCondenser = Refrigerant.update(...
        'T',kelvin(ExternalTemperatures(FirstUsable)+Options.TemperatureDifference),...
        'Q',0.0);
    
    Process.InBoiler = Refrigerant.change(...
        'P',@(p) p+Options.EvaporatorPressureDrop,...
        'H',Process.OutCondenser.H,Process.OutBoiler);    
    
    Process.BoilerDeltaH = Process.OverHeating.H-Process.InBoiler.H;

    Process.OutCooler{1} = Process.OutCondenser; % Cooler nr 1 == Condenser
    Process.Cooler{1}.UsingHeatExchangerNr = HeatExchangerNr(FirstUsable);
                
    for i = (FirstUsable+1):(N+1)
        % Check        
        [ Process.OutCompressor, Process.CompressorEta ] = ...
            Options.Compressor(Refrigerant, ...
                Process.OverHeating,...
                Process.OutCooler{end}.P + Options.PressureDrop);
        
        if (i>N) || (celsius(Process.OutCompressor.T)<ExternalTemperatures(i)+Options.TemperatureDifference)
            break
        end
        
        Process.UsedHeatExchangers(end+1) = HeatExchangerNr(i);
        
        Process.OutCooler{end+1} = Refrigerant.change(...
            'P',@(p) p+Options.PressureDrop,...
            'T',kelvin(ExternalTemperatures(i)+Options.TemperatureDifference),...
            Process.OutCooler{end});
            
        Process.Cooler{end}.DeltaH = Process.OutCooler{end}.H-Process.OutCooler{end-1}.H;
        Process.Cooler{end+1}.UsingHeatExchangerNr = HeatExchangerNr(i);
    end
    Process.Cooler{end}.DeltaH = Process.OutCompressor.H - Process.OutCooler{end}.H;
    Process.CompressorDeltaH = Process.OutCompressor.H - Process.OverHeating.H;
    
    Process.Refrigerant = Refrigerant;
    Process.Temperature = Temperature;
    
    if CheckOption(Options,'OverHeating','on')  
        Process.States = { Process.OutBoiler, ...
            Process.OverHeating, ...
            Process.OutCompressor, ...
            Process.OutCooler{end:-1:1}, ...
            Process.InBoiler };
    else
        Process.States = { Process.OutBoiler, ...
            Process.OutCompressor, ...
            Process.OutCooler{end:-1:1}, ...
            Process.InBoiler };
    end
end

