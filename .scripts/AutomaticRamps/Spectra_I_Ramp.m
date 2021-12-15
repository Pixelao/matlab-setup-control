VRamp=-20:0.2:180;%select VoltageRamp
Iramp=[0 0.1e-9 0.2e-9 0.5e-9 1e-9:0.5e-9:60e-9];
DestinationPath='C:\Users\Usuario\Desktop\Medidas\MoSe2_sample\2021_04_28bis\V=';%select folder to save
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
k=1;
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(0.2)
        I=str2double(PCSFig.Control.SM_ReadI(1,1)); %read current
        if I>Iramp(k)
            tic
            RunAsync(); %Measure WL ramp
            PCSFig.Control.LAoff
            % Save
            MeasurementData=WLRampFig.MeasurementData;
            MeasurementData.time(j)=toc;
            pause(10)
            save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
            k=k+1;
        else
            %continue
        end
end
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
disp('Measurement Ended')
