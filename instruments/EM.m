classdef EM < handle

    methods

        function obj = EM
            obj.EM=[]; % Electrometer Obj
        end

        function EM_Init(obj,ind,gpibaddress) % Electrometer Initialize
            EM = gpib('ni',ind,gpibaddress); 
            fopen(EM(ind)); % Electrometer
            fprintf(EM(ind),'*RST')
            fprintf(EM(ind),'VOLT:GUAR OFF')% funcion interna?
            fprintf(EM(ind),'SENS:FUNC ''VOLT''')% mode
            fprintf(EM(ind),'VOLT:RANG:AUTO OFF')% auto range
            fprintf(EM(ind),'SYST:ZCOR OFF')% offset corr off
            fprintf(EM(ind),'SYST:ZCH OFF')% internal zero off
        end

        function EM_Start(obj,ind) % Electrometer Start settings
            %fprintf(EM(ind),'VOLT:GUAR ON')% funcion interna?
            %fprintf(EM(ind),'SENS:FUNC ''VOLT''')% mode
            %fprintf(EM(ind),'VOLT:RANG:AUTO ON')% auto range
            %fprintf(EM(ind),'SYST:ZCOR ON')% offset corr on
            %fprintf(EM(ind),'SYST:ZCH ON')% internal zero on
            %fprintf(EM(ind),'SYST:ZCOR OFF')% offset corr off
            %fprintf(EM(ind),'SYST:ZCH OFF')% internal zero off
        end

        function r = EM_Read(obj,ind) % Electrometer Read
            EM_Start(obj,ind);
            r=query(EM(ind),'READ?'); %read signal
        end