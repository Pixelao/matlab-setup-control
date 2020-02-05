%CurrentRamp=150e-9:-5e-9:5e-9;
VRamp=-40:0.1:40;
DestinationPath='.\Measurements\AutoSave\2020-02-03\V=';
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
system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com.exe -m 730')
% Do measurements and save
j=1;
I=[1:1:20 23:1:150].*1e-9;
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(0.2)
    Current=str2double(PCSFig.Control.SM_ReadI(1,1))
    if Current>I(j) %ConditionCurrent
        j=j+1;
        tic
        RunNow(); %Measure WL ramp
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        MeasurementData.time(j)=toc;
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
        system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com.exe -m 900')
    end
end
disp('Measurement Ended')

