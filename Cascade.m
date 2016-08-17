function [ output ] = Cascade( AmbientTemperature, Temperatures, Refrigerants, varargin)

    Options = LazyOptions(varargin, DefaultOptions);

    if nargin < 3; Refrigerants = {'R290', 'R1150', 'R50'}; end
    if nargin < 2; Temperatures = { -40, -102, -160 }; end
    if nargin < 1; AmbientTemperature = 12; end
    
    N  = length(Refrigerants);   
    for i = 1:N
        if ~isa(Refrigerants{i},'Mix')
            Refrigerants{i} = Mix(Refrigerants{i});
        end
    end
    
    if ~iscell(Temperatures)
        if length(Temperatures) == N
            t = cell(1,N);
            for i = 1:N
                t{i} = Temperatures(i);
            end
            Temperatures = t;
            clear t;
        else
            error('Wrong input: Temperatures')
        end
    else
        if length(Temperatures) ~= N
            error('Wrong input: length(Temperatures) ~= length(Refrigerants)')
        end
    end
        
    MinTemp = zeros(1,N);
    
    for i = 1:N
        Temperatures{i} = sort(Temperatures{i});
        MinTemp(i) = Temperatures{i}(1);
    end
    [~,Order] = sort(MinTemp,'Descend');
    
    ExternalTemperatures = AmbientTemperature;
    Circuits = {};
        
    for i = 1:N
        n = Order(i);
        
        Output{n} = CoolingProcessWithInternal(ExternalTemperatures,Temperatures{n},Refrigerants{n},Options);
        ExternalTemperatures = [ExternalTemperatures, Output{n}.Temperatures];        
        Circuits = [Circuits, Output{n}.Circuits];
        
    end
    
    output.Temperatures   = ExternalTemperatures;
    output.Circuits       = Circuits;
    output.Options        = Options;
end

