classdef SetupControl < handle
    properties
        equipment
    end

    methods

        function obj = SetupControl
            obj.equipment.EM=[];        % Electrometers Obj
            obj.equipment.ITC503=[];    % ITC503 Obj
        end

        function InitComms(obj) % Initialize instruments
            %instrreset;
        end

        function CheckInstName = IDN(obj,instr,ind) % Check instrument Name
            switch instr
                case 'LI'
                    if ind<=length(obj.equipment.LI)
                        CheckInstName=query(obj.equipment.LI(ind),'*IDN?');
                    else
                        CheckInstName='';
                    end
                case 'SM'
                    if ind<=length(obj.equipment.SM)
                        CheckInstName=query(obj.equipment.SM(ind),'*IDN?');
                    else
                        CheckInstName='';
                    end
                case 'ITC503'
                    if ind<=length(obj.equipment.ITC503)
                        CheckInstName=query(obj.equipment.ITC503,'V')
                    else
                        CheckInstName=''
                end
            end
        end
    end
end