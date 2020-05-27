classdef ITC503 < handle

    methods

        function obj = ITC503
            obj.ITC503=[]; % ITC503 Obj
        end

        function ITC503_Init(obj,gpibaddress)   % Initialize instrument
            ITC503 = gpib('ni',0,gpibaddress);  % ITC503
            fopen(ITC503);                      % ITC503
            ITC503.EOSMode='read&write';        % ITC503 EOSmode
            ITC503.EOSCharCode='CR';            % ITC503 CharCode
        end

        function queryITC(obj,command) % ITC503 query com protocol
            clrdevice(ITC503)
            query(ITC503,command)
        end

        function T = ITC503_ReadT(obj) % ITC503 Read temperature
            T=extractAfter(queryITC(ITC503,'R1'),1);
        end

        function stabilizationT = ITC503_SetT(obj,SetT,Tol,Time) % ITC503 Stabilization to set temperature
            queryITC(ITC503,'C3'); % Remote Mode
            queryITC(ITC503,['T' num2str(SetT)]); % Set temperature
            queryITC(ITC503,'A1');
            queryITC(ITC503,'L1'); % Auto-PID
            Setpoint=str2double(extractAfter(queryITC(ITC503,'R0'),1));
            check=0;
            while check<Time
                T=str2double(extractAfter(queryITC(ITC503,'R1'),1));% read temperature
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