function [] = f_RunIV4T_ISource (varargin)
        % insert custom code here
        %%
        global RunIV2
        h_IV=figure();
        set(h_IV,'OuterPosition',[600 100 1000 830],'Color',0.95*[1 1 1],'ToolBar','figure','NumberTitle','off','Name','I-V ramp')
        
        %Voltage controls
        panel_VoltageSource=uipanel('Title','Source Voltage','FontSize',10 ...
            ,'Units','pixels' ...
            ,'Position',[15 290 130 240]);
        RunIV2.txt_V_Step=uicontrol('Parent',panel_VoltageSource,'Style','text','Position',[10 115 50 25],'String','V Step');
        RunIV2.h_V_Step=uicontrol('Parent',panel_VoltageSource,'Style','edit','String','0.1','Position',[60 120 40 25],'BackgroundColor','w');
        
        RunIV2.txt_V_Min=uicontrol('Parent',panel_VoltageSource,'Style','text','Position',[10 55 50 25],'String','V Min');
        RunIV2.h_V_Min=uicontrol('Parent',panel_VoltageSource,'Style','edit','String','-5','Position',[60 60 40 25],'BackgroundColor','w');
        
        RunIV2.txt_V_Max=uicontrol('Parent',panel_VoltageSource,'Style','text','Position',[10 85 50 25],'String','V Max');
        RunIV2.h_V_Max=uicontrol('Parent',panel_VoltageSource,'Style','edit','String','5','Position',[60 90 40 25],'BackgroundColor','w');
        
        RunIV2.txt_V_Custom=uicontrol('Parent',panel_VoltageSource,'Style','text','Position',[10 180 100 25],'String','Custom V Range');
        RunIV2.h_V_Custom=uicontrol('Parent',panel_VoltageSource,'Style','edit','String','[0:0.1:1 1:-0.1:-1 -1:0.1:0]','Position',[30 160 80 25],'BackgroundColor','w');
        RunIV2.check_V_Custom=uicontrol('Parent',panel_VoltageSource,'Style','checkbox','Position',[10 160 20 20],'BackgroundColor','w');
        
        RunIV2.txt_dual=uicontrol('Parent',panel_VoltageSource,'Style','text','Position',[15 22 90 25],'String','Dual Ramp');
        RunIV2.check_dual=uicontrol('Parent',panel_VoltageSource,'Style','checkbox','Position',[10 30 20 20],'BackgroundColor','w','Value',1);
        
        %Current controls
        panel_CurrentSource=uipanel('Title','Source Current','FontSize',10 ...
            ,'Units','pixels' ...
            ,'Position',[15 30 130 240]);
        RunIV2.txt_I_Step=uicontrol('Parent',panel_CurrentSource,'Style','text','Position',[10 115 50 25],'String','I Step');
        RunIV2.h_I_Step=uicontrol('Parent',panel_CurrentSource,'Style','edit','String','1e-10','Position',[60 120 40 25],'BackgroundColor','w');
        
        RunIV2.txt_I_Min=uicontrol('Parent',panel_CurrentSource,'Style','text','Position',[10 55 50 25],'String','I Min');
        RunIV2.h_I_Min=uicontrol('Parent',panel_CurrentSource,'Style','edit','String','-1e-9','Position',[60 60 40 25],'BackgroundColor','w');
        
        RunIV2.txt_I_Max=uicontrol('Parent',panel_CurrentSource,'Style','text','Position',[10 85 50 25],'String','I Max');
        RunIV2.h_I_Max=uicontrol('Parent',panel_CurrentSource,'Style','edit','String','1e-9','Position',[60 90 40 25],'BackgroundColor','w');
        
        RunIV2.txt_I_Custom=uicontrol('Parent',panel_CurrentSource,'Style','text','Position',[10 180 100 25],'String','Custom I Range');
        RunIV2.h_I_Custom=uicontrol('Parent',panel_CurrentSource,'Style','edit','String','1e-9*[0:0.1:1 1:-0.1:-1 -1:0.1:0]','Position',[30 160 80 25],'BackgroundColor','w');
        RunIV2.check_I_Custom=uicontrol('Parent',panel_CurrentSource,'Style','checkbox','Position',[10 160 20 20],'BackgroundColor','w');
        
        RunIV2.txt_Idual=uicontrol('Parent',panel_CurrentSource,'Style','text','Position',[15 22 90 25],'String','Dual Ramp');
        RunIV2.check_Idual=uicontrol('Parent',panel_CurrentSource,'Style','checkbox','Position',[10 30 20 20]...
            ,'BackgroundColor','w','Value',1);
        
        %Run buttons
        panel_RunButtons=uipanel('Title','Runtime Controls','FontSize',10 ...
            ,'Units','pixels' ...
            ,'Position',[15 550 130 150]);
        
        RunIV2.b_RunNow=uicontrol('Parent',panel_RunButtons,'Style','PushButton','String','Run Now','Position',[10 100 100 25]...
            ,'Callback',@f_RunIV4T_RunNow);
        RunIV2.b_Pause=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Pause','Position',[10 70 100 25]);
        RunIV2.b_Abort=uicontrol('Parent',panel_RunButtons,'Style','ToggleButton','String','Abort','Position',[10 40 100 25]);
        RunIV2.p_Source=uicontrol('Parent',panel_RunButtons,'Style','Popup','String',{'Sour. Volt.','Sour. Curr.'},'Position',[10 10 100 25]...
            ,'Callback',@f_p_Source_Callback,'tag','Source_Popup');
        
        
        % Plot axes
        RunIV2.h_IV_ax_2T=axes('Position',[0.25 0.1 0.3 0.35],'XLim',[-1 1]);
        box on
        hold all
        xlabel('Bias Voltage (V)')
        ylabel('Drain-Source Current (A)')
        
        RunIV2.h_IV_ax_Leakage=axes('Position',[0.65 0.1 0.3 0.35],'XLim',[-1 1]);
        box on
        hold all
        xlabel('Bias Voltage (V)')
        ylabel('Leakage Current (A)')
        
        RunIV2.h_IV_ax_4T=axes('Position',[0.25 0.55 0.3 0.35],'XLim',[-1 1]);
        box on
        hold all
        ylabel('4-Terminal Voltage (V)')
        
        RunIV2.h_IV_ax_4T2=axes('Position',[0.65 0.55 0.3 0.35],'XLim',[-1 1]);
        box on
        hold all
        ylabel('4-Terminal Voltage 2 (V)')
        
        %saveas button
%         b_SaveAs=uicontrol('Parent',h_IV,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
%             ,'Callback','uisave');
        
        %%
    end