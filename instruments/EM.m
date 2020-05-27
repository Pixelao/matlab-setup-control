classdef EM < handle
    properties
        equipment
    end
    
    methods

        function obj = EM
            obj.equipment.EM=[]; % Electrometer Obj
        end

        function EM_Init(obj,ind,gpibaddress) % Electrometer Initialize
            obj.equipment.EM = gpib('ni',ind,gpibaddress); 
            fopen(obj.equipment.EM(ind)); % Electrometer
            fprintf(obj.equipment.EM(ind),'*RST');
            fprintf(obj.equipment.EM(ind),'VOLT:GUAR OFF');% funcion interna?
            fprintf(obj.equipment.EM(ind),'SENS:FUNC ''VOLT''');% mode
            fprintf(obj.equipment.EM(ind),'VOLT:RANG:AUTO OFF');% auto range
            fprintf(obj.equipment.EM(ind),'SYST:ZCOR OFF');% offset corr off
            fprintf(obj.equipment.EM(ind),'SYST:ZCH OFF');% internal zero off
        end

        function EM_Start(obj,ind) % Electrometer Start settings
            fprintf(obj.equipment.EM(ind),'VOLT:GUAR ON');% funcion interna?
            fprintf(obj.equipment.EM(ind),'SENS:FUNC ''VOLT''');% mode
            fprintf(obj.equipment.EM(ind),'VOLT:RANG:AUTO ON');% auto range
            fprintf(obj.equipment.EM(ind),'SYST:ZCOR ON');% offset corr on
            fprintf(obj.equipment.EM(ind),'SYST:ZCH ON');% internal zero on
            fprintf(obj.equipment.EM(ind),'SYST:ZCOR OFF');% offset corr off
            fprintf(obj.equipment.EM(ind),'SYST:ZCH OFF');% internal zero off
        end

        function r = EM_Read(obj,ind) % Electrometer Read
            EM_Start(obj,ind);
            r=query(obj.equipment.EM(ind),'READ?'); %read signal
        end
    end
end