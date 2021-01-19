function [] = TimePlot_RunNow (varargin)
%%
addpath(genpath(pwd))
% get figure UI handles
PCSfig=findobj('Name','PCS');
Timefig=findobj('Name','Time_Plot');

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
    set(ax(j),'xlim',[0 1])
end

%% do ramp and plot
% initialize data variable
MaxSMIndex=PCSfig.NumberOfSourceMeters;
MaxChannel=max(PCSfig.SourceMeterChannels);
Data.SM.V=NaN(MaxSMIndex,MaxChannel,1000);
Data.SM.I=NaN(MaxSMIndex,MaxChannel,1000);
Data.EM=NaN(MaxSMIndex,1000);
Data.LI=NaN(MaxSMIndex,MaxChannel,1000);
Data.PW=NaN(1,1,1000);
Data.SP=NaN(1,1,1000);
Data.time=NaN(1,1000);
% initialize electrometers
if PCSfig.NumberOfElectrometers>0
    for ind=1:PCSfig.NumberOfElectrometers
        PCSfig.Control.EM_Init(ind,1) % init EMs in voltage sensing mode
    end
end
tic
n=0;
while Timefig.UIHandles.b_Abort.Value == 0
    if Timefig.UIHandles.b_Abort.Value == 1
        warning('Measurement aborted by user')
        return
    end
    while Timefig.UIHandles.b_Pause.Value == 1
        pause(0.1)
    end
    n=n+1;
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
    %Data.SP(n)=PCSfig.Control.SPread;
    %measure time
    Data.time(n)=toc;
    % plot requested signals in axes
    for j=1:4
        device=char(Timefig.UIHandles.pickplot_device(j).String(Timefig.UIHandles.pickplot_device(j).Value));
        ind=Timefig.UIHandles.popup_pickplot_index(j).Value;
        channel=Timefig.UIHandles.popup_pickplot_channel(j).Value;
        mode=Timefig.UIHandles.popup_pickplot_mode(j).Value;
        set(draw(j),'xdata',Data.time(1,:))
        set(ax(j),'xlim',[0 max(Data.time(1,:))])
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
Timefig.MeasurementData=Data; 
drawnow
end
Timefig.MeasurementData=Data;
disp('Done')
%%
end