VRamp=20:-2.5:0;
DestinationPath='.\Measurements\AutoSave\Test\V=';
% Find voltage control panel
PCSFig=findobj('Type','Figure','Name','PCS');
VCPanel=findobj('Parent',PCSFig,'Title','Source-Meter Control');
% Find voltage controls
SMIndex=findobj('Parent',VCPanel,'Tag','SMIndex');
SMChannel=findobj('Parent',VCPanel,'Tag','SMChannel');
SMBias=findobj('Parent',VCPanel,'Tag','SMBias');
SMGo=findobj('Parent',VCPanel,'String','Go');
GoToV=SMGo.Callback;
% Find Run Now button
WLRampFig=findobj('Type','Figure','Name','WL ramp');
WLRunNowButton=findobj(WLRampFig,'String','Run Now');
RunNow=WLRunNowButton.Callback;

% Do measurements and save
tic
for n=1:length(VRamp)

SMBias.String=num2str(VRamp(n)); % Set next voltage
GoToV(); RunNow(); %Go to next voltage and measure WL ramp
% Save
MeasurementData=WLRampFig.MeasurementData;
save([DestinationPath num2str(VRamp(n)) '.mat'],'MeasurementData')
end
disp('Measurement Ended')
toc

