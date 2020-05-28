function [] = Setup_Control_UI ()
%% Create window and buttons
addpath(genpath(pwd))
f_control=figure();
set(f_control,'Name','PCS','NumberTitle','off','OuterPosition',[170,120,230,670],...
    'MenuBar','none','Color',0.95*[1 1 1])
txt_version=uicontrol('Parent',f_control,'Style','text','Position',[10 540 200 80],...
    'String','V2 Nanolab May2020');

% Create setup control object and start communication
addprop(f_control,'Control');
f_control.Control = SetupControl;
%f_control.Control.InitComms;

% Count connected equipments
addprop(f_control,'NumberOfLockins');
addprop(f_control,'NumberOfSourceMeters');
addprop(f_control,'NumberOfElectrometers');
addprop(f_control,'SourceMeterChannels');
addprop(f_control,'UIHandles'); %UIHandles stores all uicontrols
f_control.NumberOfLockins = length(f_control.Control.equipment.LI);
f_control.NumberOfSourceMeters=length(f_control.Control.equipment.SM);
f_control.NumberOfElectrometers=length(f_control.Control.equipment.EM);
f_control.SourceMeterChannels=zeros(1,length(f_control.Control.equipment.SM));
% detect number of SM channels
for ind=1:f_control.NumberOfSourceMeters
    SourceMeterModel=f_control.Control.IDN('SM',ind);
    if strfind(SourceMeterModel,'Model 2611')
        f_control.SourceMeterChannels(ind)=1;
    elseif strfind(SourceMeterModel,'Model 2614B')
        f_control.SourceMeterChannels(ind)=2;
    end
end
% Load Experiments panel
panel_LE=uipanel('Title','Load Experiment','FontSize',10 ...
    ,'Units','pixels','Position',[30 500 160 80]);
LE.p_SelectExperiment = uicontrol('Parent',panel_LE,'Style','PopupMenu','String',ls('.scripts/*.m')...
    ,'Position',[10 30 140 25]);
LE_LoadCallback=@(varargin) run(strcat('.scripts/',LE.p_SelectExperiment.String(LE.p_SelectExperiment.Value,:)));
LE.b_LoadExperiment =  uicontrol('Parent',panel_LE,'Style','PushButton','String','Load Now'...
    ,'Position',[10 5 140 25],'Callback',LE_LoadCallback);

% Laser Controls panel
panel_LasC=uipanel('Title','Laser Control','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 460 160 40]);

% Lock-In Controls panel
panel_LIC=uipanel('Title','Lock-In Control','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 380 160 80]);
f_control.UIHandles.txt_LIFreq=uicontrol('Parent',panel_LIC,'Style','text','Position',[0 5 50 20],'String','f(Hz)');
f_control.UIHandles.edit_LIFreq=uicontrol('Parent',panel_LIC,'Style','edit','String','0','Position',[50 10 40 20],'BackgroundColor','w','Tag','SMBias');
f_control.UIHandles.b_GoToLIFreq=uicontrol('Parent',panel_LIC,'Style','PushButton','String','Go','Position',[100 10 40 20]...
    ,'Callback',@UIHandles_GoToLIFreqCallback);
f_control.UIHandles.t_LIReadout = uicontrol('Parent',panel_LIC,'Style','togglebutton','Position',[5 35 40 25],'String','Read'...
    ,'Callback',@UIHandles_t_LIReadoutCallback);
f_control.UIHandles.edit_LIReadout = uicontrol('Parent',panel_LIC,'Style','edit','Position',[50 35 55 25],'BackgroundColor','k'...
    ,'ForegroundColor','w','String','   ','Tag','LIReadout');
f_control.UIHandles.edit_LIReadoutVar = uicontrol('Parent',panel_LIC,'Style','popupmenu','Position',[110 35 40 25]...
    ,'String',{'f','R','?','X','Y'},'Tag','LIReadout');

% Source-Meter Controls panel
panel_UIHandles=uipanel('Title','Source-Meter Control','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 200 160 180]);

f_control.UIHandles.txt_Vbias=uicontrol('Parent',panel_UIHandles,'Style','text','Position',[0 5 50 25],'String','Vbias');
f_control.UIHandles.edit_Vbias=uicontrol('Parent',panel_UIHandles,'Style','edit','String','0','Position',[50 10 40 25],'BackgroundColor','w','Tag','SMBias');
f_control.UIHandles.b_GoToVbias=uicontrol('Parent',panel_UIHandles,'Style','PushButton','String','Go','Position',[100 10 40 25]...
    ,'Callback',@UIHandles_GoToVbiasCallback);

f_control.UIHandles.txt_Vstep=uicontrol('Parent',panel_UIHandles,'Style','text','Position',[0 35 90 25],'String','Step Size (V)');
f_control.UIHandles.edit_Vstep=uicontrol('Parent',panel_UIHandles,'Style','edit','String','0.01','Position',[100 40 40 25],'BackgroundColor','w');

f_control.UIHandles.txt_Vdelay=uicontrol('Parent',panel_UIHandles,'Style','text','Position',[0 65 90 25],'String','Vdelay (s/step)');
f_control.UIHandles.edit_Vdelay=uicontrol('Parent',panel_UIHandles,'Style','edit','String','0.1','Position',[100 70 40 25],'BackgroundColor','w');

f_control.UIHandles.txt_Index=uicontrol('Parent',panel_UIHandles,'Style','text','Position',[0 125 40 25],'String','Index');
f_control.UIHandles.edit_Index=uicontrol('Parent',panel_UIHandles,'Style','edit','Position',[40 135 20 20],'String','1','Tag','SMIndex');

f_control.UIHandles.txt_Channel=uicontrol('Parent',panel_UIHandles,'Style','text','Position',[70 125 50 25],'String','Channel');
f_control.UIHandles.edit_Channel=uicontrol('Parent',panel_UIHandles,'Style','edit','Position',[120 135 20 20],'String','1','Tag','SMChannel');

f_control.UIHandles.t_Readout = uicontrol('Parent',panel_UIHandles,'Style','togglebutton','Position',[10 100 50 25],'String','Read'...
    ,'Callback',@UIHandles_t_ReadoutCallback);
f_control.UIHandles.txt_Readout = uicontrol('Parent',panel_UIHandles,'Style','edit','Position',[70 100 70 25],'BackgroundColor','k'...
    ,'ForegroundColor','w','String','   ','Tag','SMCurrent');

%Temperature control panel
panel_T=uipanel('Title','ITC 503 Control','FontSize',10,...
    'Units','pixels'...
    ,'Position',[30 5 160 190]);

addprop(f_control,'T'); %T stores all Temperature Controls

%SetT button
f_control.T.txt_T=uicontrol('Parent',panel_T,'Style','text','Position',[0 5 50 25],'String','Set T(K)');
f_control.T.edit_T=uicontrol('Parent',panel_T,'Style','edit','String','0','Position',[50 10 40 25],'BackgroundColor','w','Tag','T');
f_control.T.b_GoToT=uicontrol('Parent',panel_T,'Style','PushButton','String','Go','Position',[100 10 40 25]...
    ,'Callback',@T_GoToTCallback);
%Tolerance button
f_control.T.txt_Tol=uicontrol('Parent',panel_T,'Style','text','Position',[0 35 50 25],'String','Tol(K)');
f_control.T.edit_Tol=uicontrol('Parent',panel_T,'Style','edit','String','0.01','Position',[50 40 40 25],'BackgroundColor','w','Tag','Tol');
%Time of Stabilization button
f_control.T.txt_Time=uicontrol('Parent',panel_T,'Style','text','Position',[0 65 50 25],'String','Time(s)');
f_control.T.edit_Time=uicontrol('Parent',panel_T,'Style','edit','String','0.1','Position',[50 70 40 25],'BackgroundColor','w','Tag','Time');
% Read temp button
f_control.T.t_Readout = uicontrol('Parent',panel_T,'Style','togglebutton','Position',[5 140 70 25],'String','Read T(K)'...
    ,'Callback',@T_t_ReadoutCallback);
f_control.T.txt_Readout = uicontrol('Parent',panel_T,'Style','edit','Position',[80 140 70 25],'BackgroundColor','k'...
    ,'ForegroundColor','w','String','   ','Tag','T');
% Read Setpoint
f_control.T.t_SettReadout = uicontrol('Parent',panel_T,'Style','togglebutton','Position',[5 110 70 25],'String','Set T(K)'...
    ,'Callback',@T_Sett_ReadoutCallback);
f_control.T.txt_SettReadout = uicontrol('Parent',panel_T,'Style','edit','Position',[80 110 70 25],'BackgroundColor','k'...
    ,'ForegroundColor','w','String','   ','Tag','SetT');

%Stabilization Temp
f_control.T.edit_OK=uicontrol('Parent',panel_T,'Style','edit','String','OK','Position',[110 70 40 25],'BackgroundColor','w','Tag','OK');

%% LI Callbacks


%% SM Callbacks
    function [] = UIHandles_t_ReadoutCallback(varargin)
        while f_control.UIHandles.t_Readout.Value
            ind = str2num(f_control.UIHandles.edit_Index.String);
            channel = str2num(f_control.UIHandles.edit_Channel.String);
            if ~isempty('f_control.Control.equipment.SM')
                if length(f_control.Control.equipment.SM)>=ind
                    if channel<=f_control.SourceMeterChannels(ind)
                        r = str2double(f_control.Control.SM_ReadI(ind,channel));
                        f_control.UIHandles.txt_Readout.String = num2str(r(:),'%10.3e');
                    else
                        f_control.UIHandles.t_Readout.Value=0;
                        warning('not enougth channels')
                    end
                else
                    f_control.UIHandles.t_Readout.Value=0;
                    warning('index exceeds number of Source Meters')
                end
            else
                f_control.UIHandles.t_Readout.Value=0;
                warning('No Source Meters found')
            end
            pause(0.01)
        end
    end
    function [] = UIHandles_GoToVbiasCallback(varargin)
        ind = str2num(f_control.UIHandles.edit_Index.String);
        channel = str2num(f_control.UIHandles.edit_Channel.String);
        Vstart=str2num(f_control.Control.SM_ReadV(ind,channel));
        Vend=str2num(f_control.UIHandles.edit_Vbias.String);
        Vstep=str2num(f_control.UIHandles.edit_Vstep.String);
        delay=str2num(f_control.UIHandles.edit_Vdelay.String);
        f_control.Control.SM_RampV(ind,channel,Vstart,Vend,Vstep,delay)
    end
%% ITC Callbacks
    function []=T_t_ReadoutCallback(varargin)
        while f_control.T.t_Readout.Value
            t = f_control.Control.ITC503_ReadT;
            f_control.T.txt_Readout.String = num2str(t(:),'%10.3f');
            pause(1);
        end
    end
    function [] = T_GoToTCallback(varargin)
            SetT=str2num(f_control.T.edit_T.String);
            Tol=str2num(f_control.T.edit_Tol.String);
            Time=str2num(f_control.T.edit_Time.String);
            stabilization=f_control.Control.ITC503_SetT(SetT,Tol,Time);
            if stabilization==0
                f_control.T.edit_OK.String = 'Not OK';
            else
                f_control.T.edit_OK.String = 'OK';
            end
    end
    function []=T_Sett_ReadoutCallback(varargin)
            St=f_control.Control.ITC503_ReadSetT
            f_control.T.txt_SettReadout.String = num2str(St(:),'%10.3f');
    end
end