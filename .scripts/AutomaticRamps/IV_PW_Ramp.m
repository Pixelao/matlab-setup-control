PWRamp=0:2:100;
WL=639.5;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\Gateramp\ExcitonAWL\PW=';%select folder to save
% Find voltage control panel
PCSFig=findobj('Type','Figure','Name','PCS');
VCPanel=findobj('Parent',PCSFig,'Title','Source-Meter Control');
WLPanel=findobj('Parent',PCSFig,'Title','Wavelength');
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
IVRampFig=findobj('Type','Figure','Name','WL ramp');
IVRunNowButton=findobj(WLRampFig,'String','Run Now');
RunNow=IVRunNowButton.Callback;
% Do measurements and save
for n=1:length(PWRamp)
    %IVrampoff
    pause(1)
    PCS.Fig.Control.LAoff;
    PCSFig.Control.LAgo(PWRamp(n));
    tic
    RunNow(); %Measure IV Ramp
    % Save
    MeasurementData=IVRampFig.MeasurementData;
    MeasurementData.time=toc;
    PCSFig.Control.LAoff
    save([DestinationPath num2str(PWRamp(n)) 'off.mat'],'MeasurementData')
    pause(5)
    %IVrampon
    PCSFig.Control.LAgo(PWRamp(n));
    PCSFig.Control.MS257move(WL);
    pause(1)
    PCS.Fig.Control.LAon;
    tic
    RunNow(); %Measure IV Ramp
    % Save
    MeasurementData=IVRampFig.MeasurementData;
    MeasurementData.time=toc;
    PCSFig.Control.LAoff
    save([DestinationPath num2str(PWRamp(n)) 'on.mat'],'MeasurementData')
    pause(5)
end
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
disp('Measurement Ended')
