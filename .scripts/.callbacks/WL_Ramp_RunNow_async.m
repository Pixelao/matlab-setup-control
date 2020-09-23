function [] = WL_Ramp_RunNow_async (varargin)
%%
addpath(genpath(pwd))
% get figure UI handles
PCSfig=findobj('Name','PCS');
WLfig=findobj('Name','WL ramp');
%%
% create sweep vector
if WLfig.UIHandles.check_V_Custom.Value
    eval(strcat('SweepRamp =',WLfig.UIHandles.h_V_Custom.String,';'));
    SweepDelay = str2num(WLfig.UIHandles.h_V_Delay.String);
else
    SweepMin = str2num(WLfig.UIHandles.h_V_Min.String);
    SweepMax = str2num(WLfig.UIHandles.h_V_Max.String);
    SweepStep = str2num(WLfig.UIHandles.h_V_Step.String);
    SweepDelay = str2num(WLfig.UIHandles.h_V_Delay.String);
    SweepLimit = str2num(WLfig.UIHandles.h_V_Limit.String);
    
    if WLfig.UIHandles.check_dual.Value
        SweepRamp = [0:SweepStep:SweepMax SweepMax:-SweepStep:SweepMin SweepMin:SweepStep:0];
    else
        SweepRamp = [SweepMin:SweepStep:SweepMax];
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
    ax(j)=WLfig.UIHandles.axes(j);
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
Data.WL=NaN(1,1,length(SweepRamp));
Data.SP=NaN(2,length(SweepRamp));
Data.time=NaN(1,length(SweepRamp));
% initialize electrometers
if PCSfig.NumberOfElectrometers>0
    for ind=1:PCSfig.NumberOfElectrometers
        PCSfig.Control.EM_Init(ind,1) % init EMs in voltage sensing mode
    end
end
% start scan
PCSfig.Control.MS257move(SweepMin);
PCSfig.Control.LAon %turn on the laser
PCSfig.Control.MS257scan(SweepMin,SweepMax);
pause(0.1)
n=1;%initialize iteration
Data.SP(1,n)=SweepMin;%Initialize condition
Data.SP(2,n)=0;
EndCond=0;
tic
while EndCond<4 %max(Data.SP)<SweepMmax+10
    if WLfig.UIHandles.b_Abort.Value == 1
        WLfig.UIHandles.b_Abort.Value = 0;
        warning('Measurement aborted by user')
        return
    end
    while WLfig.UIHandles.b_Pause.Value == 1
        pause(0.1)
    end
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
    %measure wavelength
    [Data.SP(1,n),Data.SP(2,n)]=PCSfig.Control.SPread;
    %measure time
    Data.time(1,n)=toc;
    % plot requested signals in axes
    for j=1:4
        device=char(WLfig.UIHandles.pickplot_device(j).String(WLfig.UIHandles.pickplot_device(j).Value));
        ind=WLfig.UIHandles.popup_pickplot_index(j).Value;
        channel=WLfig.UIHandles.popup_pickplot_channel(j).Value;
        mode=WLfig.UIHandles.popup_pickplot_mode(j).Value;
        set(draw(j),'xdata',Data.SP(1,:))
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
    WLfig.MeasurementData=Data;
    drawnow
    % check stop condition
    if abs(Data.SP(1,n)-SweepMax)<1
        EndCond=EndCond+1;
    else
        EndCond=0;
    end
    n=n+1;%iteración
end
PCSfig.Control.LAoff
WLfig.MeasurementData=Data;
disp('Done')
clear check
%%
end