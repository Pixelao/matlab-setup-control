classdef LA < handle
    properties
        equipment
    end
    methods

        %LI Functions
        function [xr1,yt2] = LI_Read(obj,mode)
            xr1 = [];
            yt2 = [];
            % Mode should be either xy or rt
            if ~(strcmp(mode,'xy') || strcmp(mode,'rt') || strcmp(mode,'CH'))
                error('GPIBManager.m: Mode should be either "xy" or "rt".')
                return
            end
            for h = obj.equipment.LI
                if strcmp(mode,'xy')
                    value = query(h, 'SNAP?1,2');
                elseif strcmp(mode,'rt')
                    value = query(h, 'SNAP?3,4');
                elseif strcmp(mode,'CH')
                    value = query(h, 'SNAP?10,11');
                end
                
                % Convert string to double 2x1 array
                value = str2num(value);
                xr1(end+1) = value(1);
                yt2(end+1) = value(2);
            end
        end
        function [FREQ] = LI_FreqRead(obj)
            FREQ=[];
            for h = obj.equipment.LI
                value=query(h, 'FREQ?');
                % Convert string to double 2x1 array
                value = str2num(value);
                FREQ(end+1) = value(1);
            end
        end
        function [] = LI_FreqSet(obj,ind,FREQ)
            h = obj.equipment.LI(ind)
            message=strcat('FREQ ',num2str(FREQ));
            fprintf(h, message);
            % Convert string to double 2x1 array
            
        end

        %EM Functions
        function EM_Init(obj,ind,mode)
            %fprintf(obj.equipment.EM(ind),'*RST')
            fprintf(obj.equipment.EM(ind),'VOLT:GUAR OFF')% funcion interna?
            fprintf(obj.equipment.EM(ind),'SENS:FUNC ''VOLT''')% mode
            fprintf(obj.equipment.EM(ind),'VOLT:RANG:AUTO OFF')% auto range
            fprintf(obj.equipment.EM(ind),'SYST:ZCOR OFF')% offset corr off
            fprintf(obj.equipment.EM(ind),'SYST:ZCH OFF')% internal zero off
        end
        function EM_Start(obj,ind,mode)
            %fprintf(obj.equipment.EM(ind),'VOLT:GUAR ON')% funcion interna?
            %fprintf(obj.equipment.EM(ind),'SENS:FUNC ''VOLT''')% mode
            %fprintf(obj.equipment.EM(ind),'VOLT:RANG:AUTO ON')% auto range
            %fprintf(obj.equipment.EM(ind),'SYST:ZCOR ON')% offset corr on
            %fprintf(obj.equipment.EM(ind),'SYST:ZCH ON')% internal zero on
            %fprintf(obj.equipment.EM(ind),'SYST:ZCOR OFF')% offset corr off
            %fprintf(obj.equipment.EM(ind),'SYST:ZCH OFF')% internal zero off
        end
        function r = EM_Read(obj,ind)
            EM_Start(obj,ind,1);
            r=query(obj.equipment.EM(ind),'READ?'); %read signal
        end

        %MS257 Functions
        function r = MS257move (~,WL)
            [exec_state,output]=system(['.resources\MS257com\MS257com.exe -m ',num2str(WL)]);
            if exec_state==0
                disp(['MS257 Moving wl to ',num2str(WL),' nm'])
                r=str2double(output(17:end));
            else
                r=[];
                error(output)
            end
        end
        function MS257scan (~,startwl,endwl)
            [exec_state,output]=system(['.resources\MS257com\MS257com.exe -s ',num2str(startwl),' ',num2str(endwl)]);
            if exec_state==0
                disp(['MS257 Starting scan from ',num2str(startwl),' to ',num2str(endwl),'.'])
            else
                error(output)
            end
        end
        function MS257abort (~)
            [exec_state,output]=system('.resources\MS257com\MS257com.exe -a');
            if exec_state==0
                disp('MS257 Aborting scan.')
            else
                error(output)
            end
        end
        function MS257status (~)
            [exec_state,output]=system('.resources\MS257com\MS257com.exe -st');
            if exec_state==0
                disp('MS257 Status.')
            else
                error(output)
            end
        end
    
    end
end