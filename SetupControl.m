classdef SetupControl < handle
    properties
        equipment
    end
    
    methods

        %Init Functions
        function obj = SetupControl
            obj.equipment.LI=[]; %Lock-Ins
            obj.equipment.SM=[]; %Source Meters
            obj.equipment.EM=[]; %Electrometers
            obj.equipment.ITC503=[];%TemperatureController
        end

        function InitComms(obj)
            instrreset;
            %pyversion C:\Python27\python.exe
            try obj.equipment.LI = gpib('ni',0,8); fopen(obj.equipment.LI); disp("LI 1 FOUND") %Lock-in SR830
            catch; obj.equipment.LI = []; disp("LI 1 ERROR")
            end
            if length(obj.equipment.LI)==1
                try obj.equipment.LI(2) = gpib('ni',0,9); fopen(obj.equipment.LI(2)); disp("LI 2 FOUND") %Lock-in SR830
                catch; obj.equipment.LI (2) = []; disp("LI 2 ERROR")
                end
            end
            try obj.equipment.SM = gpib('ni',0,26); fopen(obj.equipment.SM(1)); disp("SM 1 FOUND") %Source meter
            catch; obj.equipment.SM = []; disp("SM 1 ERROR")
            end
            if length(obj.equipment.SM)==1
                try obj.equipment.SM(2) = gpib('ni',0,28); fopen(obj.equipment.SM(2)); disp("SM 2 FOUND") %Source meter
                catch; obj.equipment.SM (2) = []; disp("SM 2 ERROR")
                end
            end
            try obj.equipment.EM = gpib('ni',0,18); fopen(obj.equipment.EM(1)); disp("EM 1 FOUND") %Electrometer
            catch; obj.equipment.EM = []; disp("EM 1 ERROR")
            end
            if length(obj.equipment.EM)==1
                try obj.equipment.EM(2) = gpib('ni',0,14); fopen(obj.equipment.EM(2)); disp("EM 2 FOUND") %Electrometer
                catch; obj.equipment.EM (2) = []; disp("EM 2 ERROR")
                end
            end
            try obj.equipment.ITC503 = gpib('ni',0,13); fopen(obj.equipment.ITC503);obj.equipment.ITC503.EOSMode='read&write';obj.equipment.ITC503.EOSCharCode='CR'; disp("ITC503 1 FOUND") %TemperatureController
            catch; obj.equipment.ITC503 = []; disp("ITC503 1 ERROR")
            end
        end

        function Name = IDN(obj,instr,ind)
            switch instr
                case 'LI'
                    if ind<=length(obj.equipment.LI)
                        Name=query(obj.equipment.LI(ind),'*IDN?');
                    else
                        Name='';
                    end
                case 'SM'
                    if ind<=length(obj.equipment.SM)
                        Name=query(obj.equipment.SM(ind),'*IDN?');
                    else
                        Name='';
                    end
                case 'ITC503'
                    if ind<=length(obj.equipment.ITC503)
                        Name=query(obj.equipment.ITC503,'V');
                    else
                        Name='';
                    end
            end
        end
        
    end
end