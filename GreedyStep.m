function [ Tout,MinTemperature,MinIndex,MinEnergy,Energies ] = GreedyStep( Gas,...
        InitialState, AmbientTemperature, Tin, TempVec, Refrigerants, varargin)
    
    Options = LazyOptions(varargin,DefaultOptions);
    
    MinEnergy0 = CalculateEverything(Gas,InitialState,AmbientTemperature,Tin,Refrigerants,Options);
    Tout = Tin;
    MinEnergy      = MinEnergy0;
    MinTemperature = nan;
    MinIndex      = nan;
    
    Energies = nan(1,length(TempVec));
    for i =  1:length(TempVec)
        t = TempVec(i);
        Energy = inf(1,3);
        if (~max([Tout{1}, Tout{2}, Tout{3}] == t)) && (t < AmbientTemperature + Options.TemperatureDifference)
            if max(Tout{2}) < t  && t < AmbientTemperature + Options.TemperatureDifference
                Energy(1) = CalculateEverything(Gas,InitialState,AmbientTemperature,{[Tout{1},t],Tout{2},Tout{3}},Refrigerants,Options);
            end
            if max(Tout{3}) < t  && t < min(Tout{1})
                Energy(2) = CalculateEverything(Gas,InitialState,AmbientTemperature,{Tout{1},[Tout{2},t],Tout{3}},Refrigerants,Options);
            end
            if min(Tout{3}) < t && t < min(Tout{2})
                Energy(3) = CalculateEverything(Gas,InitialState,AmbientTemperature,{Tout{1},Tout{2},[Tout{3},t]},Refrigerants,Options);
            end
        end
        [Energies(i),index] = min(Energy);
        if Energies(i)<MinEnergy
            MinTemperature = t;
            MinEnergy      = Energies(i);
            MinIndex       = index;
        end
    end
    %plot(TempVec,Energies/3.6e3,MinTemperature,MinEnergy/3.6e3,'o')
    Tout{MinIndex} = sort([Tout{MinIndex}, MinTemperature]);    
    %if DoOptimize
    %    %Tout = Optimize2(NG,t0,Tout,Fluids,Options);
    %    Tout = OptimizeSmarter(Gas,t0,Tout,Refrigerants,Options);
    %end
end

