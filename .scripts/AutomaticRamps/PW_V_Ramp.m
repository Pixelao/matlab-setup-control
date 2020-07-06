VRamp=-40:1:40;%select VoltageRamp
DestinationPath='C:\Users\Usuario\Desktop\Medidas\PWVramp\V=';%select folder to save
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
PWRampFig=findobj('Type','Figure','Name','PW ramp');
PWRunNowButton=findobj(PWRampFig,'String','Run Now');
RunNow=PWRunNowButton.Callback;
% Do measurements and save
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(0.2)
        pause(1)
        tic
        RunNow(); %Measure PW ramp
        % Save
        MeasurementData=PWRampFig.MeasurementData;
        MeasurementData.time=toc;
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
end
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
disp('Measurement Ended')
