function [ ] = PlotNGnew( varargin )    
    load('NG_data')
    [N,~] = size(TT);
        
    Options = LazyOptions(varargin, ...
        'pwindow', [pmin,pmax],...        
        'twindow', [Tmin+5,Tmax-5]-273.15,...
        'hwindow', [hmin,hmax],...
        'TemperaturesC', -250:10:250,...
        'LabelStep', 50,...
        'N',N,...
        'spec','-',...
        'Hfunc',@h_NG,...
        'ShowText',{'on', 'off'},...
        'method',{'natural','nearest','linear','cubic'},...
        'pscale',{'linear','log'});                                        
    
    p = linspace(min(Options.pwindow),max(Options.pwindow),Options.N);
    t = linspace(min(Options.twindow)-5,max(Options.twindow)+5,Options.N);
    
    [P,T] = meshgrid(p,t);    
    H = Options.Hfunc(P,T+273.15);    
    
    hwindow = [max(min(H(:)),min(Options.hwindow)),min(max(H(:)),max(Options.hwindow))];       
    h = linspace(min(hwindow),max(hwindow),Options.N);   
    [hh,pp] = meshgrid(h,p);
    tt = griddata(H,P,T,hh,pp,Options.method);
    
    TempLabels = ceil(min(Options.TemperaturesC)/Options.LabelStep)*Options.LabelStep:Options.LabelStep:max(Options.TemperaturesC);    
    [Cc,hc] = contour(hh/1e3,pp/1e5,tt,Options.TemperaturesC,Options.spec);
    clabel(Cc,hc,TempLabels)    
            
    if CheckOption(Options,'ShowText','on')
        xlabel('Enthalpy [kJ/kg]')
        ylabel('Pressure [bar]')
        title('Natural Gas')
    end
    
    ax = gca;
    ax.YScale = Options.pscale;
            
end
