function [] = Setup_Control_UI ()
    %% Create window and buttons
    addpath(genpath(pwd))
    f_control=figure();
    set(f_control,'Name','PCS','NumberTitle','off','OuterPosition',[170,100,230,550],'MenuBar','none','Color',0.95*[1 1 1])
    txt_Vbias=uicontrol('Parent',f_control,'Style','text','Position',[10 450 200 25],'String','V1 JorgeQ Nov2019');

    % Create setup control object and start communication
    addprop(f_control,'Control');
    f_control.Control = SetupControl;
    f_control.Control.InitComms;

    % Count connected equipments
    addprop(f_control,'NumberOfLockins');
    addprop(f_control,'NumberOfSourceMeters');
    addprop(f_control,'NumberOfElectrometers');
    addprop(f_control,'SourceMeterChannels');
    f_control.NumberOfLockins = length(f_control.Control.equipment.LI);
    f_control.NumberOfSourceMeters=length(f_control.Control.equipment.SM);
    f_control.NumberOfElectrometers=length(f_control.Control.equipment.EM);
    f_control.SourceMeterChannels=zeros(1,length(f_control.Control.equipment.SM));

    % Check number of SM channels
    for ind=1:f_control.NumberOfSourceMeters
        SourceMeterModel=f_control.Control.IDN('SM',ind);
        if strfind(SourceMeterModel,'Model 2611')
            f_control.SourceMeterChannels(ind)=1;
        elseif strfind(SourceMeterModel,'Model 2614B')
            f_control.SourceMeterChannels(ind)=2;
        end
    end

    % Load Experiments panel
    panel_LE=uipanel('Title','Load Experiment','FontSize',10,'Units','pixels','Position',[30 380 160 80]);
    LE.p_SelectExperiment = uicontrol('Parent',panel_LE,'Style','PopupMenu','String',ls('.scripts/*.m'),'Position',[10 30 140 25]);
    LE_LoadCallback=@(varargin) run(strcat('.scripts/',LE.p_SelectExperiment.String(LE.p_SelectExperiment.Value,:)));
    LE.b_LoadExperiment =  uicontrol('Parent',panel_LE,'Style','PushButton','String','Load Now','Position',[10 5 140 25],'Callback',LE_LoadCallback);

    % Source-Meter Controls panel
    SM_panel=uipanel('Title','SourceMeter Control','FontSize',10,'Units','pixels','Position',[30 130 160 180]);
    addprop(f_control,'SM_handles'); %UIHandles stores all uicontrols
    f_control.SM_handles.txt_Vbias=uicontrol('Parent',SM_panel,'Style','text','Position',[0 5 50 25],'String','Vbias');
    f_control.SM_handles.edit_Vbias=uicontrol('Parent',SM_panel,'Style','edit','String','0','Position',[50 10 40 25],'BackgroundColor','w','Tag','SMBias');
    f_control.SM_handles.b_GoToVbias=uicontrol('Parent',SM_panel,'Style','PushButton','String','Go','Position',[100 10 40 25],'Callback',@SM_GoButton_CB);

    f_control.SM_handles.txt_Vstep=uicontrol('Parent',SM_panel,'Style','text','Position',[0 35 90 25],'String','Step Size (V)');
    f_control.SM_handles.edit_Vstep=uicontrol('Parent',SM_panel,'Style','edit','String','0.01','Position',[100 40 40 25],'BackgroundColor','w');

    f_control.SM_handles.txt_Vdelay=uicontrol('Parent',SM_panel,'Style','text','Position',[0 65 90 25],'String','Vdelay (s/step)');
    f_control.SM_handles.edit_Vdelay=uicontrol('Parent',SM_panel,'Style','edit','String','0.1','Position',[100 70 40 25],'BackgroundColor','w');

    f_control.SM_handles.txt_Index=uicontrol('Parent',SM_panel,'Style','text','Position',[0 125 40 25],'String','Index');
    f_control.SM_handles.edit_Index=uicontrol('Parent',SM_panel,'Style','edit','Position',[40 135 20 20],'String','1','Tag','SMIndex');

    f_control.SM_handles.txt_Channel=uicontrol('Parent',SM_panel,'Style','text','Position',[70 125 50 25],'String','Channel');
    f_control.SM_handles.edit_Channel=uicontrol('Parent',SM_panel,'Style','edit','Position',[120 135 20 20],'String','1','Tag','SMChannel');

    f_control.SM_handles.t_Readout = uicontrol('Parent',SM_panel,'Style','togglebutton','Position',[10 100 50 25],'String','Read','Callback',@SM_ReadButton_CB);
    f_control.SM_handles.txt_Readout = uicontrol('Parent',SM_panel,'Style','edit','Position',[70 100 70 25],'BackgroundColor','k','ForegroundColor','w','String','   ','Tag','SMCurrent');

    %% SM Button Callbacks
    function [] = SM_ReadButton_CB(varargin)
        while f_control.SM_handles.t_Readout.Value
            ind = str2double(f_control.SM_handles.edit_Index.String);
            channel = str2double(f_control.SM_handles.edit_Channel.String);
            if ~isempty('f_control.Control.equipment.SM')
                if length(f_control.Control.equipment.SM)>=ind
                    if channel<=f_control.SourceMeterChannels(ind)
                        r = str2double(f_control.Control.SM_ReadI(ind,channel));
                        f_control.SM_handles.txt_Readout.String = num2str(r(:),'%10.3e');
                    else
                        f_control.SM_handles.t_Readout.Value=0;
                        warning('not enougth channels')
                    end
                else
                    f_control.SM_handles.t_Readout.Value=0;
                    warning('index exceeds number of Source Meters')
                end
            else
                f_control.SM_handles.t_Readout.Value=0;
                warning('No Source Meters found')
            end
            pause(0.01)
        end
    end

    function [] = SM_GoButton_CB(varargin)
        ind=str2double(f_control.SM_handles.edit_Index.String);
        channel=str2double(f_control.SM_handles.edit_Channel.String);
        Vstart=str2double(f_control.SM_handles.SM_ReadV(ind,channel));
        Vend=str2double(f_control.SM_handles.edit_Vbias.String);
        Vstep=str2double(f_control.SM_handles.edit_Vstep.String);
        delay=str2double(f_control.SM_handles.edit_Vdelay.String);
        f_control.Control.SM_RampV(ind,channel,Vstart,Vend,Vstep,delay)
    end

end