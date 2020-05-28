VRamp=-40:0.1:40;%select VoltageRamp
PW=15; %select power off the laser
DestinationPath='.\Measurements\AutoSave\2020-02-07\V=';%select folder to save
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
system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -off'])
% Do measurements and save
j=1;
I=[1:1:30 30:2:500].*1e-9;
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(0.2)
    Current=str2double(PCSFig.Control.SM_ReadI(1,1))
    if Current>I(j) %ConditionCurrent
        j=j+1;
        system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -on']) %laser on
        pause(1)
        system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -p',' ',num2str(PW)]) %laser on
        tic
        RunNow(); %Measure WL ramp
        system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -off']) %laser off
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        MeasurementData.time(j)=toc;
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
        system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com\MS257com.exe -m 800')
    end
end
disp('Measurement Ended')

