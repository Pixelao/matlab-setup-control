function [] = f_RunPCCH (varargin)
        %%
        global h_FR_Min h_FR_Max h_FR_Step b_Pause b_Abort check_FR_Custom h_FR_Custom check_AutoSave
        h_PCCH=figure();
        set(h_PCCH,'OuterPosition',[600 400 1000 600],'Color',0.95*[1 1 1],'ToolBar','figure')
        h_PCCH_ax=axes('Position',[0.2 0.1 0.75 0.8],'XLim',[200 1000],'tag','mainFig');
        box on
        hold on
        xlabel('Chopper frequency (Hz)')
        ylabel('Photocurrent (A)')
        %Control parameters
        %txt_wstart=uicontrol('Parent',h_PCCH,'Style','text','Position',[10 30 70 30],'String','Start WL (nm)');
        %h_wstart=uicontrol('Parent',h_PCCH,'Style','edit','String','800','Position',[80 40 40 25],'BackgroundColor','w');
       
        txt_FR_Step=uicontrol('Parent',h_PCCH,'Style','text','Position',[10 65 70 25],'String','FR stepsize (Hz)');
        h_FR_Step=uicontrol('Parent',h_PCCH,'Style','edit','String','10','Position',[80 70 40 25],'BackgroundColor','w');
        txt_FR_Min=uicontrol('Parent',h_PCCH,'Style','text','Position',[10 95 70 25],'String','Min FR (Hz)');
        h_FR_Min=uicontrol('Parent',h_PCCH,'Style','edit','String','200','Position',[80 100 40 25],'BackgroundColor','w');
        txt_FR_Max=uicontrol('Parent',h_PCCH,'Style','text','Position',[10 125 70 25],'String','Max FR (Hz)');
        h_FR_Max=uicontrol('Parent',h_PCCH,'Style','edit','String','1000','Position',[80 130 40 25],'BackgroundColor','w');

        txt_FR_Custom=uicontrol('Parent',h_PCCH,'Style','text','Position',[15 190 130 25],'String','Custom frequency Range');
        h_FR_Custom=uicontrol('Parent',h_PCCH,'Style','edit','String','[200:100:500]','Position',[50 170 80 25],'BackgroundColor','w');
        check_FR_Custom=uicontrol('Parent',h_PCCH,'Style','checkbox','Position',[30 170 20 20],'BackgroundColor','w','Value',1);
        
        %Run button
        b_RunNow=uicontrol('Parent',h_PCCH,'Style','PushButton','String','Run Now','Position',[30 430 100 25]...
            ,'Callback',@f_RunPCCH_RunNow);
        b_Pause=uicontrol('Parent',h_PCCH,'Style','ToggleButton','String','Pause','Position',[30 400 100 25]);
        b_Abort=uicontrol('Parent',h_PCCH,'Style','ToggleButton','String','Abort','Position',[30 370 100 25]);
        txt_AutoSave=uicontrol('Parent',h_PCCH,'Style','text','Position',[25 225 90 25],'String','Auto Save');
        check_AutoSave=uicontrol('Parent',h_PCCH,'Style','checkbox','Position',[100 233 20 20],'BackgroundColor','w','Value',1);
        
        %saveas button
        b_SaveAs=uicontrol('Parent',h_PCCH,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
            ,'Callback','global WStruct; uisave(''WStruct'')');
    end