function [  ] = AppendToLog( Options, MyCascade, AmbientTemperature, Filename )
    if nargin<4
        fid = 1;
    elseif ischar(Filename)
        fid = fopen(Filename,'a');
    else
        fid = 1;
    end
       
    Hash = DataHash(StripOptions(Options));
    
    fprintf(fid,'%s,',Hash);
    fprintf(fid,' %d,',AmbientTemperature);
    
    Refrigerants = fields(MyCascade);
    A = zeros(1,length(Refrigerants));
    for i = 1:length(Refrigerants)
        A(i) = min(MyCascade.(Refrigerants{i}));
    end
    [~,a] = sort(A,'Descend');    
    for i = 1:length(Refrigerants)
        fprintf(fid,' %s',Refrigerants{a(i)});
    end
    fprintf(fid,',');
    for i = 1:length(Refrigerants)
        fprintf(fid,' %d',length(MyCascade.(Refrigerants{a(i)})));
    end
    fprintf(fid,',');
    
    for i = 1:length(Refrigerants)
        fprintf(fid,' %g',MyCascade.(Refrigerants{a(i)}));
    end
    fprintf(fid,'\n');
    if fid ~= 1
        fclose(fid);
    end
end