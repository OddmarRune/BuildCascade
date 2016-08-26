function [ Tout ] = ImproveSetup(t0,T,varargin)
    Options = LazyOptions(varargin, DefaultOptions);
      
    Refrigerants = {'R290','R1150','R50'};    
    NG = NaturalGas('NaturalGas'); 

    TT = zeros(length(t0),length(cell2mat(T)));

    for k = 1:length(t0)
        fprintf('step nr %d of %d\n',k,length(t0))    
        NG0 = NG.update('P',60e5,'T',kelvin(t0(k)+Options.TemperatureDifference));    

        T = OptimizeGenetic(NG,NG0,t0(k),T,Refrigerants,Options);
        T = MyOptimize(NG,NG0,t0(k),T,Refrigerants,Options);
        TT(k,:) = cell2mat(T);
                    
        Cooler = Cascade(t0(k),T,Refrigerants,Options);
        Gas = Cooling(NG,NG0,Cooler.Temperatures,Options);
        Mass{k} = FindMassTransport(Cooler,Gas);
        SpecificEnergy(k) = CalculateSpecificEnergy(Cooler, Mass{k});
        COP(k) = (Gas.States{1}.H-Gas.States{end}.H)/SpecificEnergy(k);

        kWh_per_ton(k) = SpecificEnergy(k)/3.6e3;
    end
    
    if CheckOption(Options,'OverHeating','on')
        heating = Options.OverHeatTo;
    else
        heating = 'Dewpoint';
    end    
   
    eta = Options.Compressor('DisplayName',0,0);
    filename = strrep(strrep(sprintf('Improved_%d%d%d_%s_%s',length(T{1}),length(T{2}),length(T{3}),heating,eta),'.',''),'-','_');
    
    close all

    figure(1)
    plot(t0,TT,'-o'), grid on, ylim([-200,20*ceil(max(TT(:))/20)])
    title(strrep(filename,'_','-'))

    t0 = t0(:);
    kWh_per_ton = kWh_per_ton(:);

    figure(2)
    plot(t0,kWh_per_ton), grid on
    title(strrep(filename,'_','-'))

    SaveAllOpenFigures('path','fig','filename',filename)

    close all
    
    tab.(filename) = table(t0,kWh_per_ton);

    writetable(tab.(filename),sprintf('data/%s',filename))

    dlmwrite(sprintf('data/%s_tempsetup.txt',filename),TT)
    
end