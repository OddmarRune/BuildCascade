function [  ] = MySavePlot( filename, width, removetitle )
    if nargin<2
        width = -2;
    end
    if nargin<3
        removetitle = true;
    end      
    switch width
        case -1
            width = 7.38;
        case -2
            width  = 16;        
    end    
    if removetitle
        mytitle = get(gca,'Title');
        mytitle = mytitle.String;     
        title('')
    end
    exportfig(filename,...
        'Resolution', 600,      ...
        'Width',      width,    ...
        'Color',      'rgb',    ...
        'FontMode',   'Scaled', ...
        'FontSize',   1)
    if removetitle
        title(mytitle)
    end
end

