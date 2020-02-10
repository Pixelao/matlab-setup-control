%%plot all
files=dir('*.mat');
for i=1:length(files)
    name(i)=sscanf(files(i).name,'V=%g.mat');
end
name=sort(name);
figure(1);
axis([1.8 2.3 0 inf])
figure(2);
color=linspace(0,1,length(name));
LF=@(I,x0,gamma,x) I./(1+((x-x0)/gamma).^2);%lorentzianfunction
for i=1:length(name)
    %if i==25
        %nada
    %else
    load(['V=' num2str(name(i)) '.mat'])
    Photocurrent(:)=MeasurementData.LI(1,1,:);
    SMcurrent(:)=MeasurementData.SM.I(1,1,:);
    I0(i,1)=SMcurrent(1);
    If(i,1)=SMcurrent(length(SMcurrent));
    SMcurrent(length(SMcurrent))=[];
    WL(:)=MeasurementData.WL(1,1,:);
    WL(length(WL))=[];
    Photocurrent(length(Photocurrent))=[];
    E=1240./(WL-23);
    Pnorm=Photocurrent/max(Photocurrent);
    figure(1);
    hold on
    plot(E,Pnorm+0.4*i,'color',[color(i),0,0],'linewidth',1);
    figure(2);
    hold on
    plot(E,SMcurrent,'color',[color(i),0,0]);
    clear Photocurrent WL E SMcurrent Pnorm Energy
    %end
end
hold off
figure(3);hold on
plot(name,I0,'o-');plot(name,If,'o-');
