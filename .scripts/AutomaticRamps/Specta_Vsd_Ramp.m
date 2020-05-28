%CurrentRamp=150e-9:-5e-9:5e-9;
VRamp=[-3:0.5:1 1:0.25:10];
DestinationPath='.\Measurements\AutoSave\2020-02-10\V=';
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
system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com\MS257com.exe -m 800')
% Do measurements and save
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(0.2)
    tic
    RunNow(); %Measure WL ramp
    % Save
    MeasurementData=WLRampFig.MeasurementData;
    MeasurementData.time(n)=toc;
    save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
    system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com\MS257com.exe -m 800')
end
disp('Measurement Ended')