% DataGen

% Denne treng i grunnen berre køyrast ein gong kvar gong du startar matlab.
clear 
setup

Options.MaxGenerations = 100;
Options.GeneticDisplay = 'off';
Options.Compressor     = @(R,P1,p2)SimpleCompressor(R,P1,p2,'eta',0.85);

% Options.Compressor     = @Compressor;
% Options.OverHeatTo     = 'NextTemperature';
% Options.OptimizePlot   = 'off';
% Options.PressureDrop          = 0.5e5;
% Options.TemperatureDifference = 5;

AmbientTemperatures = -30:10:40;

T111 = {  -40.227           ,   -101.52,              -160 };
T122 = {  -40.227           , [ -75.027, -101.52 ], [ -128.93, -160 ]};
T222 = {[ -29.959, -40.227 ], [ -75.027, -101.52 ], [ -128.93, -160 ]};

ImproveSetup(AmbientTemperatures,T222,Options)
ImproveSetup(AmbientTemperatures,T111,Options)
ImproveSetup(AmbientTemperatures,T122,Options)
