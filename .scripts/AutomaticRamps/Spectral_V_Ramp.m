VRamp=-60:5:-30;%select VoltageRamp
DestinationPath='C:\Users\Usuario\Desktop\Medidas\Ana PR\ReS2\2021_05_13\vramp\V=';%select folder to save
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
WLRunAsyncButton=findobj(WLRampFig,'String','Run Async');
RunNow=WLRunNowButton.Callback;
RunAsync=WLRunAsyncButton.Callback;
% Do measurements and save
j=1;
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(0.2)
        pause(1)
        I=str2double(PCSFig.Control.SM_ReadI(1,1));
        MeasurementData.Ioff(n)=I;
        tic
        RunAsync(); %Measure WL ramp
        PCSFig.Control.LAoff
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        MeasurementData.time(j)=toc;
        pause(10)
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
end
SMChannel.String='1';
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
SMChannel.String='2';
GoToV();
disp('Measurement Ended')
