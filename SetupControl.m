classdef SetupControl < handle
    properties
        equipment
    end

    methods
        
        function obj = SetupControl
            obj.equipment.LI = [];
            obj.equipment.SM = [];
            obj.equipment.EM = [];
            obj.equipment.ITC503 = [];
        end
        
        function InitComms(obj) % Initialize instruments
            %LI_Init(LI,4);
            SM_Init(SM,1,6);
            LI_Init(LI,4);
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