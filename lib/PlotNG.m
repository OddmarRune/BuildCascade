function [ ] = PlotNG( )
    load('NG_data')
    %hwindow = [min(hh(:)),max(hh(:))];
    pwindow = [min(pp(:)),max(pp(:))];
    twindow = [min(TT(:)),max(TT(:))]-273.15;
    tstart = ceil(twindow(1)/10)*10;    
    p = linspace(pwindow(1),pwindow(2));
    
    h = h_NG(p,tstart+273.15);
    semilogy(h/1e3,p/1e5,'--r'), hold on, grid on
    for t = (tstart+10):10:twindow(2)
        h = h_NG(p,t+273.15);
        plot(h/1e3,p/1e5,'--r')
    end
    hold off    
    xlabel('Enthalpy [kJ/kg]')
    ylabel('Pressure [bar]')
    title('Natural Gas')
end

