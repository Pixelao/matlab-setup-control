function [] = IV_Ramp (varargin)
%% add paths & figures
addpath(genpath(pwd))
PCSfig=findobj('Name','PCS');
%
% Create figure
h_IV=figure();
set(h_IV,'OuterPosition',[400 10 1000 670],'Color',0.95*[1 1 1],'ToolBar','figure'...
    ,'NumberTitle','off','Name','I-V ramp','MenuBar','figure')
addprop(h_IV,'UIHandles');
addprop(h_IV,'MeasurementData');
% IV panel
panel_IVControls=uipanel('FontSize',10 ...
    ,'Units','pixels','Position',[20 80 120 500]);
% Ramp Buttons
panel_RunButtons=uipanel('Parent',panel_IVControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 360 100 135]);

h_IV.UIHandles.b_RunNow=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Run Now','Position',[10 100 80 25]...
    ,'Callback',@IV_Ramp_RunNow);
h_IV.UIHandles.b_Pause=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Pause','Position',[10 70 80 25]);
h_IV.UIHandles.b_Abort=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Abort','Position',[10 40 80 25]);
h_IV.UIHandles.b_SaveAs=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Save As...','Position',[10 10 80 25]...
    ,'Callback','FileSaveCallBack');

% measurement ramp settings
panel_SweepConfig=uipanel('Parent',panel_IVControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 10 100 220],'Title','Sweep config');

h_IV.UIHandles.txt_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 170 100 25],'String','Custom ramp');
h_IV.UIHandles.h_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','[0:0.1:1 1:-0.1:0]','Position',[3 155 90 20],'BackgroundColor','w');
h_IV.UIHandles.check_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[5 180 15 15]);

h_IV.UIHandles.txt_V_Limit=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 125 40 20],'String','Limit');
h_IV.UIHandles.h_V_Limit=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 130 50 20],'BackgroundColor','w');

h_IV.UIHandles.txt_V_Delay=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 100 40 20],'String','Delay');
h_IV.UIHandles.h_V_Delay=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 105 50 20],'BackgroundColor','w');

h_IV.UIHandles.txt_V_Step=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 75 30 20],'String','Step');
h_IV.UIHandles.h_V_Step=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 80 50 20],'BackgroundColor','w');

h_IV.UIHandles.txt_V_Max=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 50 30 20],'String','Max');
h_IV.UIHandles.h_V_Max=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','5','Position',[40 55 50 20],'BackgroundColor','w');

h_IV.UIHandles.txt_V_Min=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 25 30 20],'String','Min');
h_IV.UIHandles.h_V_Min=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','-5','Position',[40 30 50 20],'BackgroundColor','w');



h_IV.UIHandles.txt_dual=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[10 0 90 20],'String','Dual Ramp');
h_IV.UIHandles.check_dual=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[10 3 20 20],'Value',1);

% source config
panel_SourceConfig=uipanel('Parent',panel_IVControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 230 100 130],'Title','Source');
V.UIHandles.txt_SourceIV=uicontrol('Parent',panel_SourceConfig,'Style','text','Position',[5 70 50 25],'String','Source');
h_IV.UIHandles.h_SourceIV=uicontrol('Parent',panel_SourceConfig,'Style','popupmenu','String',{'V' 'I'},'Position',[55 75 35 25],'BackgroundColor','w');

h_IV.UIHandles.txt_SourceIndex=uicontrol('Parent',panel_SourceConfig,'Style','text','Position',[5 40 50 25],'String','Index');
h_IV.UIHandles.h_SourceIndex=uicontrol('Parent',panel_SourceConfig,'Style','edit','String','1','Position',[55 45 35 25],'BackgroundColor','w');

h_IV.UIHandles.txt_SourceChannel=uicontrol('Parent',panel_SourceConfig,'Style','text','Position',[5 10 50 25],'String','Channel');
h_IV.UIHandles.h_SourceChannel=uicontrol('Parent',panel_SourceConfig,'Style','edit','String','1','Position',[55 15 35 25],'BackgroundColor','w');

% device options to plot
devices={'SourceMeter','Electrometer','Lock-In','Plot Nothing'};
if PCSfig.NumberOfSourceMeters>0 | PCSfig.NumberOfLockins>0 | PCSfig.NumberOfElectrometers>0
    indices = num2str([1:max([PCSfig.NumberOfSourceMeters PCSfig.NumberOfLockins PCSfig.NumberOfElectrometers])]');
else
    indices='1';
end
if PCSfig.NumberOfSourceMeters>0
    channels = num2str([1:max(PCSfig.SourceMeterChannels)]');
else
    channels='1';
end
% plot axes
dxy=[0 0 0 0;
    400 0 0 0;
    0 280 0 0;
    400 280 0 0];
for n=1:4
    h_IV.UIHandles.axes(n) = axes('Units','pixels','Position',[200 70 300 220]+dxy(n,:),'XLim',[-1 1]);
    box on; hold all; if n<3; xlabel('Bias Voltage/Current (V/A)'); end
    h_IV.UIHandles.pickplot_device(n)=uicontrol('Parent',h_IV,'Style','popupmenu','String',devices,'Position',[200 290 100 25]+dxy(n,:),'BackgroundColor','w');
    h_IV.UIHandles.popup_pickplot_index(n)=uicontrol('Parent',h_IV,'Style','popupmenu','String',indices,'Position',[310 290 50 25]+dxy(n,:),'BackgroundColor','w');
    h_IV.UIHandles.popup_pickplot_text(n)=uicontrol('Parent',h_IV,'Style','text','String','CH','Position',[370 290 30 20]+dxy(n,:),'BackgroundColor',[.95 .95 .95],'FontSize',9);
    h_IV.UIHandles.popup_pickplot_channel(n)=uicontrol('Parent',h_IV,'Style','popupmenu','String',channels,'Position',[400 290 40 25]+dxy(n,:),'BackgroundColor','w');
    h_IV.UIHandles.popup_pickplot_mode(n)=uicontrol('Parent',h_IV,'Style','popupmenu','String',{'I','V'},'Position',[450 290 40 25]+dxy(n,:),'BackgroundColor','w');
end


%callbacks
    function [] = FileSaveCallBack(varargin)
        h=gcf;
        MeasurementData=h.MeasurementData;
        uisave('MeasurementData');
    end
end
%%
function [] = WL_Ramp (varargin)
%% add paths & figures
addpath(genpath(pwd))
PCSfig=findobj('Name','PCS');
%
% Create figure
h_WL=figure();
set(h_WL,'OuterPosition',[400 10 1000 670],'Color',0.95*[1 1 1],'ToolBar','figure','NumberTitle','off','Name','WL ramp','MenuBar','figure')
addprop(h_WL,'UIHandles');
addprop(h_WL,'MeasurementData');
% IV panel
panel_IVControls=uipanel('FontSize',10,'Units','pixels','Position',[20 80 120 500]);
% Ramp Buttons
panel_RunButtons=uipanel('Parent',panel_IVControls,'FontSize',10,'Units','pixels','Position',[10 360 100 135]);

h_WL.UIHandles.b_RunNow=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Run Now','Position',[10 100 80 25],'Callback',@WL_Ramp_RunNow);
h_WL.UIHandles.b_Pause=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Pause','Position',[10 70 80 25]);
h_WL.UIHandles.b_Abort=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Abort','Position',[10 40 80 25]);
h_WL.UIHandles.b_SaveAs=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Save As...','Position',[10 10 80 25],'Callback','FileSaveCallBack');

% measurement ramp settings
panel_SweepConfig=uipanel('Parent',panel_IVControls,'FontSize',10,'Units','pixels','Position',[10 10 100 220],'Title','Sweep config');

h_WL.UIHandles.txt_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 170 100 25],'String','Custom ramp');
h_WL.UIHandles.h_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','[0:0.1:1 1:-0.1:0]','Position',[3 155 90 20],'BackgroundColor','w');
h_WL.UIHandles.check_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[5 180 15 15]);

h_WL.UIHandles.txt_V_Limit=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 125 40 20],'String','Limit');
h_WL.UIHandles.h_V_Limit=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 130 50 20],'BackgroundColor','w');

h_WL.UIHandles.txt_V_Delay=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 100 40 20],'String','Delay');
h_WL.UIHandles.h_V_Delay=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 105 50 20],'BackgroundColor','w');

h_WL.UIHandles.txt_V_Step=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 75 30 20],'String','Step');
h_WL.UIHandles.h_V_Step=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','5','Position',[40 80 50 20],'BackgroundColor','w');

h_WL.UIHandles.txt_V_Max=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 50 30 20],'String','Max');
h_WL.UIHandles.h_V_Max=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','1000','Position',[40 55 50 20],'BackgroundColor','w');

h_WL.UIHandles.txt_V_Min=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 25 30 20],'String','Min');
h_WL.UIHandles.h_V_Min=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','400','Position',[40 30 50 20],'BackgroundColor','w');



h_WL.UIHandles.txt_dual=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[10 0 90 20],'String','Dual Ramp');
h_WL.UIHandles.check_dual=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[10 3 20 20],'Value',0);
% device options to plot
devices={'SourceMeter','Electrometer','Lock-In','Plot Nothing'};
if PCSfig.NumberOfSourceMeters>0 | PCSfig.NumberOfLockins>0 | PCSfig.NumberOfElectrometers>0
    indices = num2str([1:max([PCSfig.NumberOfSourceMeters PCSfig.NumberOfLockins PCSfig.NumberOfElectrometers])]');
else
    indices='1';
end
if PCSfig.NumberOfSourceMeters>0
    channels = num2str([1:max(PCSfig.SourceMeterChannels)]');
else
    channels='1';
end
% plot axes
dxy=[0 0 0 0;
    400 0 0 0;
    0 280 0 0;
    400 280 0 0];
for n=1:4
    h_WL.UIHandles.axes(n) = axes('Units','pixels','Position',[200 70 300 220]+dxy(n,:),'XLim',[-1 1]);
    box on; hold all; if n<3; xlabel('Bias Voltage/Current (V/A)'); end
    h_WL.UIHandles.pickplot_device(n)=uicontrol('Parent',h_WL,'Style','popupmenu','String',devices,'Position',[200 290 100 25]+dxy(n,:),'BackgroundColor','w');
    h_WL.UIHandles.popup_pickplot_index(n)=uicontrol('Parent',h_WL,'Style','popupmenu','String',indices,'Position',[310 290 50 25]+dxy(n,:),'BackgroundColor','w');
    h_WL.UIHandles.popup_pickplot_text(n)=uicontrol('Parent',h_WL,'Style','text','String','CH','Position',[370 290 30 20]+dxy(n,:),'BackgroundColor',[.95 .95 .95],'FontSize',9);
    h_WL.UIHandles.popup_pickplot_channel(n)=uicontrol('Parent',h_WL,'Style','popupmenu','String',channels,'Position',[400 290 40 25]+dxy(n,:),'BackgroundColor','w');
    h_WL.UIHandles.popup_pickplot_mode(n)=uicontrol('Parent',h_WL,'Style','popupmenu','String',{'I','V'},'Position',[450 290 40 25]+dxy(n,:),'BackgroundColor','w');
end


%callbacks
function [] = FileSaveCallBack(varargin)
h=gcf;
[filename, pathname] = uiputfile('*.fig', 'Save the file as');
    if isnumeric(filename)
       disp('User pushed cancel. Not saving anything')
    else
       savefig(h,fullfile(pathname, filename))
    end
end
end