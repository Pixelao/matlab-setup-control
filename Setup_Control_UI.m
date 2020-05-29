function [] = Setup_Control_UI ()

    %% Create window and buttons
    addpath(genpath(pwd))
    window = figure();
    set(window,'Name','PCS','NumberTitle','off','Position',[30 30 400 430],'MenuBar','none','Color',0.95*[1 1 1])
    uicontrol('Parent',window,'Style','text','Position',[30 340 160 80],'FontSize',11,'String','V2 Nanolab May 2020');
    
    % Create setup control object and start communication
    addprop(window,'Control');
    window.Control = SetupControl;
    window.Control.InitComms;
    
    % Count connected equipments
    addprop(window,'NumberOfLockins');
    addprop(window,'NumberOfSourceMeters');
    addprop(window,'NumberOfElectrometers');
    addprop(window,'SourceMeterChannels');
    addprop(window,'T'); %T stores all Temperature Controls
    addprop(window,'UIHandles'); %UIHandles stores all uicontrols
    window.NumberOfLockins = length(window.Control.equipment.LI);
    window.NumberOfSourceMeters = length(window.Control.equipment.SM);
    window.NumberOfElectrometers = length(window.Control.equipment.EM);
    window.SourceMeterChannels = zeros(1,length(window.Control.equipment.SM));
    
    % Detect number of SM channels
    for ind = 1:window.NumberOfSourceMeters
        SourceMeterModel=window.Control.IDN('SM',ind);
        if contains(SourceMeterModel,'Model 2611')
            window.SourceMeterChannels(ind)=1;
        elseif contains(SourceMeterModel,'Model 2614B')
            window.SourceMeterChannels(ind)=2;
        end
    end
    
    % LE Panel (Load Experiments)
    panel_LE = uipanel('Title','Load Experiment','FontSize',10,'Units','pixels','Position',[30 310 160 80]);
    LE.p_SelectExperiment = uicontrol('Parent',panel_LE,'Style','PopupMenu','String',ls('.scripts/*.m'),'Position',[10 30 140 25]);
    LE_loadnow_callback = @(varargin) run(strcat('.scripts/',LE.p_SelectExperiment.String(LE.p_SelectExperiment.Value,:)));
    LE.b_LoadExperiment = uicontrol('Parent',panel_LE,'Style','PushButton','String','Load Now','Position',[10 5 140 25],'Callback',LE_loadnow_callback);
    
    % LA PANEL (Laser)
    panel_LA = uipanel('Title','Laser Control','FontSize',10,'Units','pixels','Position',[200 220 160 130]);
    window.UIHandles.t_LApercent = uicontrol('Parent',panel_LA,'Style','text','Position',[7 7 55 20],'String','POWER %');
    window.UIHandles.e_LAPower = uicontrol('Parent',panel_LA,'Style','edit','String','0','Position',[65 10 40 20],'BackgroundColor','w','Tag','LABias');
    window.UIHandles.b_GoToLAPower = uicontrol('Parent',panel_LA,'Style','PushButton','String','Go','Position',[110 7 40 25],'Callback',@LA_go_callback);
    window.UIHandles.t_LApercent = uicontrol('Parent',panel_LA,'Style','text','Position',[0 80 100 25],'String','Emission');
    window.UIHandles.b_LAOnPower = uicontrol('Parent',panel_LA,'Style','PushButton','String','ON','Position',[5 65 40 25],'BackgroundColor','green','ForegroundColor','black','Callback',@LA_on_callback);
    window.UIHandles.b_LAOffPower = uicontrol('Parent',panel_LA,'Style','PushButton','String','OFF','Position',[50 65 40 25],'BackgroundColor','red','ForegroundColor','white','Callback',@LA_off_callback);
    window.UIHandles.t_LARead = uicontrol('Parent',panel_LA,'Style','togglebutton','Position',[5 35 40 25],'String','Read','Callback',@LA_read_callback);
    window.UIHandles.e_LAReadout = uicontrol('Parent',panel_LA,'Style','edit','Position',[50 35 100 25],'BackgroundColor','k','ForegroundColor','w','String','   ','Tag','LAReadout');
    
    % LI Panel (Lock Ins)
    panel_LIC = uipanel('Title','Lock-In Control','FontSize',10,'Units','pixels','Position',[30 220 160 80]);
    window.UIHandles.txt_LIFreq = uicontrol('Parent',panel_LIC,'Style','text','Position',[7 7 55 20],'String','f(Hz)');
    window.UIHandles.edit_LIFreq = uicontrol('Parent',panel_LIC,'Style','edit','String','0','Position',[65 10 40 20],'BackgroundColor','w','Tag','LIBias');
    window.UIHandles.b_GoToLIFreq = uicontrol('Parent',panel_LIC,'Style','PushButton','String','Go','Position',[110 7 40 25],'Callback',@LI_go_callback);
    window.UIHandles.t_LIReadout = uicontrol('Parent',panel_LIC,'Style','togglebutton','Position',[5 35 40 25],'String','Read','Callback',@LI_read_callback);
    window.UIHandles.edit_LIReadout = uicontrol('Parent',panel_LIC,'Style','edit','Position',[50 35 55 25],'BackgroundColor','k','ForegroundColor','w','String','   ','Tag','LIReadout');
    window.UIHandles.edit_LIReadoutVar = uicontrol('Parent',panel_LIC,'Style','popupmenu','Position',[110 35 40 25],'String',{'f','R','?','X','Y'},'Tag','LIReadout');
    
    %% SM Panel (Source Meters)
    panel_SM = uipanel('Title','Source-Meter Control','FontSize',10,'Units','pixels','Position',[30 20 160 190]);
    window.UIHandles.txt_Vbias = uicontrol('Parent',panel_SM,'Style','text','Position',[0 5 50 25],'String','Vbias');
    window.UIHandles.edit_Vbias = uicontrol('Parent',panel_SM,'Style','edit','String','0','Position',[50 10 40 25],'BackgroundColor','w','Tag','SMBias');
    window.UIHandles.b_GoToVbias = uicontrol('Parent',panel_SM,'Style','PushButton','String','Go','Position',[100 10 40 25],'Callback',@SM_go_callback);
    window.UIHandles.txt_Vstep = uicontrol('Parent',panel_SM,'Style','text','Position',[0 35 90 25],'String','Step Size (V)');
    window.UIHandles.edit_Vstep = uicontrol('Parent',panel_SM,'Style','edit','String','0.01','Position',[100 40 40 25],'BackgroundColor','w');
    window.UIHandles.txt_Vdelay = uicontrol('Parent',panel_SM,'Style','text','Position',[0 65 90 25],'String','Vdelay (s/step)');
    window.UIHandles.edit_Vdelay = uicontrol('Parent',panel_SM,'Style','edit','String','0.1','Position',[100 70 40 25],'BackgroundColor','w');
    window.UIHandles.txt_Index = uicontrol('Parent',panel_SM,'Style','text','Position',[0 125 40 25],'String','Index');
    window.UIHandles.edit_Index = uicontrol('Parent',panel_SM,'Style','edit','Position',[40 135 20 20],'String','1','Tag','SMIndex');
    window.UIHandles.txt_Channel = uicontrol('Parent',panel_SM,'Style','text','Position',[70 125 50 25],'String','Channel');
    window.UIHandles.edit_Channel = uicontrol('Parent',panel_SM,'Style','edit','Position',[120 135 20 20],'String','1','Tag','SMChannel');
    window.UIHandles.t_Readout = uicontrol('Parent',panel_SM,'Style','togglebutton','Position',[10 100 50 25],'String','Read','Callback',@SM_read_callback);
    window.UIHandles.txt_Readout = uicontrol('Parent',panel_SM,'Style','edit','Position',[70 100 70 25],'BackgroundColor','k','ForegroundColor','w','String','   ','Tag','SMCurrent');
    
    %%TC Panel (Temp Controller)
    panel_TC = uipanel('Title','ITC 503 Control','FontSize',10,'Units','pixels','Position',[200 20 160 190]);
    window.T.txt_T = uicontrol('Parent',panel_TC,'Style','text','Position',[0 5 50 25],'String','Set T(K)');
    window.T.edit_T = uicontrol('Parent',panel_TC,'Style','edit','String','0','Position',[50 10 40 25],'BackgroundColor','w','Tag','T');
    window.T.b_GoToT = uicontrol('Parent',panel_TC,'Style','PushButton','String','Go','Position',[100 10 40 25],'Callback',@TC_go_callback);
    window.T.txt_Tol = uicontrol('Parent',panel_TC,'Style','text','Position',[0 35 50 25],'String','Tol(K)');
    window.T.edit_Tol = uicontrol('Parent',panel_TC,'Style','edit','String','0.01','Position',[50 40 40 25],'BackgroundColor','w','Tag','Tol');
    window.T.txt_Time = uicontrol('Parent',panel_TC,'Style','text','Position',[0 65 50 25],'String','Time(s)');
    window.T.edit_Time = uicontrol('Parent',panel_TC,'Style','edit','String','0.1','Position',[50 70 40 25],'BackgroundColor','w','Tag','Time');
    window.T.t_Readout = uicontrol('Parent',panel_TC,'Style','togglebutton','Position',[5 140 70 25],'String','Read T(K)','Callback',@TC_read_callback);
    window.T.txt_Readout = uicontrol('Parent',panel_TC,'Style','edit','Position',[80 140 70 25],'BackgroundColor','k','ForegroundColor','w','String','   ','Tag','T');
    window.T.t_SettReadout = uicontrol('Parent',panel_TC,'Style','togglebutton','Position',[5 110 70 25],'String','Set T(K)','Callback',@TC_set_callback);
    window.T.txt_SettReadout = uicontrol('Parent',panel_TC,'Style','edit','Position',[80 110 70 25],'BackgroundColor','k','ForegroundColor','w','String','   ','Tag','SetT');
    window.T.edit_OK = uicontrol('Parent',panel_TC,'Style','edit','String','OK','Position',[110 70 40 25],'BackgroundColor','w','Tag','OK');
    
    %% SM Callbacks
        function [] = SM_read_callback(varargin)
            while window.UIHandles.t_Readout.Value
                ind = str2double(window.UIHandles.edit_Index.String);
                channel = str2double(window.UIHandles.edit_Channel.String);
                if ~isempty('window.Control.equipment.SM')
                    if length(window.Control.equipment.SM)>=ind
                        if channel<=window.SourceMeterChannels(ind)
                            r = str2double(window.Control.SM_ReadI(ind,channel));
                            window.UIHandles.txt_Readout.String = num2str(r(:),'%10.3e');
                        else
                            window.UIHandles.t_Readout.Value=0;
                            warning('not enougth channels')
                        end
                    else
                        window.UIHandles.t_Readout.Value=0;
                        warning('index exceeds number of Source Meters')
                    end
                else
                    window.UIHandles.t_Readout.Value=0;
                    warning('No Source Meters found')
                end
                pause(0.01)
            end
        end
    
        function [] = SM_go_callback(varargin)
            ind = str2double(window.UIHandles.edit_Index.String);
            channel = str2double(window.UIHandles.edit_Channel.String);
            Vstart = str2double(window.Control.SM_ReadV(ind,channel));
            Vend = str2double(window.UIHandles.edit_Vbias.String);
            Vstep = str2double(window.UIHandles.edit_Vstep.String);
            delay = str2double(window.UIHandles.edit_Vdelay.String);
            window.Control.SM_RampV(ind,channel,Vstart,Vend,Vstep,delay)
        end
    
    %% TC Callbacks
        function [] = TC_read_callback(varargin)
            while window.T.t_Readout.Value
                t = window.Control.ITC503_ReadT;
                window.T.txt_Readout.String = num2str(t(:),'%10.3f');
                pause(0.2);
            end
        end
        
        function [] = TC_go_callback(varargin)
                SetT = str2double(window.T.edit_T.String);
                Tol = str2double(window.T.edit_Tol.String);
                Time = str2double(window.T.edit_Time.String);
                stabilization = window.Control.ITC503_SetT(SetT,Tol,Time);
                x = stabilization;
                if x==0
                    window.T.edit_OK.String = 'Not OK';
                else
                    window.T.edit_OK.String = 'OK';
                end
        end
    
        function [] = TC_set_callback(varargin)
                St = window.Control.ITC503_ReadSetT;
                window.T.txt_SettReadout.String = num2str(St(:),'%10.3f');
        end
    
    
    %% LI Callbacks
    % TODO
    
    %% LASER Callbacks
        function [] = LA_read_callback(varargin)
            while window.UIHandles.t_LARead.Value
                p = window.Control.LAread;
                window.UIHandles.e_LAReadout.String = str2double(p);
                pause(1);
            end
        end
    
        function [] = LA_go_callback(varargin)
            pw=str2double(window.UIHandles.e_LAPower.String);
            window.Control.LAgo(pw)
        end
    
        function [] = LA_on_callback(varargin)
            window.Control.LAon()
        end
    
        function [] = LA_off_callback(varargin)
            window.Control.LAoff()
        end
    end