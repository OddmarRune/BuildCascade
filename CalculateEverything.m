function [ SpecificEnergy, COP ] = CalculateEverything( Gas, InitialState, AmbientTemperature, Temperatures, Refrigerants, varargin)
    Options = LazyOptions(varargin,DefaultOptions);
        
    try
        Cooler = Cascade(AmbientTemperature,Temperatures,Refrigerants,Options);
    catch
        SpecificEnergy = nan;
        COP = nan;
        return
    end
    if Options.MinimumPressure > 0
        for i = 1:length(Cooler.Circuits)
            if Cooler.Circuits{i}.OverHeating.P < Options.MinimumPressure
                SpecificEnergy = inf;
                COP = 0;
                return
            end
        end
    end
    Gas1 = Cooling(Gas,InitialState,Cooler.Temperatures,Options);
    Mass = FindMassTransport(Cooler,Gas1);
    SpecificEnergy = CalculateSpecificEnergy(Cooler, Mass);
    COP = (Gas1.States{1}.H-Gas1.States{end}.H)/SpecificEnergy;
end

