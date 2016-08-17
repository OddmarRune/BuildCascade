function [ eta ] = MyEta( p1, eta_base, pr_base, R, N )
% MYETA Calculates isentropic efficiency assuming constant change in 
%   entropy and constant pressureratio. 
%   Arguments: If p1 is a single pressure this is used as starting point for 
%   the compression. MYETA will then return a function.
%   If p1 is a vector of 2 elements, the function will calculate the
%   isentropic efficiency for the compression up to the second pressure.
%   If p1 contains more than 2 elements the function will evaluate the
%   eta-function for alle pressure ratios including 1.
    if nargin<5
        N = 2;
    end
    if ~isa(R,'Fluid')
        R = Fluid(R);
    end
    if p1(1)>R.get('ptriple') && p1(1)<R.get('pcrit')
        R1 = R.set('P',p1(1),'Q',1.0);
    elseif p1(1)>=R.get('pcrit')
        R1 = R.set('P',p1(1),'T',R.get('Tcrit')+1);
    else
        R1 = R.set('P',p1(1),'T',R.get('Ttriple')+1);
    end
    
    R2s = R1.change('P',@(p) p*pr_base,'S');
    R2  = R1.change('P',@(p) p*pr_base,'H',R1.get('H')+(R2s.get('H')-R1.get('H'))/eta_base);
    
    dpr = pr_base^(1/N);
    ds = (R2.get('S')-R1.get('S'))/N;
    s = R1.get('S') + ds*(1:N);
    p = R1.get('P')*dpr.^(1:N);
    h = R1.calculate('H','P',p,'S',s);
        
    h2s = R1.calculate('H','P',p,'S');
    eta = (h2s-R1.get('H'))./(h-R1.get('H'));
    Pr = p/p1(1);
    
    a = mean(diff(eta)./diff(log10(Pr)));
    b = eta_base-a*log10(pr_base);
    if length(p1)==1
        eta = @(PressureRatio) a*log10(PressureRatio)+b;
    elseif length(p1)==2
        eta = a*log10(p1(2)/p1(1))+b;
    else
        eta = a*log10(p1(1:end)/p1(1))+b;
    end
    
end

