function [] = f_RunIV (varargin)
        %%
        global RunIV
        h_IV=figure();
        set(h_IV,'OuterPosition',[600 400 1000 600],'Color',0.95*[1 1 1],'ToolBar','figure','NumberTitle','off','Name','I-V ramp')
        %Buttons and controls
        RunIV.txt_V_Step=uicontrol('Parent',h_IV,'Style','text','Position',[30 125 50 25],'String','V Step');
        RunIV.h_V_Step=uicontrol('Parent',h_IV,'Style','edit','String','0.1','Position',[80 130 40 25],'BackgroundColor','w');
        
        RunIV.txt_V_Min=uicontrol('Parent',h_IV,'Style','text','Position',[30 65 50 25],'String','V Min');
        RunIV.h_V_Min=uicontrol('Parent',h_IV,'Style','edit','String','-5','Position',[80 70 40 25],'BackgroundColor','w');
        
        RunIV.txt_V_Max=uicontrol('Parent',h_IV,'Style','text','Position',[30 95 50 25],'String','V Max');
        RunIV.h_V_Max=uicontrol('Parent',h_IV,'Style','edit','String','5','Position',[80 100 40 25],'BackgroundColor','w');
        
        RunIV.txt_V_Custom=uicontrol('Parent',h_IV,'Style','text','Position',[30 190 100 25],'String','Custom V Range');
        RunIV.h_V_Custom=uicontrol('Parent',h_IV,'Style','edit','String','[0:0.1:1 1:-0.1:-1 -1:0.1:0]','Position',[50 170 80 25],'BackgroundColor','w');
        RunIV.check_V_Custom=uicontrol('Parent',h_IV,'Style','checkbox','Position',[30 170 20 20],'BackgroundColor','w');
        
        RunIV.txt_dual=uicontrol('Parent',h_IV,'Style','text','Position',[45 30 90 25],'String','Dual Ramp');
        RunIV.check_dual=uicontrol('Parent',h_IV,'Style','checkbox','Position',[40 40 20 20],'BackgroundColor','w','Value',1);
        
        %Run buttons
        RunIV.b_RunNow=uicontrol('Parent',h_IV,'Style','PushButton','String','Run Now','Position',[30 430 100 25]...
            ,'Callback',@f_RunIV_RunNow);
        RunIV.b_Pause=uicontrol('Parent',h_IV,'Style','ToggleButton','String','Pause','Position',[30 400 100 25]);
        RunIV.b_Abort=uicontrol('Parent',h_IV,'Style','ToggleButton','String','Abort','Position',[30 370 100 25]);
        
        RunIV.h_IV_ax=axes('Position',[0.2 0.1 0.75 0.8],'XLim',[-1 1]);
        box on
        hold on
        xlabel('Bias Voltage (V)')
        ylabel('Current (A)')
        
        %saveas button
        b_SaveAs=uicontrol('Parent',h_IV,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
            ,'Callback','uisave');
        
    end