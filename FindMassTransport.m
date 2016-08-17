function [ m ] = FindMassTransport( Cooler, Gas )

    N = length(Cooler.Circuits);
    A = zeros(N);
    b = zeros(N,1);
    
    for i = 1:N
        c = Cooler.Circuits{i}.MyHeatExchangerNr-1;
        A(c,c) = -Cooler.Circuits{i}.BoilerDeltaH;
        for j = 1:length(Cooler.Circuits{i}.UsedHeatExchangers)
            r = Cooler.Circuits{i}.Cooler{j}.UsingHeatExchangerNr-1;
            if r ~= 0
                A(r,c) = Cooler.Circuits{i}.Cooler{j}.DeltaH;
            end
        end
    end
    
    for i = 1:length(Gas.UsingHeatExchangerNr)
        c = Gas.UsingHeatExchangerNr{i}-1;
        b(c) = -Gas.DeltaH{i};
    end
   
    if det(A)~=0
        m = A\b;
    else
        error('Unsolvable')
    end
end

