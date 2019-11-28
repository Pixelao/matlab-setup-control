%import data from a figure
fig=gcf;
axObjs=fig.Children;dataObjs=axObjs.Children;
V=dataObjs(1).XData;V4=dataObjs.YData;
%%
suma1=1
suma2=1
for i=1:length(V4)
    if V4(i)>0
        V41(suma1)=V4(i);
        I41(suma1)=I(i);
        suma1=suma1+1;
    elseif V4(i)<0
        V42(suma2)=V4(i);
        I42(suma2)=I(i);
        suma2=suma2+1;
    end
end

    