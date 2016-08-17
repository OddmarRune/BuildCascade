function [ SpecificEnergy ] = CalculateSpecificEnergy( Cooler, MassTransport, varargin )
    Options = LazyOptions(varargin,DefaultOptions);
    
    N = length(Cooler.Circuits);
    Energy = zeros(1,N);    
    
    for i = 1:N
        nr = Cooler.Circuits{i}.MyHeatExchangerNr-1;
        Energy(nr) = Cooler.Circuits{i}.CompressorDeltaH * MassTransport(nr);        
    end
    
    SpecificEnergy = sum(Energy);
end

