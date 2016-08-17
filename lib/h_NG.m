function [ h ] = h_NG( p, T )
    load('NG_data')
    h = interp2(pp,TT,hh,p,T);        
end

