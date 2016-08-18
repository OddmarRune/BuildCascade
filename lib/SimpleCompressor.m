function [ CompressedState, Eta ] = SimpleCompressor( Gas, InitialState, FinalPressure, varargin )    
    Options = LazyOptions(varargin,...        
        'eta', 0.85);    
    if (nargin<1) || (isa(Gas,'char') && strcmpi(Gas,'DisplayName'))
        CompressedState = sprintf('ConstantEta%g',Options.eta);
        return
    end
    assert(isa(Gas,'Mix'),'Wrong input type: Gas should be object of class Mix.') 
    
    h2  = @(h2s,eta) (@(h1) h1+(h2s-h1)/eta); % Helping Function
    Eta = Options.eta;         
    HelpingState    = Gas.change('P',FinalPressure,'S',@(s) s,InitialState);
    CompressedState = Gas.change('P',FinalPressure,'H',h2(HelpingState.H,Eta), InitialState);
end

