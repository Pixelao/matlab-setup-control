%CurrentRamp=150e-9:-5e-9:5e-9;
VRamp=0.5:0.5:10;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\Vsdramp\Vg-Vth=-5V\V=';%select folder to save
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
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV();
    pause(1)
    tic
    RunAsync(); %Measure WL ramp
    % Save
    MeasurementData=WLRampFig.MeasurementData;
    MeasurementData.time(n)=toc;
    PCSFig.Control.LAoff
    save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
    pause(5)
end
disp('Measurement Ended')