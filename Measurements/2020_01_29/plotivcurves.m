%%plot all
files=dir('*.mat');
for i=1:length(files)
    name(i)=sscanf(files(i).name,'%g.mat');
end
name=sort(name);
j=1;
for i=[16 17:2:33]
    load([num2str(i) '.mat'])
    V(:)=MeasurementData.SM.V(1,1,:);
    I(:)=MeasurementData.SM.I(1,1,:);
    Vds(:,j)=V(1,:);
    Ids(:,j)=I(1,:);
    j=j+1;
    clear I V
end
Vg=[-30:5:15];
figure
hold on
for i=1:10
    plot(Vds(:,i),Ids(:,i)*10^9,'linewidth',2,'color',[i/10,0,0])
    %txt = text(-2+i*0.2,i*30,['\bf \sl V_g' '\rm \bf =' ' ' num2str(Vg(i))  '\bf V'],'color',[i/10,0,0],'FontSize',11);

end
grid on
axis([-5 5 -inf 300])
xlabel('\sl V_{ds}\rm (V)')
ylabel('\sl I_{ds}\rm (nA)')