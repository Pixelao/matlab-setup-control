function [] = PW_Ramp_RunNow (varargin)
%%
addpath(genpath(pwd))
% get figure UI handles
PCSfig=findobj('Name','PCS');
PWfig=findobj('Name','PW ramp');
% create sweep vector
if PWfig.UIHandles.check_V_Custom.Value
    eval(strcat('SweepRamp =',PWfig.UIHandles.h_V_Custom.String,';'));
    SweepDelay = str2num(PWfig.UIHandles.h_V_Delay.String);
else
    SweepMin = str2num(PWfig.UIHandles.h_V_Min.String);
    SweepMmax = str2num(PWfig.UIHandles.h_V_Max.String);
    SweepStep = str2num(PWfig.UIHandles.h_V_Step.String);
    SweepDelay = str2num(PWfig.UIHandles.h_V_Delay.String);
    SweepLimit = str2num(PWfig.UIHandles.h_V_Limit.String);
    
    if PWfig.UIHandles.check_dual.Value
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
    ax(j)=PWfig.UIHandles.axes(j);
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
Data.PW=NaN(1,1,length(SweepRamp));
Data.PWmeasure=NaN(1,1,length(SweepRamp));
Data.SP=NaN(1,1,length(SweepRamp));
%init laser
PCSfig.Control.LAgo(SweepRamp(1));
PCSfig.Control.LAon;
% initialize electrometers
if PCSfig.NumberOfElectrometers>0
    for ind=1:PCSfig.NumberOfElectrometers
        PCSfig.Control.EM_Init(ind,1) % init EMs in voltage sensing mode
    end
end
for n=1:length(SweepRamp)
    if PWfig.UIHandles.b_Abort.Value == 1
        PWfig.UIHandles.b_Abort.Value = 0;
        warning('Measurement aborted by user')
        return
    end
    while PWfig.UIHandles.b_Pause.Value == 1
        pause(0.1)
    end
    % set source to next step
    PCSfig.Control.LAgo(SweepRamp(n));
    Data.PW(n)=SweepRamp(n);
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
        device=char(PWfig.UIHandles.pickplot_device(j).String(PWfig.UIHandles.pickplot_device(j).Value));
        ind=PWfig.UIHandles.popup_pickplot_index(j).Value;
        channel=PWfig.UIHandles.popup_pickplot_channel(j).Value;
        mode=PWfig.UIHandles.popup_pickplot_mode(j).Value;
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
PWfig.MeasurementData=Data;
pause(0.001); 
drawnow
end
PCSfig.Control.LAoff;
PWfig.MeasurementData=Data;
disp('Done')
%%
end