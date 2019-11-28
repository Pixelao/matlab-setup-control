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