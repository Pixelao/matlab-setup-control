PWRamp=5:5:100;
DestinationPath='.\Measurements\AutoSave\2020-03-02(0)\PW=';
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
%move MS257
system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com\MS257com.exe -m 700')
% Do measurements and save
for n=1:length(PWRamp)
    system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -on'])%laser on
    system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -p',' ',num2str(PWRamp(n))])
    pause(1)
    tic
    RunNow()
    system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -off']); %Measure WL ramp
    % Save
    MeasurementData=WLRampFig.MeasurementData;
    MeasurementData.time(n)=toc;
    MeasurementData.Power(n)=PWRamp(n);
    save([DestinationPath num2str(PWRamp(n)) '.mat'],'MeasurementData')
    system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com.exe -m 700')
end
disp('Measurement Ended')