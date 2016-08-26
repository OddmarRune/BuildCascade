function [ Options ] = DefaultOptions ()
    Options.PressureDrop            = 0.5e5;
    Options.TemperatureDifference   = 5;    
    Options.Compressor              = @Compressor;
    Options.MinimumPressure         = 1.1e5;
    Options.OverHeating             = {'on','off'};
    Options.EvaporatorPressureDrop  = 0.0e5;
    Options.OverHeatingPressureDrop = 0.0e5;
    Options.OverHeatTo              = {'NextTemperature',...
        'AmbientTemperature','NextExternalTempetarure'};
    Options.OptimizePlot            = {'on', 'off'};
    Options.MaxGenerations          = 50;
    Options.GeneticDisplay          = {'final','off','iter','diagnose'};
end

%Options.Compressor = @(Gas,InitialState,FinalPressure) ...
%        Compressor( Gas, InitialState, FinalPressure );