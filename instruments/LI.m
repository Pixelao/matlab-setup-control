classdef LI < handle

    methods

        function obj = SM
            obj.LI=[]; % LockIn Obj
        end

        function LI_Init(obj,gpibaddress) % Initialize instruments
            obj.LI = gpib('ni',0,gpibaddress); fopen(obj.LI); % Lock-in SR830
        end

        function [xr1,yt2] = LI_Read(obj,mode) % Lock-In Read
            xr1 = [];
            yt2 = [];
            if ~(strcmp(mode,'XY') || strcmp(mode,'RT') || strcmp(mode,'CH'))
                error('GPIBManager.m: Mode should be either "XY", "RT" or "CH".')
                return
            end
            for h = obj.LI
                if strcmp(mode,'XY')
                    value = query(h, 'SNAP?1,2');
                elseif strcmp(mode,'RT')
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
    end
end