classdef LI < handle
    properties
        equipment
    end
    methods

        function LI_Init(obj,gpibaddress)   % Initialize instruments
            obj.equipment.LI = gpib('ni',0,gpibaddress);  % Lock-in SR830
            fopen(LI);                      % Lock-in SR830
        end

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
    end
end