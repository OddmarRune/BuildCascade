function [  ] = autodock( on )
    if nargin<1 || on
        set(0,'DefaultFigureWindowStyle','docked')
    else
        set(0,'DefaultFigureWindowStyle','normal')
    end
end

