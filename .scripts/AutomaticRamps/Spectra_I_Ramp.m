%CurrentRamp=150e-9:-5e-9:5e-9;
VRamp=-40:0.1:40;
DestinationPath='.\Measurements\AutoSave\2019-12-04,Vgatespectralrampfixedcurrent\V=';
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
system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com.exe -m 700')
% Do measurements and save
tic
j=1;
for n=1:length(VRamp)
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV(); 
    Current=str2double(PCSFig.Control.SM_ReadI(1,1))
    if Current>j*(0.1e-9+j*0.05e-9) %ConditionCurrent
        j=j+1;
        RunNow(); %Measure WL ramp
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
        system('C:\Users\Usuario\matlab-setup-control\.resources\MS257com.exe -m 700')
    end
end
disp('Measurement Ended')
toc
