% run

clear
close all

setup
autodock

R = Mix('Propane');

AmbientTemperature = 12;
Temperatures = [-40 -12];

C1 = CoolingProcessWithInternal(AmbientTemperature,Temperatures,R,...
    'OverHeating','on','OverHeatTo','AmbientTemperature');

figure(1)
PlotPH(R,'pwindow',[1e4 1e7]), hold on
for i = 1:length(C1.Circuits)
    PlotProcess(C1.Circuits{i}.States,'ProcessName',i+1)
end
hold off
title('Over Heating to Ambient')

C2 = CoolingProcessWithInternal(AmbientTemperature,Temperatures,R,...
    'OverHeating','on','OverHeatTo','NextTemperature');

figure(2)
PlotPH(R,'pwindow',[1e4 1e7]), hold on
for i = 1:length(C2.Circuits)
    PlotProcess(C2.Circuits{i}.States,'ProcessName',i+1)
end
hold off
title('Over Heating to Next Temperature')


C3 = CoolingProcessWithInternal(AmbientTemperature,Temperatures,R,...
    'OverHeating','off');

figure(3)
PlotPH(R,'pwindow',[1e4 1e7]), hold on
for i = 1:length(C3.Circuits)
    PlotProcess(C3.Circuits{i}.States,'ProcessName',i+1)
end
hold off
title('No Over Heating')

SaveAllOpenFigures('fig')