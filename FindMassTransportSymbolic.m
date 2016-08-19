function [ m, Eq ] = FindMassTransportSymbolic( Cooler, Gas )

    N = length(Cooler.Circuits);
    
    A = zeros(N);
    b = zeros(N,1);
    
    As = sym(A);
    bs = sym(b);
    
    for i = 1:N
        c = Cooler.Circuits{i}.MyHeatExchangerNr-1;
        
        A(c,c) = -Cooler.Circuits{i}.BoilerDeltaH;        
        As(c,c) = -sym(sprintf('dH_BR%d',c+1));
        
        for j = 1:length(Cooler.Circuits{i}.UsedHeatExchangers)
            r = Cooler.Circuits{i}.Cooler{j}.UsingHeatExchangerNr-1;
            if r ~= 0
                A(r,c) = Cooler.Circuits{i}.Cooler{j}.DeltaH;
                As(r,c) = sym(sprintf('dH_C%d',r+1));
            end
        end
    end
    
    for i = 1:length(Gas.UsingHeatExchangerNr)
        c = Gas.UsingHeatExchangerNr{i}-1;
        b(c) = -Gas.DeltaH{i};
        bs(c) = -sym(sprintf('dH_G%d',c+1));
    end
   
    if det(A)~=0
        m = A\b;
    else
        error('Unsolvable')
    end
    ms = sym('m_%d',[1 N+1]);
    mg = ms(1);
    ms = ms(2:end);
    LHS = As*ms(:) - bs(:)*mg;
    LHS(N+1) = mg-1;
    Eq = LHS == 0;
    
end

