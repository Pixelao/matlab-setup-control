PWRamp=5:5:100;
VRamp=-40:0.1:40;
Current=10e-9;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\Async\PWdependence(2)\PW=';
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
    I=str2double(PCSFig.Control.SM_ReadI(1,1)); %read current
    if I>Current
        j=j+1;
        if j>lenght(PWRamp) %break of the loop if all the powers are finished
            break
        end
        system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -p',' ',num2str(PWRamp(n))]) %set power
        pause(1)
        tic
        RunAsync() %asynchronous spectrum
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        MeasurementData.time(n)=toc;
        MeasurementData.Power(n)=PWRamp(n);
        save([DestinationPath num2str(PWRamp(n)) '.mat'],'MeasurementData')%save
        pause(1)
    else
        SMBias.String=num2str(VRamp(n)); % Set next voltage
        GoToV();
        pause(0.2)
    end
end
disp('Measurement Ended')