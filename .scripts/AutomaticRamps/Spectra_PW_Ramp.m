PWRamp=2:2:100;
Ifixed=20e-9;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\PWramp\Vg-Vth=5V\PW=';%select folder to save
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
for n=1:length(PWRamp)
    PCSFig.Control.LAgo(PWRamp(n)); 
    pause(0.2)
    pause(1)
    %loop to avoid the photodoping
    I=PCSFig.Control.SM_ReadI(1,1);
    Vg=SMBias.String;
    while I<Ifixed
        Vg=Vg+0.1;
        SMBias.String=num2str(Vg); % Move gate
        GoToV();
        I=PCSFig.Control.SM_ReadI(1,1); %read Current
    end
    %end loop
    tic
    RunAsync(); %Measure WL Ramp
    % Save
    MeasurementData=WLRampFig.MeasurementData;
    MeasurementData.time=toc;
    PCSFig.Control.LAoff
    save([DestinationPath num2str(PWRamp(n)) '.mat'],'MeasurementData')
    pause(5)
end
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
disp('Measurement Ended')
