function [ Process ] = SimpleCoolingProcessWithInternal( ExternalTemperatures,...
                                            InternalTemperatures,...
                                            Temperature, ...
                                            Refrigerant, ...
                                            varargin)
                                         
    Options = LazyOptions(varargin, DefaultOptions);

    [ ExternalTemperatures, HeatExchangerNr ] = sort(ExternalTemperatures,'ascend');
    N = length(ExternalTemperatures);
    [ InternalTemperatures, InternalHeatExchangerNr ] = sort(InternalTemperatures,'ascend');
    n = length(InternalTemperatures);          
    
    if Temperature>=InternalTemperatures(1)
        error('Temperature Higher than lowest Internal Temperatures')
    end
    
    Process.MyHeatExchangerNr = N + n + 1;    
    
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
    
    % Using lowest of internal temperatures.
    MyInternalTemperature = InternalTemperatures(1);
    
    % Using external temperatures for additional cooling.
    % Should possibly use higher internal temperatures as well.
    FirstUsableExternal = find((ExternalTemperatures+Options.TemperatureDifference)>MyInternalTemperature,1);
    FirstUsableInternal = find((InternalTemperatures+Options.TemperatureDifference)>MyInternalTemperature,1);
    
    Process.UsedHeatExchangers(1) = N + InternalHeatExchangerNr(1);                           
    
    if CheckOption(Options,'OverHeating','on')            
        if CheckOption(Options,'OverHeatTo','NextExternalTempetarure')
            OverHeatingTemperature = kelvin(ExternalTemperatures(1));
        elseif CheckOption(Options,'OverHeatTo','AmbientTemperature')
            OverHeatingTemperature = kelvin(ExternalTemperatures(end));
        elseif CheckOption(Options,'OverHeatTo','NextTemperature')
            OverHeatingTemperature = kelvin(min([InternalTemperatures(1),ExternalTemperatures(1)]));
        end
        Process.OverHeating = Refrigerant.change(...
            'P',@(p) p-Options.OverHeatingPressureDrop,...
            'T',OverHeatingTemperature,...
            Process.OutBoiler);        
    else
        Process.OverHeating = Process.OutBoiler;
    end
    
    Process.OutCondenser = Refrigerant.update('T',kelvin(MyInternalTemperature),'Q',0.0);       
    Process.InBoiler = Refrigerant.change('P',@(p) p+Options.EvaporatorPressureDrop,...
        'H',Process.OutCondenser.H,Process.OutBoiler);    
    
    Process.BoilerDeltaH = Process.OverHeating.H-Process.InBoiler.H;
    
    Process.OutCooler{1} = Process.OutCondenser; % Cooler nr 1 == Condenser
    Process.Cooler{1}.UsingHeatExchangerNr = N + InternalHeatExchangerNr(1);    

    % Check
    NextPressure = Process.OutCondenser.P;  % No pressure drop over internal condenser    
    [ Process.OutCompressor, Process.CompressorEta ] = ...
        Options.Compressor(Refrigerant,Process.OverHeating,NextPressure);
    
    if (celsius(Process.OutCompressor.T)>ExternalTemperatures(FirstUsableExternal)+Options.TemperatureDifference)
        for i = FirstUsableExternal:N
            Process.UsedHeatExchangers(end+1) = HeatExchangerNr(i);
            Process.OutCooler{end+1} = Refrigerant.change(...
                'P',NextPressure,...
                'T',kelvin(ExternalTemperatures(i)+Options.TemperatureDifference),...
                Process.OutCooler{end});
            
            Process.Cooler{end}.DeltaH = Process.OutCooler{end}.H-Process.OutCooler{end-1}.H;
            Process.Cooler{end+1}.UsingHeatExchangerNr = HeatExchangerNr(i);
            
            % Check
            NextPressure = Process.OutCooler{end}.P + Options.PressureDrop;
            [ Process.OutCompressor, Process.CompressorEta ] = ...
                Options.Compressor(Refrigerant,Process.OverHeating,NextPressure);                        
            
            if (i<N) && (celsius(Process.OutCompressor.T)<ExternalTemperatures(i+1)+Options.TemperatureDifference)
                break
            end
        end
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

