function [] = f_RunPCCH_RunNow (varargin)
        global h_FR_Min h_FR_Max h_FR_Step b_Pause b_Abort check_FR_Custom h_FR_Custom check_AutoSave
        hPlot=plot(NaN,NaN,'Color',[0.5 0.5 0.5]); hold on;
        hPlot_Lock=plot(NaN,NaN,'r');
        Idata=[];
        IdataD=[];
        fr=[];
        pow=[];
        %disp('Setting laser to starting wavelength.')
        %WLM.SwitchToChannel(2);
        %SOL.GoToWL(str2num(get(h_wstart,'String'))); %go to wl
        %A=SOL.GetWL(); start_wl=A.current_wavelength;
        %WLM.SwitchToChannel(1)
        % Solstis scan parameters
        if get(check_FR_Custom,'Value')==1
            fr_sweep=eval(get(h_FR_Custom,'String'));
        else
            fr_sweep=[str2num(get(h_FR_Min,'String')):str2num(get(h_FR_Step,'String')):str2num(get(h_FR_Max,'String'))];
        end
        h_PCCH2=findall(0,'tag','mainFig');
        set(h_PCCH2,'XLim',[min(fr_sweep) max(fr_sweep)])
        tic %count timer
            disp('Measurement starting')
        for j=1:length(fr_sweep)
            while get(b_Pause,'Value')==1
                pause(0.2)
            end
            if get(b_Abort,'Value')==1
                set(b_Abort,'Value',0)
                fprintf('Measurement aborted by user \n')
                return
            end
            fprintf(lockin,['FREQ ' num2str(fr_sweep(j))]);
            act_freq = query(lockin, 'FREQ?');
            the_fr=str2num(act_freq);
            
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
                AA_Lock=thelockins(1);
                TT_Lock=thelockins(2);% read measurement
                theII_Lock(i)=AA_Lock;
                theta_lockins(i)=TT_Lock;
            end
            OD.SetShutter(2,'close');
            tic %start dark time cronometer
            norm(j,:) = GPIB.ReadKeithleys(); % Caution Keithley connected
            theI=mean(theII);
            theI_D=mean(theII_D);
            theI_Lock=mean(theII_Lock);
            theT_Lock=mean(theta_lockins);
            Idata=[Idata theI];
            IdataD=[IdataD theI_D];
            clear theII theII_D theII_Lock theta_lockins
            % Plotting
            fr=[fr the_fr];
                      
            set(hPlot,'YData',[get(hPlot,'YData') (theI-theI_D)]...
                ,'XData',[get(hPlot,'XData') the_fr])
            set(hPlot_Lock,'YData',[get(hPlot_Lock,'YData') theI_Lock*sin(theT_Lock)]...
                ,'XData',[get(hPlot_Lock,'XData') the_fr])
            disp(['Run ' num2str(j)])
        end
        fprintf(lockin,'FREQ 200');
        disp('Done')
        
        t=clock; name=strcat(num2str(t(4)),'h',num2str(t(5)),'m');
        data.comment=name;
        % save data
        if get(check_AutoSave,'Value')
            filename=create_filenames(name);  save(filename); savefig(gcf,[filename '_plot.fig']);
            savefig(gcf,[filename '_plot.fig'])
        end
    end