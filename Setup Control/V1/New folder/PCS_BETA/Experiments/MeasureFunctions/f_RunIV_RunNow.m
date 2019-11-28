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