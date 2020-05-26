function [] = f_RunGate4T_ISource (varargin)
        %%
        global RunGate2
        h_Gate=figure();
        set(h_Gate,'OuterPosition',[600 100 1000 900],'Color',0.95*[1 1 1],'ToolBar','figure','NumberTitle','off','Name','Gate ramp')
        %Buttons and controls
        RunGate2.txt_V_Step=uicontrol('Parent',h_Gate,'Style','text','Position',[30 125 50 25],'String','V Step');
        RunGate2.h_V_Step=uicontrol('Parent',h_Gate,'Style','edit','String','0.1','Position',[80 130 40 25],'BackgroundColor','w');
        
        RunGate2.txt_V_Min=uicontrol('Parent',h_Gate,'Style','text','Position',[30 65 50 25],'String','V Min');
        RunGate2.h_V_Min=uicontrol('Parent',h_Gate,'Style','edit','String','-5','Position',[80 70 40 25],'BackgroundColor','w');
        
        RunGate2.txt_V_Max=uicontrol('Parent',h_Gate,'Style','text','Position',[30 95 50 25],'String','V Max');
        RunGate2.h_V_Max=uicontrol('Parent',h_Gate,'Style','edit','String','5','Position',[80 100 40 25],'BackgroundColor','w');
        
        RunGate2.txt_V_Custom=uicontrol('Parent',h_Gate,'Style','text','Position',[30 190 100 25],'String','Custom V Range');
        RunGate2.h_V_Custom=uicontrol('Parent',h_Gate,'Style','edit','String','[0:0.1:1 1:-0.1:-1 -1:0.1:0]','Position',[50 170 80 25],'BackgroundColor','w');
        RunGate2.check_V_Custom=uicontrol('Parent',h_Gate,'Style','checkbox','Position',[30 170 20 20],'BackgroundColor','w');
        
        RunGate2.txt_dual=uicontrol('Parent',h_Gate,'Style','text','Position',[45 30 90 25],'String','Dual Ramp');
        RunGate2.check_dual=uicontrol('Parent',h_Gate,'Style','checkbox','Position',[40 40 20 20],'BackgroundColor','w','Value',1);
        %Run buttons
        RunGate2.b_RunNow=uicontrol('Parent',h_Gate,'Style','PushButton','String','Run Now','Position',[30 430 100 25]...
            ,'Callback',@f_RunGate4T_RunNow);
        RunGate2.b_Pause=uicontrol('Parent',h_Gate,'Style','ToggleButton','String','Pause','Position',[30 400 100 25]);
        RunGate2.b_Abort=uicontrol('Parent',h_Gate,'Style','ToggleButton','String','Abort','Position',[30 370 100 25]);
        
        RunGate2.h_Gate_ax_2T=axes('Position',[0.2 0.1 0.3 0.3],'XLim',[-1 1]);
        box on
        hold on
        xlabel('Gate Voltage (V)')
        ylabel('Current (A) / Voltage (V)')
        
        RunGate2.h_Gate_ax_4T=axes('Position',[0.2 0.5 0.3 0.3],'XLim',[-1 1]);
        box on
        hold on
        xlabel('Gate Voltage (V)')
        ylabel('4-Terminal Voltage (V)')
        
        RunGate2.h_Gate_ax_4T2=axes('Position',[0.6 0.5 0.3 0.3],'XLim',[-1 1]);
        box on
        hold all
        ylabel('4-Terminal Voltage 2 (V)')
        
        RunGate2.h_Gate_ax_Leakage=axes('Position',[0.6 0.1 0.3 0.3],'XLim',[-1 1]);
        box on
        hold all
        xlabel('Gate Voltage (V)')
        ylabel('Leakage Current (A)')
        
        %saveas button
        b_SaveAs=uicontrol('Parent',h_Gate,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
            ,'Callback','uisave');
    end