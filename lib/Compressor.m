function [ CompressedState, Eta ] = Compressor( Gas, InitialState, FinalPressure, varargin )
    Options = LazyOptions(varargin,...
        'pr_base',  3,...
        'eta_base', 0.85);
    
    if nargin<1 || (isa(Gas,'char') && strcmpi(Gas,'DisplayName'))
        CompressedState = sprintf('VarEta%g_%g',Options.pr_base,Options.eta_base);
        return
    end
    assert(isa(Gas,'Mix'),'Wrong input type: Gas should be object of class Mix.') 
   
    % Helping Function
    h2      = @(h2s,eta) (@(h1) h1+(h2s-h1)/eta);
    
    pr_base  = Options.pr_base;
    eta_base = Options.eta_base;
    
    P1 = InitialState;
    
    PressureRatio = (FinalPressure/InitialState.P);
       
    % Step one: First Compressor with pressureratio pr_base and
    %           Isentropic Efficiency eta_base
    P2s = Gas.change('P',@(p) p*pr_base,'S',@(s) s,             P1);
    P2  = Gas.change('P',@(p) p*pr_base,'H',h2(P2s.H,eta_base), P1);
    
    % Step two: Second Compressor with pressureratio pr_base and
    %           Isentropic Efficiency eta_base
    P3s = Gas.change('P',@(p) p*pr_base,'S',@(s) s,             P2);
    P3  = Gas.change('P',@(p) p*pr_base,'H',h2(P3s.H,eta_base), P2);
    
    % Combined step: Calculating Isentropic Efficiency for the combined
    %                Compressor.
    P3s2 = Gas.change('P',@(p) p*pr_base^2,'S', @(s) s,         P1);
    
    eta2 = (P3s2.H-P1.H)./(P3.H-P1.H); % Combined Isentropic Efficiency
    eta1 = eta_base;
    
    % Finding parameters for Mathematical model.
    a = (eta2-eta1)./log10(pr_base);
    b = eta_base-a*log10(pr_base);

    % Mathematical model:
    Eta = a*log10(PressureRatio)+b; % Estimated Isentropic Efficiency
    
    HelpingState    = Gas.change('P',@(p) p*PressureRatio,...
                                 'S',@(s) s,...
                                 InitialState);
                             
    CompressedState = Gas.change('P',@(p) p*PressureRatio,...
                                 'H',h2(HelpingState.H,Eta),...
                                 InitialState);
    
end

