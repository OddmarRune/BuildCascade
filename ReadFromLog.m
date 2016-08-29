function [ TemperatureSetup ] = ReadFromLog( Options, MyCascade, AmbientTemperature, Filename, varargin )
    Settings = LazyOptions(varargin,...
        'AmbientTemperatureMatch',{'Equal','Approx','HigherOrEqual','none'},...
        'ExchangerSetupMatch',{'Equal','SameNumber','none'},...
        'OptionMatch',{'Equal','none'},...
        'RefrigerantMatch',{'Equal'});
        
    if ischar(Filename)
        fid = fopen(Filename,'r');
    else
        error('Wrong Input')
    end
    
    Hash = DataHash(StripOptions(Options));
    
    TemperatureSetup = {};
    
    if fid<0
        return
    end
    
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
        
        match = true;
        
        if CheckOption(Settings,'OptionMatch','Equal')
            match = match && strcmpi(Hash,strtrim(C{1}{1}));
        end
        
        if CheckOption(Settings,'RefrigerantMatch','Equal')
            match = match && strcmpi(strtrim(refstring),strtrim(C{1}{3}));
        end
        
        w = cell2mat(textscan(C{1}{4},'%f','Delimiter',' '));
        
        if CheckOption(Settings,'ExchangerSetupMatch','Equal')
            match = match && isequal(v(:),w(:));
        elseif CheckOption(Settings,'ExchangerSetupMatch','SameNumber')
            match = match && (sum(v) == sum(w));
        end
        
        if CheckOption(Settings,'AmbientTemperatureMatch','Equal')
            match = match && (AmbientTemperature == str2double(C{1}{2}));
        elseif CheckOption(Settings,'AmbientTemperatureMatch','Approx')
            match = match && abs(AmbientTemperature-str2double(C{1}{2}))<5;
        elseif CheckOption(Settings,'AmbientTemperatureMatch','HigherOrEqual')
            match = match && (AmbientTemperature>=str2double(C{1}{2}));
        end
        
        if match
            c = c+1;
            tvec = str2num(C{1}{5});
            W = cumsum(w);
            TemperatureSetup{c} = {tvec(1:W(1)),tvec((W(1)+1):(W(2))),tvec((W(2)+1):W(3))};
        end
    end
    
    fclose(fid);
end

