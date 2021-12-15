VRamp=-190:5:180;%select VoltageRamp
DestinationPath='C:\Users\Usuario\Desktop\Medidas\MoSe2_sample\2021_05_04\Powerrampsbis\V=';%select folder to save
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
j=1;
PCSFig.Control.LAgo(0);
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(5)
        pause(1)
        tic
        RunNow(); %Measure PW ramp
        PCSFig.Control.LAoff
        PCSFig.Control.LAgo(0);
        % Save
        MeasurementData=PWRampFig.MeasurementData;
        MeasurementData.time(j)=toc;
        pause(5)
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
end
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
disp('Measurement Ended')
