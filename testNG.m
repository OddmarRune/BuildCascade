fluid       = {'R50','R170','R728','R290','R600','R600a'};
fractions   = [0.8770,0.0540,0.031,0.0260,0.0080,0.0040];


if ~exist('NG','var') || ~isa(NG,'Mix')    
    NG = Mix('NatureGas',fluid,fractions);
end

p = 60e5;
T = linspace(-160,20)+273.15;
h = NG.change('P',p,'T',T).H;

plot(h/1e3,T-273.15), grid on

dT = 5;
Th = 273.15+15;
COP = @(Tc) Tc./(Th-Tc);

Tm = (T(1:end-1)+T(2:end))/2;

sum(diff(h)./COP(Tm-dT))/3.6e3