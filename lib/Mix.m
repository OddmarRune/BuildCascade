classdef Mix < handle    
    properties
        Name
        Gases
        Fractions
        HEOS
        UnableToCompute
        Fallback
    end
    
    methods
        
        function obj = Mix(name,gases,fractions)
            obj.Name = name;        
            obj.Fallback = false;
            if nargin == 3                        
                if length(gases)~=length(fractions)
                    error('Wrong input!')            
                end
                obj.Gases = sprintf('%s%s',gases{1},sprintf('&%s',gases{2:end}));
                obj.Fractions = CoolProp.DoubleVector();
                for i = 1:length(fractions)
                    obj.Fractions.push_back(fractions(i));
                end
                obj.HEOS = CoolProp.AbstractState.factory('HEOS',obj.Gases);
                obj.HEOS.set_mole_fractions(obj.Fractions);
                obj.HEOS.build_phase_envelope('dummy')     
                obj.Fallback = true;
            elseif nargin == 2
                obj.Gases = gases;                
                obj.Fractions = 1.0;
                obj.HEOS = CoolProp.AbstractState.factory('HEOS',obj.Gases);
            elseif nargin == 1
                gases = name;
                obj.Gases = gases;                
                obj.Fractions = 1.0;
                obj.HEOS = CoolProp.AbstractState.factory('HEOS',obj.Gases);            
            end
            try
                obj.UnableToCompute = false;
                obj.update('P',obj.ptriple*10,'Q',1.0);
            catch
                obj.UnableToCompute = true;
            end
                
        end
        
        function T = Ttriple(obj)
            T = obj.HEOS.Ttriple();            
        end   
        
        function p = ptriple(obj)
            p = obj.HEOS.p_triple();            
        end
        
        function T = Tcrit(obj)
            T = obj.HEOS.T_critical();
        end
        
        function p = pcrit(obj)
            p = obj.HEOS.p_critical();
        end
        
        function output = update(obj,A,a,B,b)
            if sum(A=='DHSU')>0
                inputA = sprintf('%smass',A);
            else
                inputA = A;
            end
            if sum(B=='DHSU')>0
                inputB = sprintf('%smass',B);
            else
                inputB = B;
            end                        
            if A<B
                s = sprintf('%s%s_INPUTS',inputA,inputB);
                if ~obj.Fallback || strcmp(s,'PQ_INPUTS') || strcmp(s,'QT_INPUTS') || strcmp(s,'PT_INPUTS')
                    try
                        obj.UnableToCompute = false;
                        obj.HEOS.update(CoolProp.(sprintf('%s%s_INPUTS',inputA,inputB)),a,b);
                    catch ME
                        obj.UnableToCompute = true;
                        % rethrow(ME)
                    end
                else
                    if A=='Q' || B=='Q'
                        f = @(x) obj.PQsearch(A,a,B,b,x(1),x(2));
                        Out = obj.get_state;
                        if isnan(Out.P)
                            Out = obj.update('P',obj.ptriple*10,'Q',1.0);
                        end
                        fminsearch(f,[Out.P,Out.Q]);
                    else
                        f = @(x) obj.PTsearch(A,a,B,b,x(1),x(2));
                        Out = obj.get_state;
                        if isnan(Out.P)
                            Out = obj.update('P',obj.ptriple*10,'Q',1.0);
                        end
                        fminsearch(f,[Out.P,Out.T]);
                    end
                end
            else
                s = sprintf('%s%s_INPUTS',inputB,inputA);
                if ~obj.Fallback || strcmp(s,'PQ_INPUTS') || strcmp(s,'QT_INPUTS') || strcmp(s,'PT_INPUTS')
                    try
                        obj.UnableToCompute = false;
                        obj.HEOS.update(CoolProp.(sprintf('%s%s_INPUTS',inputB,inputA)),b,a);
                    catch ME
                        obj.UnableToCompute = true;
                        % rethrow(ME)
                    end
                else
                    if A=='Q' || B=='Q'
                        f = @(x) obj.PQsearch(A,a,B,b,x(1),x(2));
                        Out = obj.get_state;
                        if isnan(Out.P)
                            Out = obj.update('P',obj.ptriple*10,'Q',1.0);
                        end
                        fminsearch(f,[Out.P,Out.Q]);
                    else
                        Out = obj.get_state;
                        if isnan(Out.P)
                            Out = obj.update('P',obj.ptriple*10,'Q',1.0);
                        end
                        if A == 'P'
                            f = @(x) obj.PTsearch(A,a,B,b,a,x);
                            fminsearch(f,Out.T);
                        elseif B == 'P'
                            f = @(x) obj.PTsearch(A,a,B,b,b,x);
                            fminsearch(f,Out.T);
                        else                            
                            f = @(x) obj.PTsearch(A,a,B,b,x(1),x(2));
                            fminsearch(f,[Out.P,Out.T]);
                        end
                    end
                end
            end
            output = obj.get_state;
        end
        
        function output = change(obj,A,a,B,b,InitialState)
            if nargin<6
                InitialState = obj.get_state;
            end
            if isnumeric(a)
                if length(a) == 1
                    if isnumeric(b)
                        if length(b) == 1
                            output = obj.update(A,a,B,b);
                        else
                            output.H = zeros(size(b));
                            output.P = zeros(size(b));
                            output.Q = zeros(size(b));
                            output.S = zeros(size(b));
                            output.T = zeros(size(b));
                            output.U = zeros(size(b));
                            for i = 1:length(b(:))
                                out = obj.update(A,a,B,b(i));
                                output.H(i) = out.H;
                                output.P(i) = out.P;
                                output.Q(i) = out.Q;
                                output.S(i) = out.S;
                                output.T(i) = out.T;
                                output.U(i) = out.U;
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
                            output.Q = zeros(size(a));
                            output.S = zeros(size(a));
                            output.T = zeros(size(a));
                            output.U = zeros(size(a));    
                            for i = 1:length(a(:))
                                out = obj.update(A,a(i),B,b);
                                output.H(i) = out.H;
                                output.P(i) = out.P;
                                output.Q(i) = out.Q;
                                output.S(i) = out.S;
                                output.T(i) = out.T;
                                output.U(i) = out.U;                                
                            end                            
                        else
                            if isequal(size(a), size(b)) || ...
                                    (isvector(a) && isvector(b) && numel(a) == numel(b))
                                output.H = zeros(size(a)); 
                                output.P = zeros(size(a));
                                output.Q = zeros(size(a));
                                output.S = zeros(size(a));
                                output.T = zeros(size(a));
                                output.U = zeros(size(a));    
                                for i = 1:length(a(:))                           
                                    out = obj.update(A,a(i),B,b(i));
                                    output.H(i) = out.H;
                                    output.P(i) = out.P;
                                    output.Q(i) = out.Q;
                                    output.S(i) = out.S;
                                    output.T(i) = out.T;
                                    output.U(i) = out.U; 
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
                            output.Q = zeros(size(a));
                            output.S = zeros(size(a));
                            output.T = zeros(size(a));
                            output.U = zeros(size(a));
                            for i = 1:length(b(:))
                                out = obj.update(A,a(InitialState.(A)),B,b(i));
                                output.H(i) = out.H;
                                output.P(i) = out.P;
                                output.Q(i) = out.Q;
                                output.S(i) = out.S;
                                output.T(i) = out.T;
                                output.U(i) = out.U; 
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
        
        function output = get_state(obj)
            vars = {'H','P','Q','S','T','U'};
            for i = 1:length(vars)
                if ~obj.UnableToCompute
                    output.(vars{i}) = obj.HEOS.(varname(vars{i}));
                else
                    output.(vars{i}) = nan;
                end
            end
        end
        
        function output = MyPropsSI(obj,Y,A,a,B,b)
            output = obj.update(A,a,B,b).(Y);
        end        
        
        function y = PTsearch(obj,A,a,B,b,p,t)
            obj.UnableToCompute = false;
            try
                obj.HEOS.update(CoolProp.PT_INPUTS,p,t);
            catch
                obj.UnableToCompute = true;
            end
            Out = obj.get_state; 
            y = norm([Out.(A)-a,Out.(B)-b]);
        end

        function y = QTsearch(obj,A,a,B,b,q,t)
            obj.UnableToCompute = false;
            try
                obj.HEOS.update(CoolProp.QT_INPUTS,q,t);
            catch
                obj.UnableToCompute = true;                
            end
            Out = obj.get_state;
            y = norm([Out.(A)-a,Out.(B)-b]);
        end

        function y = QPsearch(obj,A,a,B,b,q,p)
            obj.UnableToCompute = false;
            try
                obj.HEOS.update(CoolProp.QP_INPUTS,q,p);
            catch
                obj.UnableToCompute = true;
            end
            Out = obj.get_state;
            y = norm([Out.(A)-a,Out.(B)-b]);
        end
        
        
    end    
end

function name = varname(A)
    switch A 
        case 'H'
            name = 'hmass';
        case 'P'
            name = 'p';
        case 'Q'
            name = 'Q';
        case 'S'
            name = 'smass';
        case 'T'
            name = 'T';
        case 'U'
            name = 'umass';
    end    
end

