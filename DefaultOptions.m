function [ Options ] = DefaultOptions ()
    Options.PressureDrop            = 0.5e5;
    Options.TemperatureDifference   = 5;    
    Options.Compressor              = @(Gas,InitialState,FinalPressure) ...
        Compressor( Gas, InitialState, FinalPressure );
    Options.MinimumPressure         = 1.1e5;
    Options.OverHeating             = {'off','on'};
    Options.EvaporatorPressureDrop  = 0.0e5;
    Options.OverHeatingPressureDrop = 0.0e5;
    Options.OverHeatTo              = {'NextTemperature',...
        'AmbientTemperature','NextExternalTempetarure'};
end