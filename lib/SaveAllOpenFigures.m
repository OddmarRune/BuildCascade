function [  ] = SaveAllOpenFigures( path, width, removetitle )
    if nargin<2
        width = -2;
    end
    if nargin<3
        removetitle = true;
    end 
    handles=findall(0,'type','figure');
    for i = 1:length(handles)
        name = sprintf('%s/figure_%d.tiff',path,i);
        figure(handles(i))
        MySavePlot(name,width,removetitle)
    end
end

