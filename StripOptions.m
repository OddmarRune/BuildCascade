function [ StrippedOptions ] = StripOptions( OptionsInput )
    Options = LazyOptions(OptionsInput,DefaultOptions);    
    StrippedOptions = struct;
    List = {'Compressor','EvaporatorPressureDrop','MinimumPressure',...
        'OverHeating','OverHeatingPressureDrop','OverHeatTo','PressureDrop',...
        'TemperatureDifference'};
    for i = 1:length(List)
        StrippedOptions.(List{i}) = Options.(List{i});
    end
end

