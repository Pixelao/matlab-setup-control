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