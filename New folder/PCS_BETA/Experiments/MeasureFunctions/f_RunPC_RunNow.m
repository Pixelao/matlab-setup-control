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