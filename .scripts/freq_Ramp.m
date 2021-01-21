function [] = freq_Ramp (varargin)
%% add paths & figures
addpath(genpath(pwd))
PCSfig=findobj('Name','PCS');
%
% Create figure
h_freq=figure();
set(h_freq,'OuterPosition',[400 10 1000 670],'Color',0.95*[1 1 1],'ToolBar','figure'...
    ,'NumberTitle','off','Name','freq ramp','MenuBar','figure')
addprop(h_freq,'UIHandles');
addprop(h_freq,'MeasurementData');
% IV panel
panel_IVControls=uipanel('FontSize',10 ...
    ,'Units','pixels','Position',[20 80 120 500]);
% Ramp Buttons
panel_RunButtons=uipanel('Parent',panel_IVControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 300 100 180]);

h_freq.UIHandles.b_RunNow=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Run Now','Position',[10 100 80 25]...
    ,'Callback',@freq_Ramp_RunNow);
h_freq.UIHandles.b_Pause=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Pause','Position',[10 70 80 25]);
h_freq.UIHandles.b_Abort=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Abort','Position',[10 40 80 25]);
h_freq.UIHandles.b_SaveAs=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Save As...','Position',[10 10 80 25]...
    ,'Callback','FileSaveCallBack');

% measurement ramp settings
panel_SweepConfig=uipanel('Parent',panel_IVControls,'FontSize',10 ...
    ,'Units','pixels','Position',[10 10 100 260],'Title','Sweep config');

h_freq.UIHandles.txt_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 210 100 25],'String','Custom ramp');
h_freq.UIHandles.h_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','[0:0.1:1 1:-0.1:0]','Position',[3 195 90 20],'BackgroundColor','w');
h_freq.UIHandles.check_V_Custom=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[5 220 15 15]);

h_freq.UIHandles.txt_V_Limit=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 165 40 20],'String','Limit');
h_freq.UIHandles.h_V_Limit=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 170 50 20],'BackgroundColor','w');

h_freq.UIHandles.txt_V_Delay=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[2 140 40 20],'String','Delay');
h_freq.UIHandles.h_V_Delay=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0.1','Position',[40 145 50 20],'BackgroundColor','w');

h_freq.UIHandles.txt_V_Step=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 115 30 20],'String','Step');
h_freq.UIHandles.h_V_Step=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','5','Position',[40 120 50 20],'BackgroundColor','w');

h_freq.UIHandles.txt_V_Max=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 90 30 20],'String','Max');
h_freq.UIHandles.h_V_Max=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','1000','Position',[40 95 50 20],'BackgroundColor','w');

h_freq.UIHandles.txt_V_Min=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 65 30 20],'String','Min');
h_freq.UIHandles.h_V_Min=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','0','Position',[40 70 50 20],'BackgroundColor','w');

h_freq.UIHandles.txt_I_fix=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[5 40 30 20],'String','I(nA)');
h_freq.UIHandles.h_I_fix=uicontrol('Parent',panel_SweepConfig,'Style','edit','String','1','Position',[40 45 50 20],'BackgroundColor','w');

h_freq.UIHandles.txt_fixcurrent=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[10 20 90 20],'String','fixcurrent');
h_freq.UIHandles.check_fixcurrent=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[10 23 20 20],'Value',0);

h_freq.UIHandles.txt_dual=uicontrol('Parent',panel_SweepConfig,'Style','text','Position',[10 0 90 20],'String','Dual Ramp');
h_freq.UIHandles.check_dual=uicontrol('Parent',panel_SweepConfig,'Style','checkbox','Position',[10 3 20 20],'Value',0);
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
    h_freq.UIHandles.axes(n) = axes('Units','pixels','Position',[200 70 300 220]+dxy(n,:),'XLim',[-1 1]);
    box on; hold all; if n<3; xlabel('Freq(Hz)'); end
    h_freq.UIHandles.pickplot_device(n)=uicontrol('Parent',h_freq,'Style','popupmenu','String',devices,'Position',[200 290 100 25]+dxy(n,:),'BackgroundColor','w');
    h_freq.UIHandles.popup_pickplot_index(n)=uicontrol('Parent',h_freq,'Style','popupmenu','String',indices,'Position',[310 290 50 25]+dxy(n,:),'BackgroundColor','w');
    h_freq.UIHandles.popup_pickplot_text(n)=uicontrol('Parent',h_freq,'Style','text','String','CH','Position',[370 290 30 20]+dxy(n,:),'BackgroundColor',[.95 .95 .95],'FontSize',9);
    h_freq.UIHandles.popup_pickplot_channel(n)=uicontrol('Parent',h_freq,'Style','popupmenu','String',channels,'Position',[400 290 40 25]+dxy(n,:),'BackgroundColor','w');
    h_freq.UIHandles.popup_pickplot_mode(n)=uicontrol('Parent',h_freq,'Style','popupmenu','String',{'I','V'},'Position',[450 290 40 25]+dxy(n,:),'BackgroundColor','w');
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