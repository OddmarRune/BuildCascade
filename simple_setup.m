close all

setup
autodock

t0 = 12;
T = {-40, -102, -160};
Refrigerants = {'R290','R1150','R50'};

MySettings = {...
    'OverHeating','on',...
    'OverHeatTo','NextTemperature'};

Options = LazyOptions(MySettings,DefaultOptions);

alternative = 3;

if alternative == 1
    fluid       = {'R50','R170','R728','R290','R600','R600a'};
    fractions   = [0.8770,0.0540,0.031,0.0260,0.0080,0.0040];    
    NG = Mix('NaturalGas',fluid,fractions);
elseif alternative == 2
    NG = Mix('Methane');
else
    NG = NaturalGas('NaturalGas'); 
end
NG0 = NG.update('P',60e5,'T',kelvin(t0+Options.TemperatureDifference));

MyCascade.(Refrigerants{1}) = T{1};
MyCascade.(Refrigerants{2}) = T{2};
MyCascade.(Refrigerants{3}) = T{3};
MyCascade

Cooler = Cascade(t0,T,Refrigerants,Options);
Gas = Cooling(NG,NG0,Cooler.Temperatures,Options);
Mass = FindMassTransport(Cooler,Gas)
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
    fprintf('ExNr: %d, %6s, %5.3g, [',...
        Cooler.Circuits{i}.MyHeatExchangerNr,...
        Cooler.Circuits{i}.Refrigerant.Name,...
        Cooler.Circuits{i}.Temperature)
    fprintf(' %d ',Cooler.Circuits{i}.UsedHeatExchangers)
    fprintf(']\n')        
end

figures.(NG.Name) = figure;

if alternative == 3
    PlotNG
elseif alternative == 2
    PlotPH(NG,'pwindow',[50e5 70e5])
else
    disp('No Plot')
end
hold on

P = [];
H = [];
for i = 1:length(Gas.States)
    P(i) = Gas.States{i}.P;
    H(i) = Gas.States{i}.H;
end
plot(H/1e3,P/1e5,'-o','LineWidth',2), hold off


% return 
% 
% figure
% t = [];
% q = cumsum([0, cell2mat(Gas.DeltaH)]);
% 
% for i = 1:length(Gas.States)
%     t(i) = celsius(Gas.States{i}.T);
% end
% 
% tc = sort([Cooler.MyTemperatures(2:end),Cooler.MyTemperatures(2:end)],'descend') ;
% qc = sort([q,q(2:end-1)]);
% 
% plot(q/1e3,t,qc/1e3,tc)

% SaveAllOpenFigures('fig',-1)