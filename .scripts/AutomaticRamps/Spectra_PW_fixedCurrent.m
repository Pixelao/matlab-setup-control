PWRamp=60:10:100;
VRamp=0:0.1:40;
Current=20e-9;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\Async\PWdependence(4)\PW=';
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
system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com\MS257com.exe -m 800')
system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -p',' ',num2str(PWRamp(1))]) %set power
j=0; %initialize counter
for n=1:length(VRamp)
    I=str2double(PCSFig.Control.SM_ReadI(1,1)); %read current
    if I>Current
        j=j+1;
        if j>length(PWRamp) %break of the loop if all the powers are finished
            break
        end
        system(['C:\Users\Usuario\matlab-setup-control\.resources\NKTcom\NKTcom.exe -p',' ',num2str(PWRamp(j))]) %set power
        pause(1)
        tic
        RunAsync() %asynchronous spectrum
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        MeasurementData.time(j)=toc;
        MeasurementData.Power(j)=PWRamp(j);
        save([DestinationPath num2str(PWRamp(j)) '.mat'],'MeasurementData')%save
        pause(1)
        system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com\MS257com.exe -m 800')
    else
        SMBias.String=num2str(VRamp(n)); % Set next voltage
        GoToV();
        pause(0.2)
    end
end
disp('Measurement Ended')