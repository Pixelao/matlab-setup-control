function [] = TimePlot_RunNow (varargin)
%%
addpath(genpath(pwd))
% get figure UI handles
PCSfig=findobj('Name','PCS');
Timefig=findobj('Name','TimePlot');

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
    ax(j)=Timefig.UIHandles.axes(j);
    draw(j)=plot(ax(j),0:300,NaN(1,301));
    set(ax(j),'xlim',[min(SweepRamp) max(SweepRamp)])
end

%% do ramp and plot
% initialize data variable
MaxSMIndex=PCSfig.NumberOfSourceMeters;
MaxChannel=max(PCSfig.SourceMeterChannels);
Data.SM.V=NaN(MaxSMIndex,MaxChannel,length(SweepRamp));
Data.SM.I=NaN(MaxSMIndex,MaxChannel,length(SweepRamp));
Data.EM=NaN(MaxSMIndex,MaxChannel,length(SweepRamp));
% initialize electrometers
if PCSfig.NumberOfElectrometers>0
    for ind=1:PCSfig.NumberOfElectrometers
        PCSfig.Control.EM_Init(ind,1) % init EMs in voltage sensing mode
    end
end
for n=1:length(SweepRamp)
    if Timefig.UIHandles.b_Abort.Value == 1
        warning('Measurement aborted by user')
        return
    end
    while Timefig.UIHandles.b_Pause.Value == 1
        pause(0.1)
    end
    % set source to next step
    switch SourceMode
        case 1 %source voltage
            if n==1
                if Timefig.UIHandles.b_Abort.Value == 1
                    return
                end
                while Timefig.UIHandles.b_Pause.Value == 1
                    pause(0.1)
                end
                Vstart=str2num(PCSfig.Control.SM_ReadV(SourceIndex,SourceChannel));
                PCSfig.Control.SM_RampV(SourceIndex,SourceChannel,Vstart,SweepRamp(n),0.05,0.1)%ramp to first value
            else
                PCSfig.Control.SM_SetV(SourceIndex,SourceChannel,SweepRamp(n))
            end
        case 2 %source current
            if n==1
                if Timefig.UIHandles.b_Abort.Value == 1
                    return
                end
                while Timefig.UIHandles.b_Pause.Value == 1
                    pause(0.1)
                end
                Istart=str2num(PCSfig.Control.SM_ReadI(SourceIndex,SourceChannel));
                PCSfig.Control.SM_RampI(SourceIndex,SourceChannel,Istart,SweepRamp(n),0.05,0.1)%ramp to first value
            else
                PCSfig.Control.SM_SetI(SourceIndex,SourceChannel,SweepRamp(n))
            end
    end
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
    % measure electrometers
    for ind=1:PCSfig.NumberOfElectrometers
        myvalues=str2num(PCSfig.Control.EM_Read(ind));
        Data.EM(ind,n)=myvalues(1);
    end
    % plot requested signals in axes
    for j=1:4
        device=char(Timefig.UIHandles.pickplot_device(j).String(Timefig.UIHandles.pickplot_device(j).Value));
        ind=Timefig.UIHandles.popup_pickplot_index(j).Value;
        channel=Timefig.UIHandles.popup_pickplot_channel(j).Value;
        mode=Timefig.UIHandles.popup_pickplot_mode(j).Value;
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
            case 'Plot Nothing'
                % do nothing
        end
    end
Timefig.MeasurementData=Data;
pause(0.001); 
drawnow
end
Timefig.MeasurementData=Data;
disp('Done')
%%
end