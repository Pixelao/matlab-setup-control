function [] = PCS_Controller_V8_beta5 ()
clear all

%% Add UI functions to path
addpath([cd '/Experiments']);
addpath([cd '/Experiments/MeasureFunctions']);
experiments = dir([cd '/Experiments/','*.m']);


exp={experiments.name};
exps=strrep(exp,'.m',' ');
clear i

%% create GPIB object and select Keithley source
SourceID=1;% vsource id number
GateID=2;% vgate id number
dev=0; % Devices disconnected =0
global GPIB exp

gpib_avail=instrhwinfo('gpib', 'ni');
if(isempty(gpib_avail.InstalledBoardIds))
    disp('No NI GPIB adapter found. Not initializing devices.')
else
    GPIB = GPIBManager.getInstance();
    if isempty(GPIB.equipment.vsource)
        disp('Keithley Voltage source not connected.')
    else
        handle = GPIB.equipment.vsource(SourceID);
        handle2 = GPIB.equipment.vsource(GateID);   
    end

    if isempty(GPIB.equipment.lockin)
        disp('Lockin not connected.')
    else
        lockin = GPIB.equipment.lockin(1); % control lockin
    end
    if isempty(GPIB.equipment.kepco)
        disp('Magnet power supply not connected.')
    else
        GPIB.InitMagnet
    end
end


% Create list box
%% Create Solstis manager object
if(dev> 1)
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
end
%% Create window and buttons
h_Control=figure();
set(h_Control,'Name','PCS Controller','NumberTitle','off','OuterPosition',[300,200,230,800],...
    'MenuBar','none','Color',0.95*[1 1 1])

txt_Version=uicontrol('Parent',h_Control,'Style','text','Position',[10 720 200 75],'String','V8 JorgeQ March2018');

% Magnet Control panel
panel_Magnet=uipanel('Title','Magnet Controls','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 10 160 210]);
    
    txt_VmagnetActual=uicontrol('Parent',panel_Magnet,'Style','text','Position',[0 140 100 16],'String','Actual voltage (V):');
    VmagnetActual=uicontrol('Parent',panel_Magnet,'Style','text','Position',[100 140 40 16],'tag','V_ui','String','0');
    txt_ImagnetActual=uicontrol('Parent',panel_Magnet,'Style','text','Position',[0 160 100 16],'String','Actual current (A):');
    ImagnetActual=uicontrol('Parent',panel_Magnet,'Style','text','Position',[100 160 40 16],'tag','I_ui','String','0');
    
   txt_MagnetSpeed=uicontrol('Parent',panel_Magnet,'Style','text','Position',[0 110 60 25],'String','Stepsize (A)');
    h_MagnetSpeed=uicontrol('Parent',panel_Magnet,'Style','edit','String','0.1','Position',[65 110 40 25],'BackgroundColor','w','tag','MagnetSpeed');
    
    txt_MagnetTime=uicontrol('Parent',panel_Magnet,'Style','text','Position',[0 75 60 25],'String','Steptime (s)');
    h_MagnetTime=uicontrol('Parent',panel_Magnet,'Style','edit','String','0.1','Position',[65 80 40 25],'BackgroundColor','w','tag','MagnetTime');
    
    txt_Imagnet=uicontrol('Parent',panel_Magnet,'Style','text','Position',[0 5 60 25],'String','Current (A)');
    h_Imagnet=uicontrol('Parent',panel_Magnet,'Style','edit','String','0','Position',[65 10 40 25],'BackgroundColor','w','tag','h_Imagnet');
    b_GoToImagnet=uicontrol('Parent',panel_Magnet,'Style','PushButton','String','Go','Position',[115 10 40 25]...
        ,'Callback',@f_GoToImagnet,'Tag','b_GoToImagnet');

    txt_Vmagnet=uicontrol('Parent',panel_Magnet,'Style','text','Position',[0 35 60 25],'String','Voltage');
    h_Vmagnet=uicontrol('Parent',panel_Magnet,'Style','edit','String','0','Position',[65 40 40 25],'BackgroundColor','w','tag','h_Vmagnet');
    b_GoToVmagnet=uicontrol('Parent',panel_Magnet,'Style','PushButton','String','Go','Position',[115 40 40 25]...
        ,'Callback',@f_GoToVmagnet,'Tag','b_GoToVmagnet');


% Basic Controls panel
panel_Basic=uipanel('Title','Basic Controls','FontSize',10 ...
    ,'Units','pixels' ...
    ,'Position',[30 220 160 210]);

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
    ,'Position',[30 435 160 290]);
    exp_list=uicontrol('Parent',panel_1D,'Style','listbox','Position',[10 10 140 240],'tag','List_ui','Callback',@f_exp_list);
    set(exp_list,'String',exps,...
	'Value',1)
    


%% Opening script
f_CloseShutter; %CloseShutter
pause(0.1)
        % do the waveplate thing
        global WPControl WPFig
        [WPControl,WPFig]=WaveplateInit(); % initialize waveplate control
%        set(WPFig,'Visible','off')

%% Subfunctions
    function [] = f_GoToVmagnet (varargin)
        t=GPIB.ChangeMagnetVoltage(str2num(get(h_Vmagnet,'String'))/2,str2num(get(h_MagnetSpeed,'String')),str2num(get(h_MagnetTime,'String')),'kernel_mode_error');
        set(VmagnetActual,'String',t)
        set(h_Imagnet,'String',num2str(GPIB.ReadPSU('curr')))
        set(ImagnetActual,'String',num2str(GPIB.ReadPSU('curr')))
        
        
    end
    function [] = f_GoToImagnet (varargin)
        t=GPIB.RampMagnet(str2num(get(h_Imagnet,'String')),str2num(get(h_MagnetSpeed,'String')),str2num(get(h_MagnetTime,'String')),'kernel_timeout');
        set(ImagnetActual,'String',t)
        set(h_Vmagnet,'String',num2str(GPIB.ReadPSU('volt'),'%20.5f'));
        set(VmagnetActual,'String',num2str(GPIB.ReadPSU('volt'),'%20.5f'));
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
    function [] = f_exp_list(varargin)
        if strcmp(get(gcf,'selectiontype'),'open')
            index_selected = get(exp_list,'Value');
            run_file=[cd '\Experiments\' cell2mat(exp(index_selected))];
            disp(['Loading ' run_file])
            run(run_file)
        end
    end



end