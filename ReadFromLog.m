function [ TemperatureSetup ] = ReadFromLog( Options, MyCascade, AmbientTemperature, Filename )
    if ischar(Filename)
        fid = fopen(Filename,'r');
    else
        error('Wrong Input')
    end
    
    Hash = DataHash(StripOptions(Options));
    
    TemperatureSetup = {};
    
    Refrigerants = fields(MyCascade);
    A = zeros(1,length(Refrigerants));
    for i = 1:length(Refrigerants)
        A(i) = min(MyCascade.(Refrigerants{i}));
    end
    [~,a] = sort(A,'Descend');    
    refstring = '';
    for i = 1:length(Refrigerants)
        refstring = sprintf('%s %s',refstring,Refrigerants{a(i)});
    end
    
    v = [];
    for i = 1:length(Refrigerants)
        v(i) = length(MyCascade.(Refrigerants{a(i)}));
    end
    
    c = 0;
    
    while ~feof(fid)
        tline = fgetl(fid);
        C = textscan(tline,'%s','Delimiter',',');
        if strcmpi(Hash,strtrim(C{1}{1}))
            if strcmpi(strtrim(refstring),strtrim(C{1}{3}))
                w = cell2mat(textscan(C{1}{4},'%f','Delimiter',' '));
                if (v(:) == w(:))
                    if AmbientTemperature == str2double(C{1}{2})
                        c = c+1;
                        tvec = str2num(C{1}{5});
                        W = cumsum(w);
                        TemperatureSetup{c} = {tvec(1:W(1)),tvec((W(1)+1):(W(2))),tvec((W(2)+1):W(3))};
                    end
                end
            end
        end
    end
    
    fclose(fid);
end

