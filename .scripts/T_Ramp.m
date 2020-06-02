function [] = T_Ramp (varargin)
%% add paths & figures
addpath(genpath(pwd))
PCSfig=findobj('Name','PCS');
%
% Create figure
h_T=figure();
set(h_T,'OuterPosition',[400 10 1000 670],'Color',0.95*[1 1 1],'ToolBar','figure'...
    ,'NumberTitle','off','Name','T ramp','MenuBar','figure')
addprop(h_T,'UIHandles');
addprop(h_T,'MeasurementData');
% IV panel
panel_TControls=uipanel('FontSize',10 ...
    ,'Units','pixels','Position',[20 80 120 500]);
% Ramp Buttons
panel_RunButtons=uipanel('Parent',panel_TControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 360 100 135]);

h_T.UIHandles.b_RunNow=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Run Now','Position',[10 100 80 25]...
    ,'Callback',@T_Ramp_RunNow);
h_T.UIHandles.b_Pause=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Pause','Position',[10 70 80 25]);
h_T.UIHandles.b_Abort=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Abort','Position',[10 40 80 25]);
h_T.UIHandles.b_SaveAs=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Save As...','Position',[10 10 80 25]...
    ,'Callback','FileSaveCallBack');

% measurement ramp settings
panel_SweepConfig=uipanel('Parent',panel_TControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 10 100 300],'Title','Sweep config');

h_T.UIHandles.txt_T_Custom=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 250 100 25],'String','Custom ramp');
h_T.UIHandles.h_T_Custom=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','[0:0.1:1 1:-0.1:0]','Position',[3 230 90 20],'BackgroundColor','w');
h_T.UIHandles.check_T_Custom=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[5 260 15 15]);

h_T.UIHandles.txt_Time=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 200 40 20],'String','Time(s)');
h_T.UIHandles.h_Time=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','20','Position',[40 205 50 20],'BackgroundColor','w');

h_T.UIHandles.txt_Tol=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 170 40 20],'String','Tol(K)');
h_T.UIHandles.h_Tol=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 175 50 20],'BackgroundColor','w');

h_T.UIHandles.txt_Delay=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 10 40 20],'String','Delay');
h_T.UIHandles.h_Delay=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 15 50 20],'BackgroundColor','w');

h_T.UIHandles.txt_Step=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 145 30 20],'String','Step');
h_T.UIHandles.h_Step=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','5','Position',[40 150 50 20],'BackgroundColor','w');

h_T.UIHandles.txt_T_Max=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 120 30 20],'String','Max');
h_T.UIHandles.h_T_Max=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','300','Position',[40 125 50 20],'BackgroundColor','w');

h_T.UIHandles.txt_T_Min=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 95 30 20],'String','Min');
h_T.UIHandles.h_T_Min=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','10','Position',[40 100 50 20],'BackgroundColor','w');



h_T.UIHandles.txt_dual=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[10 0 90 20],'String','Dual Ramp');
h_T.UIHandles.check_dual=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[10 3 20 20],'Value',0);
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
    h_T.UIHandles.axes(n) = axes('Units','pixels','Position',[200 70 300 220]+dxy(n,:),'XLim',[-1 1]);
    box on; hold all; if n<3; xlabel('Bias Voltage/Current (V/A)'); end
    h_T.UIHandles.pickplot_device(n)=uicontrol('Parent',h_T,'Style','popupmenu','String',devices,'Position',[200 290 100 25]+dxy(n,:),'BackgroundColor','w');
    h_T.UIHandles.popup_pickplot_index(n)=uicontrol('Parent',h_T,'Style','popupmenu','String',indices,'Position',[310 290 50 25]+dxy(n,:),'BackgroundColor','w');
    h_T.UIHandles.popup_pickplot_text(n)=uicontrol('Parent',h_T,'Style','text','String','CH','Position',[370 290 30 20]+dxy(n,:),'BackgroundColor',[.95 .95 .95],'FontSize',9);
    h_T.UIHandles.popup_pickplot_channel(n)=uicontrol('Parent',h_T,'Style','popupmenu','String',channels,'Position',[400 290 40 25]+dxy(n,:),'BackgroundColor','w');
    h_T.UIHandles.popup_pickplot_mode(n)=uicontrol('Parent',h_T,'Style','popupmenu','String',{'I','V'},'Position',[450 290 40 25]+dxy(n,:),'BackgroundColor','w');
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