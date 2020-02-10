%oscilloscope
figure('color',[1,1,1])
plot(scope01(:,1)*1000,scope01(:,2),'linewidth',2,'color',[1,0,0])
xlabel('\sl t \rm (ms)')
ylabel('\sl Photocurrent \rm (a.u)')
grid on