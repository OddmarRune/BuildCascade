function [ h ] = h_NG( p, T, varargin )
    Options = LazyOptions(varargin,...
        'method',{'','spline','cubic','linear', 'nearest'});
    load('NG_data')
    if isempty(Options.method)
        h = interp2(pp,TT,hh,p,T);
    else
        h = interp2(pp,TT,hh,p,T,Options.method);
    end
end

