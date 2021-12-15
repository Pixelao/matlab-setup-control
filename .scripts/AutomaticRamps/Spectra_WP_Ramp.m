AnglesRamp=0:5:360;
% Imin=1.5e-9;
% Imax=2e-9;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\ZrSe3_deviceB\2021_07_14\wpramp\WP=';%select folder to save
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
k=0;
for i=1:1:1000
    if i==1
        AnglesRamp=225:5:360;
    else
        AnglesRamp=0:5:360;
    end
    for n=1:length(AnglesRamp)
        if rem(n,5)==0
            TheAxes=findobj('Parent',WLRampFig,'Type','Axes');
            cla(TheAxes(1))
            cla(TheAxes(2))
            cla(TheAxes(3))
            cla(TheAxes(4))
        end
        PCSFig.Control.WaveplateMove(AnglesRamp(n));
        PCSFig.Control.LAon
        pause(0.2)
        pause(1)
        %loop to avoid the photodoping
        %     I=str2double(PCSFig.Control.SM_ReadI(1,1));
        %     Vg=str2double(SMBias.String);
        %     while I<Imin || I>Imax
        %         if I<Imin
        %             Vg=Vg+0.01;
        %             SMBias.String=num2str(Vg); % Move gate
        %             GoToV();
        %             I=str2double(PCSFig.Control.SM_ReadI(1,1));%read Current
        %         elseif I>Imax
        %             Vg=Vg-0.01;
        %             SMBias.String=num2str(Vg); % Move gate
        %             GoToV();
        %             I=str2double(PCSFig.Control.SM_ReadI(1,1));%read Current
        %         end
        %     end
        %end loop
        tic
        RunAsync(); %Measure WL Ramp
        % Save
        MeasurementData=WLRampFig.MeasurementData;
        MeasurementData.time=toc;
        PCSFig.Control.LAoff
        save([DestinationPath num2str(AnglesRamp(n)) 'º-' num2str(i) '.mat'],'MeasurementData')
        disp(['Measurement time = ' num2str(MeasurementData.time) ' s'])
        %pause(60)
    end
end
SMChannel.String='1';
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
SMChannel.String='2';
GoToV();
PCSFig.Control.WaveplateHome;
disp('Measurement Ended')
