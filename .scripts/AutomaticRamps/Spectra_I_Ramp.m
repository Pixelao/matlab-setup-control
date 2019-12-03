CurrentRamp=150e-9:-5e-9:5e-9;
VRamp=-50:0.1:50;
DestinationPath='.\Measurements\AutoSave\Test\V=';
% Find voltage control panel
PCSFig=findobj('Type','Figure','Name','PCS');
VCPanel=findobj('Parent',PCSFig,'Title','Source-Meter Control');
% Find voltage controls
SMIndex=findobj('Parent',VCPanel,'Tag','SMIndex');
SMChannel=findobj('Parent',VCPanel,'Tag','SMChannel');
SMBias=findobj('Parent',VCPanel,'Tag','SMBias');
SMGo=findobj('Parent',VCPanel,'String','Go');
SMRead=findobj('Parent',VCPanel,'String','Read');
SMCurrent=findobj('Parent',VCPanel,'Tag','Read');
GoToV=SMGo.Callback;
ReadI=SMRead.Callback;
% Find Run Now button
WLRampFig=findobj('Type','Figure','Name','WL ramp');
WLRunNowButton=findobj(WLRampFig,'String','Run Now');
RunNow=WLRunNowButton.Callback;

% Do measurements and save
tic
for n=1:length(VRamp)
    SMIndex.String=num2str(2);
    SMBias.String=num2str(VRamp(n)); % Set next voltage
    GoToV(); 
    SMIndex.String=num2str(1);
    ReadI(); %Read source-drain current
    if SMCurrent>n*0.2e-9 % 
        RunNow(); %Measure WL ramp
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
    end
end
disp('Measurement Ended')
toc
