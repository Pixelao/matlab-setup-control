TRamp=5:5:100;%Rampa de temperaturas
Tol=1;%tolerancia 
Time=60;%tiempo de estabilización
DestinationPath='.\Measurements\T=';
% Find voltage control panel
PCSFig=findobj('Type','Figure','Name','PCS');
VCPanel=findobj('Parent',PCSFig,'Title','Source-Meter Control');
% Find voltage controls
Channel=[1 2];
SMIndex=findobj('Parent',VCPanel,'Tag','SMIndex');
SMChannel=findobj('Parent',VCPanel,'Tag','SMChannel');
SMBias=findobj('Parent',VCPanel,'Tag','SMBias');
SMGo=findobj('Parent',VCPanel,'String','Go');
SMRead=findobj('Parent',VCPanel,'String','Read');
SMCurrent=findobj('Parent',VCPanel,'Tag','SMCurrent');
GoToV=SMGo.Callback;
ReadI=SMRead.Callback;
% Find Run Now button
WLRampFig=findobj('Type','Figure','Name','WL ramp');
WLRunNowButton=findobj(WLRampFig,'String','Run Now');
RunNow=WLRunNowButton.Callback;
% Do measurements and save
for n=1:length(TRamp)
    SetT=TRamp(n);
    PCSfig.Control.ITC503_SetT(SetT,Tol,Time)
    tic
    system('C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -on'); 
    RunNow() %Measure WL ramp
    system('C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -off');
    % Save
    MeasurementData=WLRampFig.MeasurementData;
    MeasurementData.time(n)=toc;
    MeasurementData.T(n)=TRamp(n);
    save([DestinationPath num2str(TRamp(n)) '.mat'],'MeasurementData')
end
disp('Measurement Ended')