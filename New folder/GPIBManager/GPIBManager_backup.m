classdef (Sealed) GPIBManager_backup < handle
% class used for initialization, connection and readout of GPIB connected
% lab equipment.
    
    properties
        keithley_int_time = 1
    end

    properties (Access = private)
        equipment
        idns
    end
    
    % Regulate that only 1 instance of GPIBManager can exist with a class-wide,
    % static method
    methods (Static)
        
        % The "effective" constructor, called as Optodac.getInstance
        function gpibmanager = getInstance()
            persistent GPIBMan
            if isempty(GPIBMan) || ~isvalid(GPIBMan)
                GPIBMan = GPIBManager();
                gpibmanager = GPIBMan;
                disp('Instantiated GPIBManager.')
            else
                gpibmanager = GPIBMan;
                %warning('GPIBManager.m: GPIBManager is already initialized.')
            end
        end
        
    end
    
    methods (Access = private)
        
        % Constructor (can only be called by the static getInstance
        % function)
        function obj = GPIBManager()
            % UpdateConnections() to find and initiate keithleys and lockins.
            UpdateConnections(obj);
        end
        
        % Find all connected instruments, open a visa-gpib channel and
        % store information about the instruments.
        function FindAll(obj)
            obj.idns = {};
            obj.equipment = struct('keithley',[],'lockin',[],'else',[]);
            for i = 0:30
                address = ['GPIB0::' num2str(i) '::0::INSTR'];
                handle = Open(obj,address);
                try
                    idn = query(handle, '*IDN?');
                catch
                    idn = 'None';
                end
                obj.idns{end+1,1} = idn;
                if ~isempty(strfind(idn,'SR830'))
                    obj.equipment.lockin = [obj.equipment.lockin handle];
                elseif ~isempty(strfind(idn,'KEITHLEY'))
                    obj.equipment.keithley = [obj.equipment.keithley handle];
                elseif ~strcmp(idn,'None')
                    obj.equipment.else = [obj.equipment.else handle];
                end
            end            
        end
        
        % Initialize keithley settings.
        function InitKeithley(obj,handle)
            int_t = obj.keithley_int_time;
            % Check if the supplied integration time is in the range 
            % supported by the Keithley 2000.
            if int_t < 0.1 || int_t > 10
                error('Integration time out of range. The integration time should be between 0.1 and 10');
            end
            for h = handle
                % Prepare the Keithley 2000 for measuring
                fprintf(h, '*rst;status:preset;*cls');
                % Turn error beep off
                fprintf(h, ':SYST:BEEP:STAT OFF');
                % Display off for an increased measurement rate
                %fprintf(h, ':DISPlay:ENABle 0');
                % Never go to idle between measurements
                fprintf(h,':init:cont on');
                % Set the integration time in Number of Power Line Cycles (NPLC)
                fprintf(h,[':SENSE:VOLT:DC:NPLC ' num2str(int_t)]);
            end
        end
        
        % Initialize lockin settings.
        function InitLockin(~,handle)
            for h = handle
                % Set output of lockin to GPIB
                fprintf(h, 'OUTX1');
                % Unlock front panel
                fprintf(h, 'OVRM 1');
            end
        end
        
        % Open a visa-gpib connection with instruments.
        function handle = Open(~,instr)
            % Find a VISA-GPIB object.
            handle = instrfind('Type', 'visa-gpib', 'RsrcName', instr, 'Tag', '');

            % Create the VISA-GPIB object if it does not exist
            % otherwise use the object that was found.
            if isempty(handle)
                handle = visa('NI', instr);
            else
                fclose(handle);
                handle = handle(1);
            end
            fopen(handle);
        end
        
    end
    
    methods (Access = public)
        
        % Close all gpib connections to all connected instruments.
        function CloseAll(obj)
            fclose(obj.equipment.keithley);
            fclose(obj.equipment.lockin);
            fclose(obj.equipment.else);
        end
        
        % Return a vector with the value of all connected keithleys.
        function voltage = ReadKeithleys(obj)
            voltage = [];
            for h = obj.equipment.keithley
                voltage(end+1) = str2num(query(h, ':SENS:DATA?'));
            end
        end
        
        % Return two vectors with the x/r and y/theta values of all
        % connected lockins.
        function [xr,yt] = ReadLockins(obj,mode)
            xr = [];
            yt = [];
            % Mode should be either xy or rt
            if ~(strcmp(mode,'xy') || strcmp(mode,'rt'))
                error('GPIBManager.m: Mode should be either "xy" or "rt".')
                return
            end
            for h = obj.equipment.lockin
                if strcmp(mode,'xy')
                    value = query(h, 'SNAP?1,2');
                elseif strcmp(mode,'rt')
                    value = query(h, 'SNAP?3,4');
                end
                % Convert string to double 2x1 array
                value = str2num(value);
                xr(end+1) = value(1);
                yt(end+1) = value(2);
            end
        end
        
        % Return a list with the gpib numbers of all connected keithleys
        function GPIBnums = GetKeithleyNums(obj)
            if iscell(obj.equipment.keithley.PrimaryAddress)
                GPIBnums = cell2mat(obj.equipment.keithley.PrimaryAddress);
            elseif isa(obj.equipment.keithley.PrimaryAddress,'double')
                GPIBnums = obj.equipment.keithley.PrimaryAddress;
            end
        end
        
        % Return a list with the gpib numbers of all connected lockins
        function GPIBnums = GetLockinNums(obj)
            if iscell(obj.equipment.lockin.PrimaryAddress)
                GPIBnums = cell2mat(obj.equipment.lockin.PrimaryAddress);
            elseif isa(obj.equipment.lockin.PrimaryAddress,'double')
                GPIBnums = obj.equipment.lockin.PrimaryAddress;
            end
        end
        
        % Return a list with a equipment names
        function [id,eq] = GetEquipmentList(obj)
            id = obj.idns;
            eq = obj.equipment;
        end
        
        % Recheck all gpib ports and store connected instruments
        function [idns,list] = UpdateConnections(obj)
            FindAll(obj);
            InitKeithley(obj,obj.equipment.keithley);
            InitLockin(obj,obj.equipment.lockin);
            idns = obj.idns;
            list = obj.equipment;
        end
        
    end
    
end

