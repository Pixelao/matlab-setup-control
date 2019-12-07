%%output and transfer curve at room temperature 
fig=gcf;Data=fig.MeasurementData;
Vg(:)=Data.SM.V(1,2,:);
Ids(:)=Data.SM.I(2,1,:);
figure;plot(Vg,Ids*10^9,'.');
xlabel('Vg (V)');ylabel('Ids (nA)'); grid on;
%% linear fit of transfer curve
hold on
j=0;
for i=1:length(Vg)
    if Vg(i)>10
        j=j+1;
        Vgfit(j)=Vg(i);
        Idsfit(j)=Ids(i);
    end
end
fit=polyfit(Vgfit,Idsfit,1);
j=0;
for i=1:length(Vg)
     if Vg(i)>7.5
        j=j+1;
        Vgplotfit(j)=Vg(i);
    end
end    
b=polyval(fit,Vgplotfit).*10^9;
plot(Vgplotfit,b)
clear a
clear b
clear Vgplotfit
clear fit
clear Idsfit
clear Vgfit
%% Output Curves plotting
fig=gcf;Data=fig.MeasurementData;
Vds(:)=Data.SM.V(2,1,:);
Ids(:)=Data.SM.I(2,1,:);
figure;plot(Vds,Ids*10^9,'.');
xlabel('Vds (V)');ylabel('Ids (nA)'); grid on;