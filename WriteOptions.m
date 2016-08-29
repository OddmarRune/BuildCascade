function [  ] = WriteOptions( Options, Filename )
    if exist(Filename,'file')
        backupFilename = sprintf('backup_%s_%s',datestr(now,'ddmmyyyy_HHMMss'),Filename);
        movefile(Filename,backupFilename)
    end        
    
    if isa(Options,'struct')                                
        tab = struct2table(Options);
        writetable(tab,Filename,'Delimiter','\t','QuoteStrings',false);
    else
        error('Wrong input');
    end  
end

