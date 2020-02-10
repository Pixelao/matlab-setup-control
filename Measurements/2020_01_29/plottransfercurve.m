clear all
load('cooltransfercurve5Vsd.mat')
j=0;
Vg(:)=MeasurementData.SM.V(2,1,:);Ids(:)=MeasurementData.SM.I(1,1,:).*10^9;
Vg(350:1:length(Vg))=[];
Ids(350:1:length(Ids))=[];
for i=1:length(Vg)
    if Vg(i)>15
        j=j+1;
        Vgfit(j)=Vg(i);
        Idsfit(j)=Ids(i);
    end
end
p=polyfit(Vgfit,Idsfit,1);
figure('color',[1,1,1]);
axis([0 inf -0.5 70])
hold on
plot(Vg,Ids,'linewidth',2,'color',[0,0,0]);
plot([12:0.1:35],polyval(p,[12:0.1:35]),'linewidth',2,'color',[1,0,0]);
xlabel('\sl V_g \rm (V)');ylabel('\sl I_{ds} \rm (nA)');
grid on