function [] = freq_Ramp_RunNow (varargin)
%%
addpath(genpath(pwd))
% get figure UI handles
PCSfig=findobj('Name','PCS');
VCPanel=findobj('Parent',PCSfig,'Title','Source-Meter Control');
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
freqfig=findobj('Name','freq ramp');
% create sweep vector
if freqfig.UIHandles.check_V_Custom.Value
    eval(strcat('SweepRamp =',freqfig.UIHandles.h_V_Custom.String,';'));
    SweepDelay = str2num(freqfig.UIHandles.h_V_Delay.String);
else
    SweepMin = str2num(freqfig.UIHandles.h_V_Min.String);
    SweepMmax = str2num(freqfig.UIHandles.h_V_Max.String);
    SweepStep = str2num(freqfig.UIHandles.h_V_Step.String);
    SweepDelay = str2num(freqfig.UIHandles.h_V_Delay.String);
    SweepLimit = str2num(freqfig.UIHandles.h_V_Limit.String);
    
    if freqfig.UIHandles.check_dual.Value
        SweepRamp = [0:SweepStep:SweepMmax SweepMmax:-SweepStep:SweepMin SweepMin:SweepStep:0];
    else
        SweepRamp = [SweepMin:SweepStep:SweepMmax];
    end
end
%%
% check if equipment is connected
if isempty(PCSfig.Control.equipment)
    error('No equipment connected')
elseif isempty(PCSfig.Control.equipment.SM)
    error('No Source Meters connected')
end
%%
% initialize plots
for j=1:4
    ax(j)=freqfig.UIHandles.axes(j);
    draw(j)=plot(ax(j),SweepRamp,NaN(1,length(SweepRamp)));
    set(ax(j),'xlim',[min(SweepRamp) max(SweepRamp)])    
end

%% do ramp and plot
% initialize data variable
MaxSMIndex=PCSfig.NumberOfSourceMeters;
MaxChannel=max(PCSfig.SourceMeterChannels);
Data.SM.V=NaN(MaxSMIndex,MaxChannel,length(SweepRamp));
Data.SM.I=NaN(MaxSMIndex,MaxChannel,length(SweepRamp));
Data.EM=NaN(MaxSMIndex,length(SweepRamp));
Data.LI=NaN(MaxSMIndex,MaxChannel,length(SweepRamp));
Data.PWmeasure=NaN(1,1,length(SweepRamp));
Data.SP=NaN(1,1,length(SweepRamp));
Data.freq=NaN(1,1,length(SweepRamp));
% fix current
I=str2num(freqfig.UIHandles.h_I_fix.String);
Imin=(I-0.02)*1e-9;
Imax=(I+0.02)*1e-9;
% initialize electrometers
if PCSfig.NumberOfElectrometers>0
    for ind=1:PCSfig.NumberOfElectrometers
        PCSfig.Control.EM_Init(ind,1) % init EMs in voltage sensing mode
    end
end
for n=1:length(SweepRamp)
    PCSfig.Control.LAoff;
    if freqfig.UIHandles.b_Abort.Value == 1
        freqfig.UIHandles.b_Abort.Value = 0;
        warning('Measurement aborted by user')
        return
    end
    while freqfig.UIHandles.b_Pause.Value == 1
        pause(0.1)
    end
    % set source to next step
    PCSfig.Control.LI_FreqSet(1,SweepRamp(n));
    Data.freq(n)=SweepRamp(n);
    if freqfig.UIHandles.check_fixcurrent.Value==1
        %loop to avoid the photodoping
        I=str2double(PCSfig.Control.SM_ReadI(1,1));
        Vg=str2double(SMBias.String);
        while I<Imin || I>Imax
            if I<Imin
                Vg=Vg+0.01;
                SMBias.String=num2str(Vg); % Move gate
                GoToV();
                I=str2double(PCSfig.Control.SM_ReadI(1,1));%read Current
            elseif I>Imax
                Vg=Vg-0.01;
                SMBias.String=num2str(Vg); % Move gate
                GoToV();
                I=str2double(PCSfig.Control.SM_ReadI(1,1));%read Current
            end
        end
    end
    %end loop
    PCSfig.Control.LAon;
    pause(SweepDelay)
    % measure signals from all connected source meters
    for ind=1:PCSfig.NumberOfSourceMeters
        for channel = 1:2
            if channel<=PCSfig.SourceMeterChannels(ind)
            Data.SM.V(ind,channel,n)=str2num(PCSfig.Control.SM_ReadV(ind,channel));
            Data.SM.I(ind,channel,n)=str2num(PCSfig.Control.SM_ReadI(ind,channel));
            end
        end
    end
    % measure lock-ins
    [Data.LI(1:PCSfig.NumberOfLockins,1,n),Data.LI(1:PCSfig.NumberOfLockins,2,n)]=PCSfig.Control.LI_Read('rt');
    % measure electrometers
    for ind=1:PCSfig.NumberOfElectrometers
        myvalues=str2num(PCSfig.Control.EM_Read(ind));
        Data.EM(ind,n)=myvalues(1);
    end
    %measure Wavelength
    Data.SP(n)=PCSfig.Control.SPread;
    Data.PWmeasure(n)=str2double(PCSfig.Control.LAread);
    % plot requested signals in axes
    for j=1:4
        device=char(freqfig.UIHandles.pickplot_device(j).String(freqfig.UIHandles.pickplot_device(j).Value));
        ind=freqfig.UIHandles.popup_pickplot_index(j).Value;
        channel=freqfig.UIHandles.popup_pickplot_channel(j).Value;
        mode=freqfig.UIHandles.popup_pickplot_mode(j).Value;
        switch device
            case 'SourceMeter'
                switch mode
                    case 1 %I
                        set(draw(j),'ydata',Data.SM.I(ind,channel,:))
                    case 2 %V
                        set(draw(j),'ydata',Data.SM.V(ind,channel,:))
                end
            case 'Electrometer'
                set(draw(j),'ydata',Data.EM(1,:)-Data.EM(2,:))
            case 'Lock-In'
                set(draw(j),'ydata',Data.LI(ind,channel,:))
            case 'Plot Nothing'
                % do nothing
        end
    end
freqfig.MeasurementData=Data;
pause(0.001); 
drawnow
PCSfig.Control.LAoff;
end
PCSfig.Control.LAoff;
freqfig.MeasurementData=Data;
disp('Done')
%%
end