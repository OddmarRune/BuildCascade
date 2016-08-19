clear
setup

t0 = 10;
T = {[-17.45,-38.443],[-71.499,-102.36],[-129.92,-160]};
Refrigerants = {'R290','R1150','R50'};

Options.OverHeating = 'on';
Options.OverHeatTo = 'NextTemperature';  
Options.Compressor = @Compressor;

Options = LazyOptions(Options,DefaultOptions);

return

NG  = NaturalGas('NaturalGas'); 
NG0 = NG.update('P',60e5,'T',kelvin(t0+Options.TemperatureDifference));

MyCascade.(Refrigerants{1}) = T{1};
MyCascade.(Refrigerants{2}) = T{2};
MyCascade.(Refrigerants{3}) = T{3};
MyCascade

Cooler = Cascade(t0,T,Refrigerants,Options);
Gas    = Cooling(NG,NG0,Cooler.Temperatures,Options);
[Mass,Eq]   = FindMassTransportSymbolic(Cooler,Gas)
SpecificEnergy = CalculateSpecificEnergy(Cooler, Mass)
COP = (Gas.States{1}.H-Gas.States{end}.H)/SpecificEnergy

kWh_per_ton = SpecificEnergy/3.6e3

figures = struct;
for i = 1:length(Refrigerants)
    figures.(Refrigerants{i}) = figure;
    PlotPH(Mix(Refrigerants{i}),'pwindow',[1e4,1e7]), hold on
end

for i = 1:length(Cooler.Circuits)
    figure(figures.(Cooler.Circuits{i}.Refrigerant.Name));
    PlotProcess(Cooler.Circuits{i}.States,'ProcessName',Cooler.Circuits{i}.MyHeatExchangerNr)
    str1 = sprintf('ExNr: %d, %6s, %5.3g, [',...
        Cooler.Circuits{i}.MyHeatExchangerNr,...
        Cooler.Circuits{i}.Refrigerant.Name,...
        Cooler.Circuits{i}.Temperature);
    str2 = sprintf(' %d ',Cooler.Circuits{i}.UsedHeatExchangers);
    str3 = ']';
    fprintf('%s%s%s\n',str1,str2,str3)
end

figures.(NG.Name) = figure;

PlotNG, hold on

P = [];
H = [];
for i = 1:length(Gas.States)
    P(i) = Gas.States{i}.P;
    H(i) = Gas.States{i}.H;
end

plot(H/1e3,P/1e5,'-o','LineWidth',2), hold off