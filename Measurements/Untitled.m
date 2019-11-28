clear x y ysmooth
x=get(gco,'xdata');
y=get(gco,'ydata');
smoothwidth=0.003; %(eV)
for n=1:length(x)
ysmooth(n)=mean(y(abs(x-x(n))<smoothwidth));
end
hold on; plot(x,ysmooth,'-k','linewidth',1)
%%%
