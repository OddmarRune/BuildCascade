close all
clear 

setup
autodock

t0 = 12;
TempVec = -159:1:t0;

Fluids = {'R290','R1150','R50'};
T      = {  -35,  -90 , -160 };
steps  = 6;

Options =  CheckOptions(); 
%Options.eta = @(p1,p2,R) beregnetaMulti( p1, p2, 0.85, 3, R,0);
Options.eta = @(p1,p2,R) MyEta( [p1 p2], 0.85, 3, R);
%Options.eta = @(p1,p2,R) 0.85;
Options.MinimumPressure = 1.1e5;
% Options.MinimumPressure = 0.0e5;

alternative = 3;
switch alternative
    case 1
        NG.name = 'Methane';
        NG.p     = 60e5;
        NG.t     = t0+Options.DeltaT;
        NG.Hfunc = @(T,p) CoolProp.PropsSI('H','T',T,'P',p,NG.name);
        Options.DeltaP = 0.5e5;
    case 2
        NG.name = 'NatureGass';
        NG.p     = 61e5;
        NG.t     = t0+Options.DeltaT;
        h0 = -HysysIterp(NG.p,kelvin(NG.t)) +CoolProp.PropsSI('H','T',kelvin(NG.t),'P',NG.p,'Methane');
        NG.Hfunc = @(T,p) HysysIterp(p,T)+h0;
        Options.DeltaP = 0.2e5;
    case 3
        NG.name = 'NG';
        NG.p = 60e5;
        NG.t = t0+Options.DeltaT;        
        NG.Hfunc = @(T,p) h_NG(p,T);
        Options.DeltaP = 0.5e5;
end


MyFig = figure('Name','Greedy Search'); hold on

orig_state = warning;
warning('off','all');

T = OptimizeSmarter(NG,t0,T,Fluids,Options);

MinEnergy = 400*3.6e3;
n = 0;
while (MinEnergy/3.6e3)>200 && n<steps
    n = n+1;
% for n = 1:steps
    [ T,MinTemperature,MinIndex,MinEnergy,Energies ] = ...
        GreedyStep( NG,t0,T,TempVec,Fluids,true,Options);
    plot(TempVec,Energies/3.6e3,MinTemperature,MinEnergy/3.6e3,'o')    
    fprintf('%d: adding a step to refrigerant nr %d at temperature %.3g \n',n,MinIndex,MinTemperature)    
end

warning(orig_state);
hold off

%%

fprintf('Post optimizing with genetic algorithm to gain up to 5%% extra.\n')
T = OptimizeGenetic(NG,t0,T,Fluids,Options);

%%

MyCascade.(Fluids{1}) = T{1};
MyCascade.(Fluids{2}) = T{2};
MyCascade.(Fluids{3}) = T{3};
MyCascade


Cooler = Cascade(t0,T,Fluids,Options);
Gas    = Cooling(NG.Hfunc,NG.t,NG.p,Cooler.MyTemperatures,Options);
Mass           = FindMassTransport(Cooler,Gas);
SpecificEnergy = CalculateSpecificEnergy(Cooler, Mass)
COP            = (Gas.States{1}.H-Gas.States{end}.H)/SpecificEnergy

kWh_per_ton = SpecificEnergy/3.6e3


figures = struct;

for i = 1:length(Fluids)
    figures.(Fluids{i}) = figure('Name',Fluids{i});
    PlotPH(Fluids{i}), hold on, ylim([1e-1,1e2])
end

for i = 1:length(Cooler.Circuits)
    figure(figures.(Cooler.Circuits{i}.MyFluid));
    plotProcess(Cooler.Circuits{i}.States,Cooler.Circuits{i}.MyHeatExchangerNr)
end

figures.(NG.name) = figure('Name',NG.name);

switch alternative 
    case 3
        PlotNG
    otherwise
        PlotPH('Methane')        
end
hold on

P = [];
H = [];
for i = 1:length(Gas.States)
    P(i) = Gas.States{i}.P;
    H(i) = Gas.States{i}.H;
end
plot(H/1e3,P/1e5,'-o','LineWidth',2), hold off

figure('Name','Cooling of Natural Gas')
t = [];
q = cumsum([0, cell2mat(Gas.DeltaH)]);

for i = 1:length(Gas.States)
    t(i) = celsius(Gas.States{i}.T);
end

tc = sort([Cooler.MyTemperatures(2:end),Cooler.MyTemperatures(2:end)],'descend') ;
qc = sort([q,q(2:end-1)]);

plot(q/1e3,t,qc/1e3,tc)

%%
SaveAllOpenFigures('fig',-2)