function [] = f_RunPC (varargin)
        %%
        global h_WL_Min h_WL_Max h_WL_Step b_Pause b_Abort check_WL_Custom h_WL_Custom check_AutoSave
        h_PC=figure();
        set(h_PC,'OuterPosition',[600 400 1000 600],'Color',0.95*[1 1 1],'ToolBar','figure')
        h_PC_ax=axes('Position',[0.2 0.1 0.75 0.8],'XLim',[700 1000]);
        box on
        hold on
        xlabel('Wavelength (nm)')
        ylabel('Photocurrent (A)')
        %Control parameters
        txt_WL_Step=uicontrol('Parent',h_PC,'Style','text','Position',[30 65 50 25],'String','WL step');
        h_WL_Step=uicontrol('Parent',h_PC,'Style','edit','String','0.1','Position',[80 70 40 25],'BackgroundColor','w');
        txt_WL_Min=uicontrol('Parent',h_PC,'Style','text','Position',[30 95 50 25],'String','Min WL');
        h_WL_Min=uicontrol('Parent',h_PC,'Style','edit','String','700','Position',[80 100 40 25],'BackgroundColor','w');
        txt_WL_Max=uicontrol('Parent',h_PC,'Style','text','Position',[30 125 50 25],'String','Max WL');
        h_WL_Max=uicontrol('Parent',h_PC,'Style','edit','String','1000','Position',[80 130 40 25],'BackgroundColor','w');
        
        txt_WL_Custom=uicontrol('Parent',h_PC,'Style','text','Position',[30 190 100 25],'String','Custom WL Range');
        h_WL_Custom=uicontrol('Parent',h_PC,'Style','edit','String','[850:-0.1:700]','Position',[50 170 80 25],'BackgroundColor','w');
        check_WL_Custom=uicontrol('Parent',h_PC,'Style','checkbox','Position',[30 170 20 20],'BackgroundColor','w','Value',1);
        
        %Run button
        b_RunNow=uicontrol('Parent',h_PC,'Style','PushButton','String','Run Now','Position',[30 430 100 25]...
            ,'Callback',@f_RunPC_RunNow);
        b_Pause=uicontrol('Parent',h_PC,'Style','ToggleButton','String','Pause','Position',[30 400 100 25]);
        b_Abort=uicontrol('Parent',h_PC,'Style','ToggleButton','String','Abort','Position',[30 370 100 25]);
        txt_AutoSave=uicontrol('Parent',h_PC,'Style','text','Position',[25 225 90 25],'String','Auto Save');
        check_AutoSave=uicontrol('Parent',h_PC,'Style','checkbox','Position',[100 233 20 20],'BackgroundColor','w','Value',1);
        
        %saveas button
        b_SaveAs=uicontrol('Parent',h_PC,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
            ,'Callback','global WStruct; uisave(''WStruct'')');
    end