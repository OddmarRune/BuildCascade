

colors = [ 0 0 0
           0.5 0 0
           1 0 0 ];

MyMap = MyColorMap(colors,5)

contourf(peaks,10)
%surf(peaks)
colormap(MyMap)
colorbar
