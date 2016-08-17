function [  ] = PlotPH( Gas, varargin )    
    assert(isa(Gas,'Mix'))
    
    ptriple  = Gas.ptriple;    
    Ttriple  = Gas.Ttriple;
    TQ0      = Gas.update('P',ptriple,'Q',0.0);
    TQ1      = Gas.update('P',ptriple,'Q',1.0);    
    hwindow  = [TQ0.H,TQ1.H+(TQ1.H-TQ0.H)*2];
    pwindow  = [ptriple, 1e7];
    
    Options = LazyOptions(varargin, ...
        'pwindow',      pwindow, ...
        'hwindow',      hwindow, ...
        'PhaseEnvelope',{'on','off'}, ...
        'Isotherms',    {'on','off'}, ...
        'Isentropics',  {'on','off'}, ...
        'GasQuality',   {'on','off'}, ...
        'UseCritical',  {'auto','on','off'}, ...
        'NoWarnings',   {'on','off'}, ...
        'TemperaturesC', -250:25:200);

    % CheckOption = @(opt,status) strcmpi(Options.(opt),status);
    
    if CheckOption(Options,'NoWarnings','on')
        orig_state = warning;
        warning('off','all');   
    end   
    
    if CheckOption(Options,'UseCritical','auto')
        if ~Gas.Fallback
            if ~isnan(Gas.Tcrit)
                Options.UseCritical = 'on';
            else
                Options.UseCritical = 'off';
            end
        else
            Options.UseCritical = 'off';
        end    
    end
    
    % Must redefine CheckOptions-function
    % CheckOption = @(opt,status) strcmpi(Options.(opt),status);
    
    clf
    hold on
    ax = gca;
    ax.YScale = 'log';
    
    pwindow = [min(Options.pwindow), max(Options.pwindow)];
    hwindow = [min(Options.hwindow), max(Options.hwindow)];
   
    if CheckOption(Options,'Isotherms','on') || ...
            CheckOption(Options,'Isentropics','on') || ...
            CheckOption(Options,'PhaseEnvelope','on') || ...
            CheckOption(Options,'GasQuality','on')
                
        pp = logspace(log10(pwindow(1)),log10(pwindow(2)),100);
        hh = linspace(hwindow(1),hwindow(2),100);
        
        [PP,HH] = meshgrid(pp,hh);
        
        %if ~isnan(Gas.change('P',pwindow(1),'H',hwindow(1)).T)
            GridData = Gas.change('P',PP,'H',HH);
        %else
            
        %    tt = linspace(kelvin(-200),kelvin(200),100);
        %    [Pt,Tt] = meshgrid(pp,tt);
        %    GridDataT = Gas.change('P',Pt,'T',Tt);
        %    HH = contour
    end
    
    if CheckOption(Options,'Isotherms','on')                        
        contour(HH/1e3,PP/1e5,celsius(GridData.T),Options.TemperaturesC,'--',...
            'ShowText','on','TextList',Options.TemperaturesC,'LabelSpacing',400)        
    end 
    
    if CheckOption(Options,'PhaseEnvelope','on')
        
        if CheckOption(Options,'UseCritical','on')
                
            crit = Gas.update('P',Gas.pcrit,'T',Gas.Tcrit);
            
            pVec = logspace(log10(ptriple),log10(crit.P),101);
            Vec0 = Gas.change('P',pVec,'Q',0.0);
            Vec1 = Gas.change('P',pVec,'Q',1.0);
            
            p1 = linspace(pVec(end-1),Gas.pcrit,12);
            p1 = p1(2:end-1);
            
            %p1 = (pVec(end-1)+Gas.pcrit)/2;
            h0 = Gas.change('P',p1,'Q',0).H;
            h1 = Gas.change('P',p1,'Q',1).H;
            
            pVec = [ pVec(1:end-1)   [p1 Gas.pcrit p1(end:-1:1)] pVec(end-1:-1:1)];
            hVec = [ Vec0.H(1:end-1) [h0 crit.H    h1(end:-1:1)] Vec1.H(end-1:-1:1)];
                        
            plot(hVec/1e3,pVec/1e5,'LineWidth',2)  
        else
            pVec = logspace(log10(ptriple),log10(pwindow(2)),101);
            Vec0 = Gas.change('P',pVec,'Q',0.0);
            Vec1 = Gas.change('P',pVec,'Q',1.0);
            
            hlimHi = 2*TQ1.H-TQ0.H;
            hlimLo = TQ0.H-1e3;
            list0 = ~isnan(Vec0.H) & (Vec0.H<hlimHi) & (Vec0.H>hlimLo);
            list1 = ~isnan(Vec1.H) & (Vec1.H<hlimHi) & (Vec1.H>hlimLo);
            
            n = min(find(list0==0,1,'first'),find(list1==0,1,'first'));
            
            if ~isempty(n)
                cutoffp = pVec(n);    
            else
                cutoffp = inf;
            end                                    
            
            list = pVec<cutoffp;
            pVec0 = pVec(list);
            pVec1 = pVec(list);
            hVec0 = Vec0.H(list);
            hVec1 = Vec1.H(list);
            
            %pVec0 = pVec(list0);
            %pVec1 = pVec(list1);
            %hVec0 = Vec0.H(list0);
            %hVec1 = Vec1.H(list1);
            
            if (hVec1(end)-hVec0(end))>100e3
                mid = nan;
            else
                mid = [];
            end
            
            pVec = [ pVec0 mid pVec1(end:-1:1)];
            hVec = [ hVec0 mid hVec1(end:-1:1)];
            plot(hVec/1e3,pVec/1e5,'LineWidth',2)
        end
        
        
    end
    
    if CheckOption(Options,'GasQuality','on')
    
        %if CheckOption(Options,'UseCritical','on')
%            contour(HH/1e3,PP/1e5,GridData.Q,0.1:0.1:0.9,'--','ShowText','on','TextList',[0.2,0.5,0.8],'LabelSpacing',500)
       %      pcrit = Gas.pcrit;
       %      pVec = logspace(log10(ptriple),log10(pcrit),101);
       %      for q = 0.1:0.1:0.9
       %          Vec = Gas.change('P',pVec,'Q',q);            
       %          plot(Vec.H/1e3,pVec/1e5,'-k');
       %      end
       % else
            Q = GridData.Q;
            qq = (Q<1) & (Q>0);
            Q(~qq) = nan;
            contour(HH/1e3,PP/1e5,Q,0.1:0.1:0.9,'-k')
       % end
        
    end          
    
    if CheckOption(Options,'Isentropics','on')        
        contour(HH/1e3,PP/1e5,GridData.S,':k')        
    end
    
    hold off
    grid on
    
    ax.XLim = hwindow/1e3;
    ax.YLim = pwindow/1e5;
    ax.Box = 'on';
    
    if CheckOption(Options,'Isotherms','on')
        caxis([min(Options.TemperaturesC) max(Options.TemperaturesC)]);
    end
    
    xlabel('Enthalpy [kJ/kg]')
    ylabel('Pressure [bar]')
    title(Gas.Name)        
    
    
    
    if CheckOption(Options,'NoWarnings','on')
        warning(orig_state);
    end
end

