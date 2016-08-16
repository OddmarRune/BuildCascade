classdef Fluid < handle
    
    properties
        Name
        H
        P
        T
        Q
        S
        % D
        Phase
        Defined
        DefList
        Tcrit
        pcrit
        Ttriple
        ptriple
    end
    
    methods
        function obj = Fluid(name,A,a,B,b)
            obj.Name = name;
            if nargin == 5
                obj.(A) = a;
                obj.(B) = b;
                obj.Defined = true;
                obj.DefList = {A,B};
            elseif nargin == 3
                obj.(A) = a;
                obj.Defined  = false;
                obj.DefList = {A};
            else
                obj.Defined = false;
            end
        end
        %         function obj = set(obj,A,a,B,b)
        %             if nargin == 5
        %                 obj.(A) = a;
        %                 obj.(B) = b;
        %                 obj.DefList = {A,B};
        %                 obj.Defined = true;
        %             elseif nargin == 3
        %                 obj.(A) = a;
        %                 found = 0;
        %                 for i = 1:length(obj.DefList)
        %                     if strcmp(A,obj.DefList{i})
        %                         if found == 0
        %                             found = i;
        %                         else
        %                             error('This is wrong');
        %                         end
        %                     end
        %                 end
        %                 if found > 0
        %                     if obj.Defined
        %                         obj = obj.change(A,a,obj.DefList{3-found});
        %                     else
        %                         obj.(A) = a;
        %                     end
        %                 elseif obj.Defined
        %                     error('Too much information')
        %                 else
        %                     obj.DefList{length(obj.DefList)+1} = A;
        %                     obj.(A) = a;
        %                     if length(obj.DefList) == 2
        %                         obj.Defined = true;
        %                     end
        %                 end
        %             end
        %         end
        function obj2 = set(obj,A,a,B,b)
            obj2 = Fluid(obj.Name);
            if nargin == 5
                obj2.(A) = a;
                obj2.(B) = b;
                obj2.DefList = {A,B};
                obj2.Defined = true;
            elseif nargin == 3
                obj2.(A) = a;
                found = 0;
                for i = 1:length(obj.DefList)
                    if strcmp(A,obj.DefList{i})
                        if found == 0
                            found = i;
                        else
                            error('This is wrong');
                        end
                    end
                end
                if found > 0
                    if obj.Defined
                        obj2 = obj.change(A,a,obj.DefList{3-found});
                    else
                        obj2.(A) = a;
                    end
                elseif obj.Defined
                    error('Too much information')
                else
                    obj2.DefList{length(obj.DefList)+1} = A;
                    obj2.(A) = a;
                    if length(obj2.DefList) == 2
                        obj2.Defined = true;
                    end
                end
            end
        end
        function a = get(obj,A)
            if nargin<2
                list = properties(obj);
                for i = 1:length(list)
                    obj.get(list{i});
                end
                a = obj;
                return
            end
            if ~isempty(obj.(A))
                a = obj.(A);
            elseif obj.Defined        
                try
                    obj.(A) = CoolProp.PropsSI(A,obj.DefList{1},obj.(obj.DefList{1}),obj.DefList{2},obj.(obj.DefList{2}),obj.Name);                    
                    a = obj.(A);
                catch
                    obj.(A) = nan;
                    a = nan;
                    % obj.Defined = false;
                end
            elseif strcmp(A,'Tcrit') || strcmp(A,'pcrit') || strcmp(A,'Ttriple') || strcmp(A,'ptriple')
                obj.(A) = CoolProp.Props1SI(obj.Name,A);
                a = obj.(A);
            else
                a = nan;
            end
        end
        function cVec = calculate(obj,C,A,aVec,B,bVec)
            cVec = zeros(size(aVec));
            
            if nargin<6
                for i = 1:length(aVec(:))
                    obj2 = obj.change(A,aVec(i),B);
                    cVec(i) = obj2.get(C);
                end
            else
                if length(bVec) == 1
                    for i = 1:length(aVec(:))
                        obj2 = obj.change(A,aVec(i),B,bVec);
                        cVec(i) = obj2.get(C);
                    end
                else
                    for i = 1:length(aVec(:))
                        obj2 = obj.change(A,aVec(i),B,bVec(i));
                        cVec(i) = obj2.get(C);
                    end
                end
            end
        end
        function s = getPhase(obj)
            if ~isempty(obj.Phase)
                s = obj.Phase;
            else
                if obj.Defined
                    obj.Phase = CoolProp.PhaseSI(obj.DefList{1},obj.(obj.DefList{1}),obj.DefList{2},obj.(obj.DefList{2}),obj.Name);
                    s = obj.Phase;
                else
                    s = 'Undefined';
                end
            end
        end
        function obj2 = change(obj,A,a,B,b)
            if nargin==4
                if isempty(obj.(B))
                    if obj.Defined
                        b = obj.get(B);
                    end
                else
                    b = obj.(B);
                    
                end
            end
            % obj2 = Fluid(obj.Name);
            if isa(a,'function_handle')
                a2 = a(obj.get(A));
            else
                a2 = a;
            end
            if isa(b,'function_handle')
                b2 = b(obj.get(B));
            else
                b2 = b;
            end
            obj2 = Fluid(obj.Name,A,a2,B,b2);
        end
    end
    
end

