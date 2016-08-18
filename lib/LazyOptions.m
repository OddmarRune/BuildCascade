function [ options ] = LazyOptions( input, varargin )
    p = inputParser;
    if length(varargin)==1
        list = fields(varargin{1});
        for k = 1:length(list)
            if iscell(varargin{1}.(list{k})) 
                p.addParameter(list{k},varargin{1}.(list{k}){1}, @(s) strcmp(s,validatestring(s,varargin{1}.(list{k}))));
            else
                p.addParameter(list{k},varargin{1}.(list{k}));
            end
        end
    else
        for k = 1:floor(length(varargin)/2)
            if iscell(varargin{2*k})                
                p.addParameter(varargin{2*k-1},varargin{2*k}{1}, @(s) strcmp(s,validatestring(s,varargin{2*k})));
            else
                p.addParameter(varargin{2*k-1},varargin{2*k});
            end
        end
        if mod(length(varargin),2)
            error('Missing default value for parameter: %s',varargin{end})
        end
    end    
    
    if isa(input,'struct')
        disp('test')
        list = fields(input);
        Input = {};
        for k = 1:length(list)
            Input = [ Input, list{k}, input.(list{k})];            
        end                
    else
        % Assume input is a cell array        
        Input = input;
    end    
    p.parse(Input{:});
    options = p.Results;
end

