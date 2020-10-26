FreqRamp=primes(1000);%FreqRamp([1:9])=[];
Imin=1.1e-7;
Imax=1.11e-7;
DestinationPath='C:\Users\Usuario\Desktop\Medidas\PWrampFreq\Vg-Vth=15V\Freq=';%select folder to save
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
PWRampFig=findobj('Type','Figure','Name','PW ramp');
PWRunNowButton=findobj(WLRampFig,'String','Run Now');
RunNow=PWRunNowButton.Callback;
% Do measurements and save
for n=1:length(FreqRamp)
    PCSFig.Control.LI_FreqSet(1,FreqRamp(n));
    PCSFig.Control.LAoff
    pause(0.2)
    pause(1)
%     loop to avoid the photodoping
    I=str2double(PCSFig.Control.SM_ReadI(1,1));
    Vg=str2double(SMBias.String);
    while I<Imin || I>Imax
        if I<Imin
            Vg=Vg+0.01;
            SMBias.String=num2str(Vg); % Move gate
            GoToV();
            I=str2double(PCSFig.Control.SM_ReadI(1,1));%read Current
        elseif I>Imax
            Vg=Vg-0.01;
            SMBias.String=num2str(Vg); % Move gate
            GoToV();
            I=str2double(PCSFig.Control.SM_ReadI(1,1));%read Current
        end
    end
%     end loop
    tic
    RunNow(); %Measure PW Ramp
    % Save
    MeasurementData=PWRampFig.MeasurementData;
    MeasurementData.time=toc;
    PCSFig.Control.LAoff
    save([DestinationPath num2str(FreqRamp(n)) '.mat'],'MeasurementData')
    pause(5)
end
SMBias.String=num2str(0); % Finish and set 0 V
GoToV();
disp('Measurement Ended')
