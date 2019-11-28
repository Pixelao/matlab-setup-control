function [] = f_RunIV4T (varargin)
        % insert custom code here
        %%
        global RunIV2
        h_IV=figure();
        set(h_IV,'OuterPosition',[600 100 1000 900],'Color',0.95*[1 1 1],'ToolBar','figure','NumberTitle','off','Name','I-V ramp')
        %Buttons and controls
        RunIV2.txt_V_Step=uicontrol('Parent',h_IV,'Style','text','Position',[30 125 50 25],'String','V Step');
        RunIV2.h_V_Step=uicontrol('Parent',h_IV,'Style','edit','String','0.1','Position',[80 130 40 25],'BackgroundColor','w');
        
        RunIV2.txt_V_Min=uicontrol('Parent',h_IV,'Style','text','Position',[30 65 50 25],'String','V Min');
        RunIV2.h_V_Min=uicontrol('Parent',h_IV,'Style','edit','String','-5','Position',[80 70 40 25],'BackgroundColor','w');
        
        RunIV2.txt_V_Max=uicontrol('Parent',h_IV,'Style','text','Position',[30 95 50 25],'String','V Max');
        RunIV2.h_V_Max=uicontrol('Parent',h_IV,'Style','edit','String','5','Position',[80 100 40 25],'BackgroundColor','w');
        
        RunIV2.txt_V_Custom=uicontrol('Parent',h_IV,'Style','text','Position',[30 190 100 25],'String','Custom V Range');
        RunIV2.h_V_Custom=uicontrol('Parent',h_IV,'Style','edit','String','[0:0.1:1 1:-0.1:-1 -1:0.1:0]','Position',[50 170 80 25],'BackgroundColor','w');
        RunIV2.check_V_Custom=uicontrol('Parent',h_IV,'Style','checkbox','Position',[30 170 20 20],'BackgroundColor','w');
        
        RunIV2.txt_dual=uicontrol('Parent',h_IV,'Style','text','Position',[45 30 90 25],'String','Dual Ramp');
        RunIV2.check_dual=uicontrol('Parent',h_IV,'Style','checkbox','Position',[40 40 20 20],'BackgroundColor','w','Value',1);
        
        %Run buttons
        RunIV2.b_RunNow=uicontrol('Parent',h_IV,'Style','PushButton','String','Run Now','Position',[30 430 100 25]...
            ,'Callback',@f_RunIV4T_RunNow);
        RunIV2.b_Pause=uicontrol('Parent',h_IV,'Style','ToggleButton','String','Pause','Position',[30 400 100 25]);
        RunIV2.b_Abort=uicontrol('Parent',h_IV,'Style','ToggleButton','String','Abort','Position',[30 370 100 25]);
        
        RunIV2.h_IV_ax_2T=axes('Position',[0.2 0.1 0.3 0.3],'XLim',[-1 1]);
        box on
        hold all
        xlabel('Bias Voltage (V)')
        ylabel('Drain-Source Current (A)')
        
        RunIV2.h_IV_ax_Leakage=axes('Position',[0.6 0.1 0.3 0.3],'XLim',[-1 1]);
        box on
        hold all
        xlabel('Bias Voltage (V)')
        ylabel('Leakage Current (A)')
        
        RunIV2.h_IV_ax_4T=axes('Position',[0.2 0.5 0.3 0.3],'XLim',[-1 1]);
        box on
        hold all
        ylabel('4-Terminal Voltage (V)')
        
        RunIV2.h_IV_ax_4T2=axes('Position',[0.6 0.5 0.3 0.3],'XLim',[-1 1]);
        box on
        hold all
        ylabel('4-Terminal Voltage 2 (V)')
        
        %saveas button
        b_SaveAs=uicontrol('Parent',h_IV,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
            ,'Callback','uisave');
        
        %%
    end