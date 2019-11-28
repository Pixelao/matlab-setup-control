function [] = PCS_Controller_V7 ()
clear all
%% create GPIB object and select Keithley source
SourceID=1;% vsource id number
GateID=2;% vgate id number
global GPIB
GPIB = GPIBManager.getInstance();
handle = GPIB.equipment.vsource(SourceID);
handle2 = GPIB.equipment.vsource(GateID);

%% Create Solstis manager object
SOL_IP='192.168.1.222';
SOL_PORT=39933;
SOL = Solstis.getInstance(SOL_IP,SOL_PORT);
SOL.OpenTCPIP();
%SOL.GoToWL(wl_sweep(1));
%% Create OPTODAC object
OD = Optodac.getInstance('COM5');
%OD = Optodac.getInstance('COM5');
OD.OpenSerial();
%% Create WLM object
WLM = WLM.getInstance;
%% Create window and buttons
h_Control=figure();
set(h_Control,'Name','PCS Controller','NumberTitle','off','OuterPosition',[300,200,230,590],...
    'MenuBar','none','Color',0.95*[1 1 1])

txt_Version=uicontrol('Parent',h_Control,'Style','text','Position',[10 470 200 75],'String','V7 JorgeQ Dec2017');

% Basic Controls panel
panel_Basic=uipanel('Title','Basic Controls','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 10 160 210]);

txt_Ibias=uicontrol('Parent',panel_Basic,'Style','text','Position',[0 5 50 25],'String','Ids');
h_Ibias=uicontrol('Parent',panel_Basic,'Style','edit','String','0e-9','Position',[50 10 40 25],'BackgroundColor','w','tag','VbiasEdit');
b_GoToIbias=uicontrol('Parent',panel_Basic,'Style','PushButton','String','Go','Position',[100 10 40 25]...
    ,'Callback',@f_GoToIbias,'Tag','b_GoToIbias');

txt_Vbias=uicontrol('Parent',panel_Basic,'Style','text','Position',[0 35 50 25],'String','Vds');
h_Vbias=uicontrol('Parent',panel_Basic,'Style','edit','String','0','Position',[50 40 40 25],'BackgroundColor','w','tag','VbiasEdit');
b_GoToVbias=uicontrol('Parent',panel_Basic,'Style','PushButton','String','Go','Position',[100 40 40 25]...
    ,'Callback',@f_GoToVbias,'Tag','b_GoToVbias');

txt_Vgate=uicontrol('Parent',panel_Basic,'Style','text','Position',[0 65 50 25],'String','Vgate');
h_Vgate=uicontrol('Parent',panel_Basic,'Style','edit','String','0','Position',[50 70 40 25],'BackgroundColor','w','tag','VgateEdit');
b_GoToVgate=uicontrol('Parent',panel_Basic,'Style','PushButton','String','Go','Position',[100 70 40 25]...
    ,'Callback',@f_GoToVgate,'Tag','b_GoToVgate');

txt_Vdelay=uicontrol('Parent',panel_Basic,'Style','text','Position',[0 95 90 25],'String','Delay (s/unit)');
h_Vdelay=uicontrol('Parent',panel_Basic,'Style','edit','String','10','Position',[100 100 40 25],'BackgroundColor','w');

txt_WL=uicontrol('Parent',panel_Basic,'Style','text','Position',[0 125 50 25],'String','WL');
h_WL=uicontrol('Parent',panel_Basic,'Style','edit','String','800','Position',[50 130 40 25],'BackgroundColor','w','Tag','h_WL');
b_GoToWL=uicontrol('Parent',panel_Basic,'Style','PushButton','String','Go','Position',[100 130 40 25]...
    ,'Callback',@f_GoToWL,'Tag','b_GoToWL');

txt_Shutter=uicontrol('Parent',panel_Basic,'Style','text','Position',[0 155 50 25],'String','Shutter');
b_ShutterClosed=uicontrol('Parent',panel_Basic,'Style','togglebutton','String','Close','Position',[50 160 40 25]...
    ,'Callback',@f_CloseShutter);
b_ShutterOpen=uicontrol('Parent',panel_Basic,'Style','ToggleButton','String','Open','Position',[100 160 40 25]...
    ,'Callback',@f_OpenShutter);

% Experiments panel
panel_1D=uipanel('Title','Experiments','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 225 160 285]);

b_RunWaveplate=uicontrol('Parent',panel_1D,'Style','PushButton','String','Waveplate rotation','Position',[10 220 140 25]...
    ,'Callback',@f_RunWaveplate);

b_RunGate=uicontrol('Parent',panel_1D,'Style','PushButton','String','Gate Ramp (4T)','Position',[10 190 140 25]...
    ,'Callback',@f_RunGate4T);

b_RunIV4T=uicontrol('Parent',panel_1D,'Style','PushButton','String','I - V characteristic (4T)','Position',[10 160 140 25]...
    ,'Callback',@f_RunIV4T);

b_RunPC=uicontrol('Parent',panel_1D,'Style','PushButton','String','PC Spectrum','Position',[10 10 140 25]...
    ,'Callback',@f_RunPC);

b_RunIV=uicontrol('Parent',panel_1D,'Style','PushButton','String','I - V characteristic','Position',[10 40 140 25]...
    ,'Callback',@f_RunIV);

b_RunGate=uicontrol('Parent',panel_1D,'Style','PushButton','String','Gate Ramp','Position',[10 70 140 25]...
    ,'Callback',@f_RunGate);

b_InstantPlot=uicontrol('Parent',panel_1D,'Style','PushButton','String','Plot over time','Position',[10 100 140 25]...
    ,'Callback',@f_RunInstant);

b_CustomExperiment=uicontrol('Parent',panel_1D,'Style','PushButton','String','Custom Experiment','Position',[10 130 140 25]...
    ,'Callback',@f_RunCustom);

b_MoreExperiments=uicontrol('Parent',panel_1D,'Style','PushButton','String','More','Position',[100 250 50 17]...
    ,'Callback',@f_MoreButtons);


%% Opening script
f_CloseShutter; %CloseShutter
pause(0.1)
        % do the waveplate thing
        global WPControl WPFig
        [WPControl,WPFig]=WaveplateInit(); % initialize waveplate control
%        set(WPFig,'Visible','off')

%% Subfunctions
    function [] = f_MoreButtons (varargin)
        %%
    h_More=figure();
    set(h_More,'Name','+ Experiments','NumberTitle','off','OuterPosition',[550,200,230,560],...
    'MenuBar','none','Color',0.95*[1 1 1])

    b_RunIV4T_ISource=uicontrol('Parent',h_More,'Style','PushButton','String','I-V 4T (Source Current)','Position',[40 450 140 25]...
    ,'Callback',@f_RunIV4T_ISource);
    b_RunGate4T_ISource=uicontrol('Parent',h_More,'Style','PushButton','String','Gate 4T (Source Current)','Position',[40 420 140 25]...
    ,'Callback',@f_RunGate4T_ISource);
    %%
    end
    function [] = f_GoToVbias (varargin)
        rampV_2450(handle,str2num(get(h_Vbias,'String')),0.1*str2num(get(h_Vdelay,'String')));
    end
    function [] = f_GoToIbias (varargin)
        rampI_2450(handle,str2num(get(h_Ibias,'String')),0.1*str2num(get(h_Vdelay,'String')));
    end
    function [] = f_GoToWL (varargin)
        %WLM.SwitchToChannel(1);
        SOL.GoToWL(str2num(get(h_WL,'String')));
        %WLM.SwitchToChannel(2);
    end
    function [] = f_GoToVgate (varargin)
        rampV_2410(handle2,str2num(get(h_Vgate,'String')),0.1*str2num(get(h_Vdelay,'String')));
    end
    function [] = f_OpenShutter (varargin)
        OD.SetShutter(2,'open')
        set(b_ShutterClosed,'BackgroundColor','default','FontWeight','default')
        set(b_ShutterClosed,'Value',0)
        set(b_ShutterOpen,'BackgroundColor',[0.4 1 0.4],'FontWeight','bold')
        
    end
    function [] = f_CloseShutter (varargin)
        OD.SetShutter(2,'close')
        set(b_ShutterOpen,'Value',0)
        set(b_ShutterOpen,'BackgroundColor','default','FontWeight','default')
        set(b_ShutterClosed,'BackgroundColor',[1 0.4 0.4],'FontWeight','bold')
    end
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
    function [] = f_RunGate (varargin)
        %%
        global RunGate
        h_Gate=figure();
        set(h_Gate,'OuterPosition',[600 400 1000 600],'Color',0.95*[1 1 1],'ToolBar','figure','NumberTitle','off','Name','Gate ramp')
        %Buttons and controls
        RunGate.txt_V_Step=uicontrol('Parent',h_Gate,'Style','text','Position',[30 125 50 25],'String','V Step');
        RunGate.h_V_Step=uicontrol('Parent',h_Gate,'Style','edit','String','0.1','Position',[80 130 40 25],'BackgroundColor','w');
        
        RunGate.txt_V_Min=uicontrol('Parent',h_Gate,'Style','text','Position',[30 65 50 25],'String','V Min');
        RunGate.h_V_Min=uicontrol('Parent',h_Gate,'Style','edit','String','-5','Position',[80 70 40 25],'BackgroundColor','w');
        
        RunGate.txt_V_Max=uicontrol('Parent',h_Gate,'Style','text','Position',[30 95 50 25],'String','V Max');
        RunGate.h_V_Max=uicontrol('Parent',h_Gate,'Style','edit','String','5','Position',[80 100 40 25],'BackgroundColor','w');
        
        RunGate.txt_V_Custom=uicontrol('Parent',h_Gate,'Style','text','Position',[30 190 100 25],'String','Custom V Range');
        RunGate.h_V_Custom=uicontrol('Parent',h_Gate,'Style','edit','String','[0:0.1:1 1:-0.1:-1 -1:0.1:0]','Position',[50 170 80 25],'BackgroundColor','w');
        RunGate.check_V_Custom=uicontrol('Parent',h_Gate,'Style','checkbox','Position',[30 170 20 20],'BackgroundColor','w');
        
        RunGate.txt_dual=uicontrol('Parent',h_Gate,'Style','text','Position',[45 30 90 25],'String','Dual Ramp');
        RunGate.check_dual=uicontrol('Parent',h_Gate,'Style','checkbox','Position',[40 40 20 20],'BackgroundColor','w','Value',1);
        %Run buttons
        RunGate.b_RunNow=uicontrol('Parent',h_Gate,'Style','PushButton','String','Run Now','Position',[30 430 100 25]...
            ,'Callback',@f_RunGate_RunNow);
        RunGate.b_Pause=uicontrol('Parent',h_Gate,'Style','ToggleButton','String','Pause','Position',[30 400 100 25]);
        RunGate.b_Abort=uicontrol('Parent',h_Gate,'Style','ToggleButton','String','Abort','Position',[30 370 100 25]);
        
        RunGate.h_Gate_ax=axes('Position',[0.2 0.1 0.75 0.8],'XLim',[-1 1]);
        box on
        hold on
        xlabel('Gate Voltage (V)')
        ylabel('Current (A)')
        
        %saveas button
        b_SaveAs=uicontrol('Parent',h_Gate,'Style','PushButton','String','Save As...','Position',[30 340 100 25]...
            ,'Callback','uisave');
    end
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
    function [] = f_RunInstant (varargin)
        % Plot I vs time
        clear I t pow
        I=NaN(1,1000);
        IDark=NaN(1,1000);
        ILock=NaN(1,1000);
        ILock2=NaN(1,1000);
        ThetaLock=NaN(1,1000);
        ThetaLock2=NaN(1,1000);
        wl=NaN(1,1000);
        pow=NaN(1,1000);
        keith2=NaN(1,1000);
        tic
        i=1;
        t=zeros(1,1000);
        figure(72)
        subplot(2,3,1)
        hPlot=plot(t,abs(I),'LineWidth',2);
        xlabel('time (s)')
        ylabel('Current (A)')
        %ylim([2 2.2]*1e-5)
        subplot(2,3,2)
        hwl=plot(t,wl,'LineWidth',2);
        xlabel('time (s)')
        ylabel('Wavelength (nm)')
        ylim([690 1010])
        
        subplot(2,3,3)
        hpow=plot(t,pow,'LineWidth',2);
        xlabel('time (s)')
        ylabel('Power (A.U)')
        %OD.SetShutter(2,'open');
        %hPCS=plot(wl,I,'.');
        
        subplot(2,3,4)
        hkeith=plot(t,keith2,'LineWidth',2);
        xlabel('time (s)')
        ylabel('Voltage (A.U)')
        %OD.SetShutter(2,'open');
        %hPCS=plot(wl,I,'.');
        
        subplot(2,3,5)
        hLock=plot(t,ILock,'LineWidth',2);
        xlabel('time (s)')
        ylabel('Lock-In 1 Current (A.U.)')
        %OD.SetShutter(2,'open');
        %hPCS=plot(wl,I,'.');
        
        subplot(2,3,6)
        hLock2=plot(t,ILock2,'LineWidth',2);
        xlabel('time (s)')
        ylabel('Lock-In 2 Current (A.U.)')
        
        while i>0
            norm = GPIB.ReadKeithleys();
            thePower=norm(1);
            for i=1%:4
                theIIDark(i)=eval(['[',query(handle,':READ?'),']']);
            end
            theIDark=median(theIIDark);
            %OD.SetShutter(2,'open');
            %pause(0.2)
            for i=1:4
                theII(i)=eval(['[',query(handle,':READ?'),']']); % read measurement
            end
            theI=median(theII);
            for i=1:4
                norm = GPIB.ReadKeithleys();
                thePP(i)=norm(2); % read measurement
                theKK(i)=norm(1);
                %theIILock=norm(1);
                [lock_1,lock_2]=GPIB.ReadLockins('CH');
                theIILock=lock_1(1);
                TThetaLock=lock_2(1);
                theIILock2=lock_1(2);
                TThetaLock2=lock_2(2);
            end
            thePower=median(thePP);
            theKeithley2=median(theKK)
            theILock=median(theIILock)
            theILock2=median(theIILock2)
            theThetaLock=median(TThetaLock);
            theThetaLock2=median(TThetaLock2);
            %OD.SetShutter(2,'close');
            I=[I theI];
            IDark=[IDark theIDark];
            ILock=[ILock theILock];
            ILock2=[ILock2 theILock2];
            ThetaLock=[ThetaLock theThetaLock];
            ThetaLock2=[ThetaLock2 theThetaLock2];
            %WLM.SwitchToChannel(1);
            A=SOL.GetWL(); the_wl=A.current_wavelength;
            %WLM.SwitchToChannel(2);
            wl=[wl the_wl];
            pow=[pow thePower];
            keith2=[keith2 theKeithley2];
            t=[t toc];
            set(hPlot,'YData',I(end-500:end)...-IDark(end-500:end)...
                ,'XData',t(end-500:end))
            set(hwl,'YData',wl(end-500:end),'XData',t(end-500:end))
            set(hpow,'XData',t(end-500:end),'YData',pow(end-500:end))
            set(hkeith,'XData',t(end-500:end),'YData',keith2(end-500:end))
            set(hLock,'XData',t(end-500:end),'YData',ILock(end-500:end).*sign(ThetaLock(end-500:end)))
            set(hLock2,'XData',t(end-500:end),'YData',ILock2(end-500:end).*sign(ThetaLock2(end-500:end)))
            %pause(0.5)
            drawnow
            
            global data
            data.WL=wl;
            data.I=I;
            data.IDark=IDark;
            data.ILock=ILock;
            data.ILock2=ILock2;
            data.time=t;
            data.pow=pow;
            data.keith2=keith2;
            data.ThetaLock=ThetaLock;
            data.ThetaLock2=ThetaLock2;
            
        end
        OD.SetShutter(2,'close');
        global data
        data.WL=wl;
        data.I=I;
        data.IDark=IDark;
        data.time=t;
        name=['I_vs_T' V_start];
        data.comment=filename;
        % save data
        filename=create_filenames(name);  save(filename); savefig(gcf,[filename '_plot.fig']);
        
    end
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
    function [] = f_RunGate4T (varargin)
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

%% Sub_Subfunctions
    function [] = f_RunPC_RunNow (varargin)
        global h_WL_Min h_WL_Max h_WL_Step b_Pause b_Abort check_WL_Custom h_WL_Custom check_AutoSave
        hPlot=plot(NaN,NaN,'Color',[0.5 0.5 0.5]); hold on;
        hPlot_Lock=plot(NaN,NaN,'r');
        Idata=[];
        IdataD=[];
        WL=[];
        pow=[];
        % Solstis scan parameters
        if get(check_WL_Custom,'Value')==1
            wl_sweep=eval(get(h_WL_Custom,'String'));
        else
            wl_sweep=[str2num(get(h_WL_Min,'String')):str2num(get(h_WL_Step,'String')):str2num(get(h_WL_Max,'String'))];
        end
        tic %count timer
        disp('Measurement starting')
        for j=1:length(wl_sweep)
            while get(b_Pause,'Value')==1
                pause(0.2)
            end
            if get(b_Abort,'Value')==1
                set(b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            WLM.SwitchToChannel(2);
            SOL.GoToWL(wl_sweep(j)); %go to wl
            A=SOL.GetWL(); the_wl=A.current_wavelength;
            WLM.SwitchToChannel(1)
            toc
            pause(5-toc) %(wait for thermal stabilization)
            for i=1:16
                AA_D=eval(['[',query(handle,':READ?'),']']); % read measurement
                theII_D(i)=AA_D;
            end
            OD.SetShutter(2,'open');
            pause(0.5) % wait for current stabilization
            for i=1:16
                AA=eval(['[',query(handle,':READ?'),']']); % read measurement
                theII(i)=AA;
            end
            for i=1:16
                thelockins=GPIB.ReadLockins('CH');
                AA_Lock=thelockins(1); % read measurement
                theII_Lock(i)=AA_Lock;
            end
            OD.SetShutter(2,'close');
            tic %start dark time cronometer
            norm(j,:) = GPIB.ReadKeithleys(); % Caution Keithley connected
            theI=mean(theII)
            theI_D=mean(theII_D)
            theI_Lock=mean(theII_Lock)
            Idata=[Idata theI];
            IdataD=[IdataD theI_D];
            clear theII theII_D
            % Plotting
            WL=[WL the_wl ];
            set(hPlot,'YData',[get(hPlot,'YData') (theI-theI_D)]...
                ,'XData',[get(hPlot,'XData') the_wl])
            set(hPlot_Lock,'YData',[get(hPlot_Lock,'YData') theI_Lock]...
                ,'XData',[get(hPlot_Lock,'XData') the_wl])
        end
        disp('Done')
        WLM.SwitchToChannel(2)
        SOL.GoToWL(800);
        WLM.SwitchToChannel(1)
        t=clock; name=strcat(num2str(t(4)),'h',num2str(t(5)),'m');
        data.comment=name;
        % save data
        if get(check_AutoSave,'Value')
            filename=create_filenames(name);  save(filename); savefig(gcf,[filename '_plot.fig']);
            savefig(gcf,[filename '_plot.fig'])
        end
    end
    function [] = f_RunGate_RunNow (varargin)
        global RunGate
        %create Vbias vector
        if get(RunGate.check_V_Custom,'Value')==1
            V_sweep=eval(get(RunGate.h_V_Custom,'String'));
        elseif get(RunGate.check_dual,'Value')==1
            V_sweep=[0:str2num(get(RunGate.h_V_Step,'String')):str2num(get(RunGate.h_V_Max,'String')) ...
                str2num(get(RunGate.h_V_Max,'String')):-str2num(get(RunGate.h_V_Step,'String')):str2num(get(RunGate.h_V_Min,'String')) ...
                str2num(get(RunGate.h_V_Min,'String')):str2num(get(RunGate.h_V_Step,'String')):0];
        else
            V_sweep=[str2num(get(RunGate.h_V_Min,'String')):str2num(get(RunGate.h_V_Step,'String')):str2num(get(RunGate.h_V_Max,'String'))];
        end
        %ramp to initial bias voltage
        rampV_2410(handle2,V_sweep(1),0.1*str2num(get(h_Vdelay,'String')));
        pause(0.1)
        %initialize plot
        set(RunGate.h_Gate_ax,'XLim',[str2num(get(RunGate.h_V_Min,'String')) str2num(get(RunGate.h_V_Max,'String'))])
        hPlot=plot(NaN,NaN,'.-'); hold all; % Initialize plot
        
        %open keithley outputs
        fprintf(handle,':OUTP ON'); % open output
        fprintf(handle2,':OUTP ON'); % open output
        
        % measure
        for i=1:length(V_sweep)
            while get(RunGate.b_Pause,'Value')==1
                pause(0.01)
            end
            if get(RunGate.b_Abort,'Value')==1
                set(RunGate.b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            tic
            fprintf(handle2,[':SOUR:VOLT:LEV ' num2str(V_sweep(i))]); % set voltage value
            %pause(delay2)
            %pause(0.1)
            %OD.SetShutter(2,'open');
            output2=str2num(query(handle2,':READ?'));
            V(i)=output2(1);
            output=str2num(query(handle,':READ?'));
            I(i)=output(1);
            %OD.SetShutter(2,'close');
            % update plot
            set(hPlot,'XData',V,'YData',I)
            drawnow
            pause(str2num(get(h_Vdelay,'String'))*str2num(get(RunGate.h_V_Step,'String'))-toc)
            
        end

%         hPlot=plot(NaN,NaN,'.-');
        clear V
        clear I
        clear norm
    end
    function [] = f_RunIV_RunNow (varargin)
        global RunIV
        %create Vbias vector
        if get(RunIV.check_V_Custom,'Value')==1
            V_sweep=eval(get(RunIV.h_V_Custom,'String'));
        elseif get(RunIV.check_dual,'Value')==1
            V_sweep=[0:str2num(get(RunIV.h_V_Step,'String')):str2num(get(RunIV.h_V_Max,'String')) ...
                str2num(get(RunIV.h_V_Max,'String')):-str2num(get(RunIV.h_V_Step,'String')):str2num(get(RunIV.h_V_Min,'String')) ...
                str2num(get(RunIV.h_V_Min,'String')):str2num(get(RunIV.h_V_Step,'String')):0];
        else
            V_sweep=[str2num(get(RunIV.h_V_Min,'String')):str2num(get(RunIV.h_V_Step,'String')):str2num(get(RunIV.h_V_Max,'String'))];
        end
        %ramp to initial bias voltage
        rampV_2450(handle,V_sweep(1),0.1*str2num(get(h_Vdelay,'String')));
        %initialize plot
        set(RunIV.h_IV_ax,'XLim',[str2num(get(RunIV.h_V_Min,'String')) str2num(get(RunIV.h_V_Max,'String'))])
        hPlot=plot(NaN,NaN,'.-'); hold all; % Initialize plot
        
        %open keithley outputs
        fprintf(handle,':OUTP ON'); % open output
        fprintf(handle2,':OUTP ON'); % open output
        
        % measure
        fprintf(handle,':OUTP ON'); % open output
        
        for i=1:length(V_sweep)
            while get(RunIV.b_Pause,'Value')==1
                pause(0.01)
            end
            if get(RunIV.b_Abort,'Value')==1
                set(RunIV.b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            tic
            fprintf(handle,[':SOUR:VOLT:LEV ' num2str(V_sweep(i))]); % set voltage value
            pause(0.5)
            trash=eval(['[',query(handle,':READ?'),']']); % read trash
            output=eval(['[',query(handle,':READ?'),']']); % read measurement
            % update plot
            V(i)=V_sweep(i);
            I(i)=output(1);
            %set(RunIV.h_IV_ax,'XData',V,'YData',I)
            set(hPlot,'XData',V,'YData',I)
            drawnow
            pause(str2num(get(h_Vdelay,'String'))*str2num(get(RunIV.h_V_Step,'String'))-toc)
        end
%         hPlot=plot(NaN,NaN,'.-');
        clear V
        clear I
        clear norm
    end
    function [] = f_RunIV4T_RunNow (varargin)
        clear V
        clear I
        clear V4T
        clear norm
        global RunIV2
        %create Vbias vector
        
        if get(RunIV2.check_V_Custom,'Value')==1
            V_sweep=eval(get(RunIV2.h_V_Custom,'String'));
        elseif get(RunIV2.check_dual,'Value')==1
            V_sweep=[0:str2num(get(RunIV2.h_V_Step,'String')):str2num(get(RunIV2.h_V_Max,'String')) ...
                str2num(get(RunIV2.h_V_Max,'String')):-str2num(get(RunIV2.h_V_Step,'String')):str2num(get(RunIV2.h_V_Min,'String')) ...
                str2num(get(RunIV2.h_V_Min,'String')):str2num(get(RunIV2.h_V_Step,'String')):0];
        else
            V_sweep=[str2num(get(RunIV2.h_V_Min,'String')):str2num(get(RunIV2.h_V_Step,'String')):str2num(get(RunIV2.h_V_Max,'String'))];
        end
        %ramp to initial bias voltage
        rampV_2450(handle,V_sweep(1),0.1*str2num(get(h_Vdelay,'String')));
        %initialize plot
        set(RunIV2.h_IV_ax_2T,'XLim',[str2num(get(RunIV2.h_V_Min,'String')) str2num(get(RunIV2.h_V_Max,'String'))])
        set(RunIV2.h_IV_ax_4T,'XLim',[str2num(get(RunIV2.h_V_Min,'String')) str2num(get(RunIV2.h_V_Max,'String'))])
        set(RunIV2.h_IV_ax_4T2,'XLim',[str2num(get(RunIV2.h_V_Min,'String')) str2num(get(RunIV2.h_V_Max,'String'))])
        set(RunIV2.h_IV_ax_Leakage,'XLim',[str2num(get(RunIV2.h_V_Min,'String')) str2num(get(RunIV2.h_V_Max,'String'))])
        hPlot=plot(RunIV2.h_IV_ax_2T,NaN,NaN,'.-'); hold all; % Initialize plot
        hPlot4T=plot(RunIV2.h_IV_ax_4T,NaN,NaN,'.-'); hold all; % Initialize plot 2
        hPlot4T2=plot(RunIV2.h_IV_ax_4T2,NaN,NaN,'.-'); hold all; % Initialize plot 3
        hPlotLeakage=plot(RunIV2.h_IV_ax_Leakage,NaN,NaN,'.-'); hold all; % Initialize plot 4
        
        %open keithley outputs
        fprintf(handle,':OUTP ON'); % open output
        fprintf(handle2,':OUTP ON'); % open output
        
        % measure
        fprintf(handle,':OUTP ON'); % open output
        
        for i=1:length(V_sweep)
            while get(RunIV2.b_Pause,'Value')==1
                pause(0.01)
            end
            if get(RunIV2.b_Abort,'Value')==1
                set(RunIV2.b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            tic
            fprintf(handle,[':SOUR:VOLT:LEV ' num2str(V_sweep(i))]); % set voltage value
            pause(0.5)
            trash=eval(['[',query(handle,':READ?'),']']); % read trash
            output=eval(['[',query(handle,':READ?'),']']); % read measurement
            output2=eval(['[',query(handle2,':READ?'),']']); % read measurement
            output4T=GPIB.ReadKeithleys; % read keithleys
            % update plot
            V(i)=V_sweep(i);
            I(i)=output(1);
            I_leak(i)=output2(2);
            V4T(i)=output4T(1);
            V4T2(i)=output4T(2);
            %set(RunIV.h_IV_ax,'XData',V,'YData',I)
            set(hPlot,'XData',V,'YData',I)
            set(hPlot4T,'XData',V,'YData',V4T)
            set(hPlot4T2,'XData',V,'YData',V4T2)
            set(hPlotLeakage,'XData',V,'YData',I_leak)
            drawnow
            pause(str2num(get(h_Vdelay,'String'))*str2num(get(RunIV2.h_V_Step,'String'))-toc)
            
            global data_IV_4T
            data_IV_4T.Vgate=V;
            data_IV_4T.I2T=I;
            data_IV_4T.V4T1=V4T;
            data_IV_4T.V4T2=V4T2;
            data_IV_4T.ILeakage=I_leak;
        end
        
        %         hPlot=plot(NaN,NaN,'.-');
        
    end
    function [] = f_RunIV4T_RunNow_ISource (varargin)
        clear V
        clear I
        clear V4T
        clear norm
        global RunIV2
        
        %create Ibias vector
        
        if get(RunIV2.check_V_Custom,'Value')==1
            I_sweep=eval(get(RunIV2.h_I_Custom,'String'));
        elseif get(RunIV2.check_dual,'Value')==1
            I_sweep=[0:str2num(get(RunIV2.h_I_Step,'String')):str2num(get(RunIV2.h_I_Max,'String')) ...
                str2num(get(RunIV2.h_I_Max,'String')):-str2num(get(RunIV2.h_I_Step,'String')):str2num(get(RunIV2.h_I_Min,'String')) ...
                str2num(get(RunIV2.h_I_Min,'String')):str2num(get(RunIV2.h_I_Step,'String')):0];
        else
            I_sweep=[str2num(get(RunIV2.h_I_Min,'String')):str2num(get(RunIV2.h_I_Step,'String')):str2num(get(RunIV2.h_I_Max,'String'))];
        end
        
        %ramp to initial Ibias voltage
        rampI_2450(handle,I_sweep(1),0.1*str2num(get(h_Vdelay,'String')));
        
        %initialize plot
        set(RunIV2.h_IV_ax_2T,'XLim',[str2num(get(RunIV2.h_I_Min,'String')) str2num(get(RunIV2.h_I_Max,'String'))])
        set(RunIV2.h_IV_ax_4T,'XLim',[str2num(get(RunIV2.h_I_Min,'String')) str2num(get(RunIV2.h_I_Max,'String'))])
        set(RunIV2.h_IV_ax_4T2,'XLim',[str2num(get(RunIV2.h_I_Min,'String')) str2num(get(RunIV2.h_I_Max,'String'))])
        set(RunIV2.h_IV_ax_Leakage,'XLim',[str2num(get(RunIV2.h_I_Min,'String')) str2num(get(RunIV2.h_I_Max,'String'))])
        hPlot=plot(RunIV2.h_IV_ax_2T,NaN,NaN,'.-'); hold all; % Initialize plot
        hPlot4T=plot(RunIV2.h_IV_ax_4T,NaN,NaN,'.-'); hold all; % Initialize plot 2
        hPlot4T2=plot(RunIV2.h_IV_ax_4T2,NaN,NaN,'.-'); hold all; % Initialize plot 3
        hPlotLeakage=plot(RunIV2.h_IV_ax_Leakage,NaN,NaN,'.-'); hold all; % Initialize plot 4
        
        %open keithley outputs
        fprintf(handle,':OUTP ON'); % open output
        fprintf(handle2,':OUTP ON'); % open output
        
        % measure
        fprintf(handle,':OUTP ON'); % open output
        
        for i=1:length(I_sweep)
            while get(RunIV2.b_Pause,'Value')==1
                pause(0.01)
            end
            if get(RunIV2.b_Abort,'Value')==1
                set(RunIV2.b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            tic
            fprintf(handle,[':SOUR:CURR:LEV ' num2str(I_sweep(i))]); % set voltage value
            pause(0.5)
            trash=eval(['[',query(handle,':READ?'),']']); % read trash
            output=eval(['[',query(handle,':READ?'),']']); % read measurement
            output2=eval(['[',query(handle2,':READ?'),']']); % read measurement
            output4T=GPIB.ReadKeithleys; % read keithleys
            % update plot
            I(i)=I_sweep(i);
            V(i)=output(1);
            I_leak(i)=output2(2);
            V4T(i)=output4T(1);
            V4T2(i)=output4T(2);
            %set(RunIV.h_IV_ax,'XData',V,'YData',I)
            set(hPlot,'XData',I,'YData',V)
            set(hPlot4T,'XData',I,'YData',V4T)
            set(hPlot4T2,'XData',I,'YData',V4T2)
            set(hPlotLeakage,'XData',I,'YData',I_leak)
            drawnow
            pause(str2num(get(h_Vdelay,'String'))*str2num(get(RunIV2.h_V_Step,'String'))-toc)
            
            global data_IV_4T
            data_IV_4T.V2T=V;
            data_IV_4T.I2T=I;
            data_IV_4T.V4T1=V4T;
            data_IV_4T.V4T2=V4T2;
            data_IV_4T.ILeakage=I_leak;
        end
        
        %         hPlot=plot(NaN,NaN,'.-');
        
    end
    function [] = f_RunGate4T_RunNow (varargin)
        global RunGate2
        %create Vbias vector
        if get(RunGate2.check_V_Custom,'Value')==1
            V_sweep=eval(get(RunGate2.h_V_Custom,'String'));
        elseif get(RunGate2.check_dual,'Value')==1
            V_sweep=[0:str2num(get(RunGate2.h_V_Step,'String')):str2num(get(RunGate2.h_V_Max,'String')) ...
                str2num(get(RunGate2.h_V_Max,'String')):-str2num(get(RunGate2.h_V_Step,'String')):str2num(get(RunGate2.h_V_Min,'String')) ...
                str2num(get(RunGate2.h_V_Min,'String')):str2num(get(RunGate2.h_V_Step,'String')):0];
        else
            V_sweep=[str2num(get(RunGate2.h_V_Min,'String')):str2num(get(RunGate2.h_V_Step,'String')):str2num(get(RunGate2.h_V_Max,'String'))];
        end
        %ramp to initial bias voltage
        rampV_2410(handle2,V_sweep(1),0.1*str2num(get(h_Vdelay,'String')));
        pause(0.1)
        %initialize plot
        set(RunGate2.h_Gate_ax_2T,'XLim',[str2num(get(RunGate2.h_V_Min,'String')) str2num(get(RunGate2.h_V_Max,'String'))])
        set(RunGate2.h_Gate_ax_4T,'XLim',[str2num(get(RunGate2.h_V_Min,'String')) str2num(get(RunGate2.h_V_Max,'String'))])
        set(RunGate2.h_Gate_ax_4T2,'XLim',[str2num(get(RunGate2.h_V_Min,'String')) str2num(get(RunGate2.h_V_Max,'String'))])
        set(RunGate2.h_Gate_ax_Leakage,'XLim',[str2num(get(RunGate2.h_V_Min,'String')) str2num(get(RunGate2.h_V_Max,'String'))])
        
        hPlot=plot(RunGate2.h_Gate_ax_2T,NaN,NaN,'.-'); hold all; % Initialize plot
        hPlot4T=plot(RunGate2.h_Gate_ax_4T,NaN,NaN,'.-'); hold all; % Initialize plot 2
        hPlot4T2=plot(RunGate2.h_Gate_ax_4T2,NaN,NaN,'.-'); hold all; % Initialize plot 2
        hPlotLeakage=plot(RunGate2.h_Gate_ax_Leakage,NaN,NaN,'.-'); hold all; % Initialize plot 2
        
        %open keithley outputs
        fprintf(handle,':OUTP ON'); % open output
        fprintf(handle2,':OUTP ON'); % open output
        
        % measure
        for i=1:length(V_sweep)
            while get(RunGate2.b_Pause,'Value')==1
                pause(0.01)
            end
            if get(RunGate2.b_Abort,'Value')==1
                set(RunGate2.b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            tic
            fprintf(handle2,[':SOUR:VOLT:LEV ' num2str(V_sweep(i))]); % set voltage value
            %pause(delay2)
            %pause(0.1)
            %OD.SetShutter(2,'open');
            output2=str2num(query(handle2,':READ?'));
            V(i)=output2(1);
            output=str2num(query(handle,':READ?'));
            I(i)=output(1);
            output4T=GPIB.ReadKeithleys; % read keithleys
            V4T(i)=output4T(1);
            V4T2(i)=output4T(2);
            I_leak(i)=output2(2);
            %OD.SetShutter(2,'close');
            % update plot
            set(hPlot,'XData',V,'YData',I)
            set(hPlot4T,'XData',V,'YData',V4T)
            set(hPlot4T2,'XData',V,'YData',V4T2)
            set(hPlotLeakage,'XData',V,'YData',I_leak)
            drawnow
            % store data in global variable
            global data_gate_4T
            data_gate_4T.Vgate=V;
            data_gate_4T.I2T=I;
            data_gate_4T.V4T1=V4T;
            data_gate_4T.V4T2=V4T2;
            data_gate_4T.ILeakage=I_leak;
            
            pause(str2num(get(h_Vdelay,'String'))*str2num(get(RunGate2.h_V_Step,'String'))-toc)
            
        end
        %         hPlot=plot(NaN,NaN,'.-');
        clear V
        clear I
        clear norm
    end
    function [] = f_RunWaveplate (varargin)
        % Run single waveplate measurement
        Ti=clock;% initial time
        clear I t pow
        I=NaN(1,1000);
        IDark=NaN(1,1000);
        ILock=NaN(1,1000);
        ILock2=NaN(1,1000);
        ThetaLock=NaN(1,1000);
        ThetaLock2=NaN(1,1000);
        wl=NaN(1,1000);
        pow=NaN(1,1000);
        keith2=NaN(1,1000);
        WPTheta=NaN(1,1000);
        t=zeros(1,1000);
        
        figure(72)
        subplot(2,3,1)
        hPlot=plot(t,abs(I),'LineWidth',2);
        xlabel('Theta (dgr)')
        ylabel('Current (A)')
        %ylim([2 2.2]*1e-5)
        subplot(2,3,2)
        hwl=plot(t,wl,'LineWidth',2);
        xlabel('Theta (dgr)')
        ylabel('Wavelength (nm)')
        ylim([690 1010])
        
        subplot(2,3,3)
        hpow=plot(t,pow,'LineWidth',2);
        xlabel('Theta (dgr)')
        ylabel('Power (A.U)')
        %OD.SetShutter(2,'open');
        %hPCS=plot(wl,I,'.');
        
        subplot(2,3,4)
        hkeith=plot(t,keith2,'LineWidth',2);
        xlabel('Theta (dgr)')
        ylabel('Voltage (A.U)')
        %OD.SetShutter(2,'open');
        %hPCS=plot(wl,I,'.');
        
        subplot(2,3,5)
        hLock=plot(t,ILock,'LineWidth',2);
        xlabel('Theta (dgr)')
        ylabel('Lock-In 1 Current (A.U.)')
        %OD.SetShutter(2,'open');
        %hPCS=plot(wl,I,'.');
        
        subplot(2,3,6)
        hLock2=plot(t,ILock2,'LineWidth',2);
        xlabel('Theta (dgr)')
        ylabel('Lock-In 2 Current (A.U.)')
        
%         % do the waveplate thing
%         global WPControl WPFig
%         [WPControl,WPFig]=WaveplateInit(); % initialize waveplate control
        WP_Theta=[0:10:720];
        WP_Theta_360=rem(WP_Theta,360);
        
        for j=1:length(WP_Theta)
            WaveplateMove(WPControl,WP_Theta_360(j)) %move waveplate
            
            %measure 12 times
            tic
            wptime=toc;
            %while wptime<1
                for i=1:12
                    theII(i)=eval(['[',query(handle,':READ?'),']']); % read measurement
                    norm = GPIB.ReadKeithleys();
                    thePP(i)=norm(2); % read measurement
                    theKK(i)=norm(1);
                    %theIILock=norm(1);
                    [lock_1,lock_2]=GPIB.ReadLockins('CH');
                    theIILock=lock_1(1);
                    TThetaLock=lock_2(1);
                    theIILock2=lock_1(2);
                    TThetaLock2=lock_2(2);
                end
                
                theI=median(theII);
                thePower=median(thePP);
                theKeithley2=median(theKK);
                theILock=median(theIILock);
                theILock2=median(theIILock2);
                theThetaLock=median(TThetaLock);
                theThetaLock2=median(TThetaLock2);
                %OD.SetShutter(2,'close');
                
                I=[I theI];
                ILock=[ILock theILock];
                ILock2=[ILock2 theILock2];
                ThetaLock=[ThetaLock theThetaLock];
                ThetaLock2=[ThetaLock2 theThetaLock2];
                WPTheta=[WPTheta WP_Theta(j)];
                %WLM.SwitchToChannel(1);
                %A=SOL.GetWL(); the_wl=A.current_wavelength;
                %WLM.SwitchToChannel(2);
                %wl=[wl the_wl];
                pow=[pow thePower];
                keith2=[keith2 theKeithley2];
                t=[t toc];
                
                % update plots
                set(hPlot,'YData',I(end-500:end)...-IDark(end-500:end)...
                    ,'XData',WPTheta(end-500:end))
                %set(hwl,'YData',wl(end-500:end),'XData',WPTheta(end-500:end))
                set(hpow,'XData',WPTheta(end-500:end),'YData',pow(end-500:end))
                set(hkeith,'XData',WPTheta(end-500:end),'YData',keith2(end-500:end))
                set(hLock,'XData',WPTheta(end-500:end),'YData',ILock(end-500:end).*sign(ThetaLock(end-500:end)))
                set(hLock2,'XData',WPTheta(end-500:end),'YData',ILock2(end-500:end).*sign(ThetaLock2(end-500:end)))
                drawnow
                
                global data
                data.WL=wl;
                data.I=I;
                data.IDark=IDark;
                data.ILock=ILock;
                data.ILock2=ILock2;
                data.time=t;
                data.pow=pow;
                data.keith2=keith2;
                data.ThetaLock=ThetaLock;
                data.ThetaLock2=ThetaLock2;
                data.WPTheta=WPTheta;
                wptime=toc;
                
            %end
        end
    fprintf('WP Rotation done \n')  
    Tf=clock;
    dT=Tf-Ti
    end
    function [] = f_RunCustom (varargin)
    thepanel=findobj('Name','PCS Controller'); 
    thebutton=findobj(thepanel,'String','Waveplate rotation');
    theCB=get(thebutton,'Callback');
    theCB();
    end
% More functions
    function [WPControl,WPFig] = WaveplateInit()
        % Create Matlab Figure Container
        fpos    = get(0,'DefaultFigurePosition'); % figure default position
        fpos(3) = 650; % figure window size;Width
        fpos(4) = 450; % Height
        
        WPFig = figure(64);
        set(WPFig,'Position', fpos,...
            'Menu','None',...
            'Name','APT GUI',...
            'Visible','on');
        
        % Create ActiveX Controller
        WPControl = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], WPFig);
        
        % Initialize
        % Start Control
        WPControl.StartCtrl;
        
        % Set the Serial Number
        SN = 27502565; % put in the serial number of the hardware
        set(WPControl,'HWSerialNum', SN);
        
        % Indentify the device
        WPControl.Identify;
        pause(5); % waiting for the GUI to load up;
    end
    function [] = WaveplateMove(WPMotor,position)
        timeout = 10; % timeout for waiting the move to be completed
        %h.MoveJog(0,1); % Jog
        
        % Set target position and move
        WPMotor.SetAbsMovePos(0,position);
        WPMotor.MoveAbsolute(0,1==1);
    end
    function [] = f_p_Source_Callback(varargin)
        global RunIV2
        % Change run now callback
        Myfig=findobj('type','figure','name','I-V ramp'); %find figure
        RunNowButton=findobj('type','uicontrol','string','Run Now');%find button inside figure
        Source_Popup=findobj('type','uicontrol','tag','Source_Popup');
        Popupvalue=get(Source_Popup,'Value');
        switch Popupvalue
            case 1
                set(RunNowButton,'Callback',@f_RunIV4T_RunNow)
            case 2
                set(RunNowButton,'Callback',@f_RunIV4T_RunNow_ISource)
        end
        % ---
        % Change axes labels
        theaxes=findobj(Myfig,'type','axes');
        switch Popupvalue
            case 2
                axes(RunIV2.h_IV_ax_2T)
                xlabel('I_{ds} (A)')
                ylabel('V_{ds} (V)')
                axes(RunIV2.h_IV_ax_Leakage)
                xlabel('I_{ds} (A)')
            case 1
                axes(RunIV2.h_IV_ax_2T)
                xlabel('V_{ds} (V)')
                ylabel('I_{ds} (A)')
                axes(RunIV2.h_IV_ax_Leakage)
                xlabel('V_{ds} (V)')
        end
    end

end