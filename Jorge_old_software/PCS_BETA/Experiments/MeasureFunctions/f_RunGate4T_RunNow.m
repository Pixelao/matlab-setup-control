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