fluid       = {'R50','R170','R728','R290','R600','R600a'};
fractions   = [0.8770,0.0540,0.031,0.0260,0.0080,0.0040];


if ~exist('NG','var') || ~isa(NG,'Mix')    
    NG = Mix('NatureGas',fluid,fractions);
end

NG.update('P',60e5,'T',300)
