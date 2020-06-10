classdef ITC503 < handle
    properties
        equipment
    end
    methods

        %ITC503 Functions
        function x=queryITC(obj,command)
            clrdevice(obj.equipment.ITC503)
            x=query(obj.equipment.ITC503,command);
        end
        
        function T = ITC503_ReadT(obj)
            queryITC(obj,'C3');
            x=queryITC(obj,'R1');
            T=str2double(extractAfter(x,1));% read temperature
        end

        function St = ITC503_ReadSetT(obj)
            queryITC(obj,'C3');
            x=queryITC(obj,'R0');
            St=str2double(extractAfter(x,1));% read set temperature
        end

        function stabilizationT = ITC503_SetT(obj,SetT,Tol,Time)
            queryITC(obj,'C3');%Remote Mode
            queryITC(obj,['T' num2str(SetT)]); %set temperature
            queryITC(obj,'A1');
            queryITC(obj,'L1');%Auto-PID
            Setpoint=str2double(extractAfter(queryITC(obj,'R0'),1));
            check=0;
            while check<Time
                T=str2double(extractAfter(queryITC(obj,'R1'),1))% read temperature
                stabilization=0;
                if Setpoint<T+Tol && Setpoint>T-Tol
                    check=check+1;
                else
                    check=0;
                end
                pause(1)
            end
            stabilizationT=1;
        end

    end
end