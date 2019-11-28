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