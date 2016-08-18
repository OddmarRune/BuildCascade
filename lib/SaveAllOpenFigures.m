function [  ] = SaveAllOpenFigures( varargin ) 
    Options = LazyOptions(varargin,...
        'path', '.', ...
        'width', -2, ...
        'removetitle', {'on','off'}, ...
        'filename','');     

    handles = findall(0,'type','figure');
    removetitle = CheckOption(Options,'removetitle','on');

    if strcmp(Options.filename,'')
        filename = '';
    else
        filename = sprintf('%s_',Options.filename);
    end
    
    for i = 1:length(handles)
        name = sprintf('%s/%sfigure_%d.tiff',Options.path,filename,i);
        figure(handles(i))
        MySavePlot(name,Options.width,removetitle)
        savefig(sprintf('%s/%sfigure_%d',Options.path,filename,i));
    end
end

