classdef NaturalGas < handle
 
    properties
        Name
        P
        H
        T
    end
    
    methods
        
        function obj = NaturalGas (name)
            if nargin < 1
                obj.Name = 'NaturalGas';
            else
                obj.Name = name;
            end
        end
        
        function output = update(obj,A,a,B,b)
            if A<B
                if A == 'P' && B == 'T'
                    obj.P = a;
                    obj.T = b;
                    obj.H = h_NG(a,b);
                else
                    error('Not Implemented!')
                end
            else
                if B == 'P' && A == 'T'
                    obj.P = b;
                    onj.T = a;
                    obj.H = h_NG(b,a);
                else
                    error('Not Implemented!')
                end
            end
            output.P = obj.P;
            output.H = obj.H;
            output.T = obj.T;
        end
        
        function output = change(obj,A,a,B,b,InitialState)
            if nargin<6
                InitialState.P = obj.P;
                InitialState.H = obj.H;
                InitialState.T = obj.T;
            end
            
            if isnumeric(a)
                if length(a) == 1
                    if isnumeric(b)
                        if length(b) == 1
                            output = obj.update(A,a,B,b);
                        else
                            output.H = zeros(size(b));
                            output.P = zeros(size(b));
                            output.T = zeros(size(b));
                            for i = 1:length(b(:))
                                out = obj.update(A,a,B,b(i));
                                output.H(i) = out.H;
                                output.P(i) = out.P;
                                output.T(i) = out.T;
                            end
                        end
                    else
                        if isa(b,'function_handle')
                            output = obj.update(A,a,B,b(InitialState.(B)));
                        else
                            error('Unknown input')
                        end                        
                    end
                else
                    if isnumeric(b)
                        if length(b) == 1
                            output.H = zeros(size(a)); 
                            output.P = zeros(size(a));
                            output.T = zeros(size(a));    
                            for i = 1:length(a(:))
                                out = obj.update(A,a(i),B,b);
                                output.H(i) = out.H;
                                output.P(i) = out.P;
                                output.T(i) = out.T;                                
                            end                            
                        else
                            if isequal(size(a), size(b)) || ...
                                    (isvector(a) && isvector(b) && numel(a) == numel(b))
                                output.H = zeros(size(a)); 
                                output.P = zeros(size(a));
                                output.T = zeros(size(a));    
                                for i = 1:length(a(:))                           
                                    out = obj.update(A,a(i),B,b(i));
                                    output.H(i) = out.H;
                                    output.P(i) = out.P;
                                    output.T(i) = out.T; 
                                end
                            else
                                error('Wrong input sizes')
                            end
                        end
                    else
                        error('Input not allowed: a is an array, b is not numeric')                        
                    end
                end
            else                           
                %%% a is not numeric
                if isa(a,'function_handle')
                    if isnumeric(b)
                        if length(b) == 1
                            output = obj.update(A,a(InitialState.(A)),B,b);
                        else
                            output.H = zeros(size(a));
                            output.P = zeros(size(a));
                            output.T = zeros(size(a));
                            for i = 1:length(b(:))
                                out = obj.update(A,a(InitialState.(A)),B,b(i));
                                output.H(i) = out.H;
                                output.P(i) = out.P;
                                output.T(i) = out.T; 
                            end
                        end
                    else
                        if isa(b,'function_handle')
                            output = obj.update(A,a(InitialState.(A)),B,b(InitialState.(B)));
                        else
                            error('Unknown input')
                        end                        
                    end                    
                else
                    error('Unknown input')
                end
            end
        end
    end
end

