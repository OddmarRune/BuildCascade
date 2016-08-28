function [  ] = Make_NG_data( pfile, Tfile, hfile, outfilename )   
    if nargin<4
        outfilename = 'NG_data';
    end
    
    if ~exist(Tfile,'file')
        error('T-file not existing')
    end
    if ~exist(pfile,'file')
        error('p-file not existing')
    end
    if ~exist(hfile,'file')
        error('h-file not existing')
    end    

    T = table2array(readtable(Tfile))+273.15;
    p = table2array(readtable(pfile));
    hh = table2array(readtable(hfile));

    hh(abs(hh)>1e6) = nan;

    [pp,TT] = meshgrid(p,T);    

    hmin = min(hh(:));
    hmax = max(hh(:));
    pmin = min(pp(:));
    pmax = max(pp(:));
    Tmin = min(TT(:));
    Tmax = max(TT(:));
    
    if exist(outfilename,'file')
        fprintf('This will overwrite %s.\n',outfilename)
        confirm = input('Y/N [N]');
        if isempty(confirm) || ~strcmpi(confirm,'y')
            confirm = 'N';
        end
    else
        confirm = 'Y';
    end
    
    if strcmpi(confirm,'y')
        save('NG_data','pp','TT','hh','hmin','hmax','pmin','pmax','Tmin','Tmax')
    else
        disp('Output not saved!')
    end

end

