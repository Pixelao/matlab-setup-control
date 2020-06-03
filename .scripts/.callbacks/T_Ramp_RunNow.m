function [] = T_Ramp_RunNow (varargin)
%%
addpath(genpath(pwd))
% get figure UI handles
PCSfig=findobj('Name','PCS');
Tfig=findobj('Name','T ramp');
% create sweep WL vector
if Tfig.UIHandles.check_WL_Custom.Value
    eval(strcat('SweepRamp =',Tfig.UIHandles.h_WL_Custom.String,';'));
    SweepDelay = str2num(Tfig.UIHandles.h_WL_Delay.String);
else
    SweepMin = str2num(Tfig.UIHandles.h_WL_Min.String);
    SweepMmax = str2num(Tfig.UIHandles.h_WL_Max.String);
    SweepStep = str2num(Tfig.UIHandles.h_WL_Step.String);
    SweepDelay = str2num(Tfig.UIHandles.h_WL_Delay.String);
    SweepLimit = str2num(Tfig.UIHandles.h_WL_Limit.String);
    SweepRamp = [SweepMin:SweepStep:SweepMmax];
end

% create sweep T ramp

if Tfig.UIHandles.check_T_Custom.Value
    eval(strcat('SweepRamp =',Tfig.UIHandles.h_T_Custom.String,';'));
    sweepTolT=str2num(Tfig.UIHandles.h_Tol.String);
    sweepTimeT=str2num(Tfig.UIHandles.h_Time.String);
else
    SweepMinT = str2num(Tfig.UIHandles.h_T_Min.String);
    SweepMmaxT = str2num(Tfig.UIHandles.h_T_Max.String);
    SweepStepT = str2num(Tfig.UIHandles.h_T_Step.String);
    SweepRampT = [SweepMinT:SweepStepT:SweepMmaxT];
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
    ax(j)=Tfig.UIHandles.axes(j);
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
Data.T=NaN(1,1,length(SweepRampT));
% initialize electrometers
if PCSfig.NumberOfElectrometers>0
    for ind=1:PCSfig.NumberOfElectrometers
        PCSfig.Control.EM_Init(ind,1) % init EMs in voltage sensing mode
    end
end
for m=1:length(SweepRampT)
    if Tfig.UIHandles.b_Abort.Value == 1
        Tfig.UIHandles.b_Abort.Value = 0;
        warning('Measurement aborted by user')
        return
    end
    while Tfig.UIHandles.b_Pause.Value == 1
        pause(0.1)
    end
    SetT=SweepRampT(m);
    Tol=sweepTolT;
    Time=sweepTolT;
    Data.T(m)=SetT;
    PCSfig.Control.ITC503_SetT(SetT,Tol,Time);
    for n=1:length(SweepRamp)
        if Tfig.UIHandles.b_Abort.Value == 1
            Tfig.UIHandles.b_Abort.Value = 0;
            warning('Measurement aborted by user')
            return
        end
        while Tfig.UIHandles.b_Pause.Value == 1
            pause(0.1)
        end
        % set source to next step
        Data.WL(n)=PCSfig.Control.GoToWL(SweepRamp(n));
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
        % plot requested signals in axes
        for j=1:4
            device=char(Tfig.UIHandles.pickplot_device(j).String(Tfig.UIHandles.pickplot_device(j).Value));
            ind=Tfig.UIHandles.popup_pickplot_index(j).Value;
            channel=Tfig.UIHandles.popup_pickplot_channel(j).Value;
            mode=Tfig.UIHandles.popup_pickplot_mode(j).Value;
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
    Tfig.MeasurementData=Data;
    pause(0.001); 
    drawnow
    end
    Tfig.MeasurementData=Data;
    disp('Done')
end
%%
end