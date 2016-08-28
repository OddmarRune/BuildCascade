function [ Options, MyCascade, AmbientTemperature, Setup ] = ReadSetup(  Filename )
    if nargin<1
        error('Filename missing.');
    elseif ~ischar(Filename)
        error('Wrong input.');
    end
        
    fid = fopen(Filename,'r');
    
    tline = fgetl(fid);
    
    
    while ~feof(fid)
        while ~feof(fid) && isempty(tline) 
            tline = fgetl(fid);
        end
        
        if ~feof(fid) && ~isempty(strfind(tline,'# Options'))
            Options = struct;
            tline = fgetl(fid);
            while ~feof(fid) && ~isempty(tline)
                C = textscan(tline,'%s','Delimiter',':');
                if strcmpi(strtrim(C{1}{1}),'Compressor')
                    Options.(strtrim(C{1}{1})) = str2func(C{1}{2});
                else
                    number = str2num(C{1}{2});
                    if isempty(number)
                        Options.(strtrim(C{1}{1})) = C{1}{2};
                    else
                        Options.(strtrim(C{1}{1})) = number;
                    end
                end
                tline = fgetl(fid);
            end
        end
        
        if ~feof(fid) && ~isempty(strfind(tline,'# Setup'))
            Setup = struct;
            tline = fgetl(fid);
            while ~feof(fid) && ~isempty(tline)
                C = textscan(tline,'%s','Delimiter',':');
                if strcmpi(strtrim(C{1}{1}),'AmbientTemperature')
                    Setup.AmbientTemperature = str2num(C{1}{2});
                end
                if strcmpi(strtrim(C{1}{1}),'Refrigerants')
                    R = textscan(C{1}{2},'%s');
                    Setup.Refrigerants = R{1};
                end
                if strcmpi(strtrim(C{1}{1}),'ExchangerSetup')
                    Setup.ExchangerSetup = str2num(C{1}{2});
                end
                tline = fgetl(fid);
            end
        end
        
        if ~feof(fid) && ~isempty(strfind(tline,'# Cascade'))
            MyCascade = struct;
            tline = fgetl(fid);
            while ~feof(fid) && ~isempty(tline)
                C = textscan(tline,'%s','Delimiter',':');
                R = strtrim(C{1}{1});
                T = cell2mat(textscan(C{1}{2},'%f'));
                T = (T(:))';
                MyCascade.(R) = T;
                tline = fgetl(fid);
            end
        end
    
    end
    
    if isstruct(Setup) && isfield(Setup,'AmbientTemperature')
        AmbientTemperature = Setup.AmbientTemperature;
    else
        AmbientTemperature = nan;
    end
    
    fclose(fid);
end

