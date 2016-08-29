function [  ] = WriteSetup( Options, MyCascade, AmbientTemperature, Filename )
    if nargin<4
        fid = 1;
    elseif ischar(Filename)
        fid = fopen(Filename,'w');
    else
        fid = 1;
    end
    
    fprintf(fid,'# Options\n');
    OptionList = fields(Options);
    for i = 1:length(OptionList)
        fprintf(fid,'%30s : ',OptionList{i});
        if ischar(Options.(OptionList{i}))
            fprintf(fid,'%s\n',Options.(OptionList{i}));
        elseif isnumeric(Options.(OptionList{i}))            
            fprintf(fid,'%g ',Options.(OptionList{i}));
            fprintf(fid,'\n');
        elseif isa(Options.(OptionList{i}),'function_handle') 
            fprintf(fid,'%s\n',func2str(Options.(OptionList{i})));
        else
            fprintf(fid,'\n');
        end
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'# Setup\n');
    if nargin>=3
        fprintf(fid,'%30s : %g\n','AmbientTemperature',AmbientTemperature);
    end
    
    Refrigerants = fields(MyCascade);
    A = zeros(1,length(Refrigerants));
    for i = 1:length(Refrigerants)
        A(i) = min(MyCascade.(Refrigerants{i}));
    end
    [~,a] = sort(A,'Descend');
    
    fprintf(fid,'%30s :','Refrigerants');
    for i = 1:length(Refrigerants)
        fprintf(fid,' %8s',Refrigerants{a(i)});
    end
    fprintf(fid,'\n');
    
    fprintf(fid,'%30s :','ExchangerSetup');
    for i = 1:length(Refrigerants)
        fprintf(fid,' %8d',length(MyCascade.(Refrigerants{a(i)})));        
    end
    fprintf(fid,'\n\n');
    
    fprintf(fid,'# Cascade\n');
    
    for i = 1:length(Refrigerants)
        fprintf(fid,'%10s : ',Refrigerants{i});
        fprintf(fid,'%g ',MyCascade.(Refrigerants{i}));
        fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
    if fid ~= 1
        fclose(fid);
    end
end

