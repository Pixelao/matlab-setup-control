
classdef measurement_device < matlab.System
    % Measurement device
    properties
        id              % Internal identification of device
        GPIB            % Does it use GPIB manager?
        ntimes          % number of measurements per cycle
        num             % number of device
        type            % What is the type, Solstis, Keithley, Lockin etc.
        quantity        % What physical quantity does it measure or set
        mode            % Does this device measure or set a value
        input_array     % Set to what value if set mode
        delay = '0.1'   % Delay between actions
    end

    properties (Hidden,Constant)
       % Some properties are limited to certain values
       ts={'lockin','keithley','vsource','solstis','shutter','pause'};
       ms={'read','source','open','close','shutter'};
       def_val={'200:250','1:10','1:10','700:1000','1:10','1:2'};
       typeSet = matlab.system.StringSet(measurement_device.ts);
       modeSet = matlab.system.StringSet(measurement_device.ms);
    end
    methods static
        % Methods that stay the same
    end
    methods (Access = public)
        function data=keithley(obj,~)
            global GPIB
            data=GPIB.ReadKeithleys();
            data=data(obj.num);
        end
        function data=pause(obj,~)
            pause(min(input_array))
        end
        function data=lockin(obj,~)
            global GPIB
            thelockins=GPIB.ReadLockins('CH');
            data=thelockins(obj.num);
        end
        function data=solstis(obj,i)
            global SOL1 SOL2 WM
            switch obj.num
                case 1
                    c=2;
                    SOL=SOL1;
                case 2
                    SOL=SOL2;
                    c=1;
            end
            disp(['Solsits number ' num2str(obj.num)])
            WM.SwitchToChannel(obj.num);
            SOL.GoToWL(obj.input_array(i)); %go to wl
            sol_status=SOL.GetWL(); 
            data=sol_status.current_wavelength;
            WM.SwitchToChannel(c);
        end
        function data=shutter(obj)
            global GPIB
            switch obj.mode
                case 'open'
                    GPIB.OD.SetShutter(obj.num,'open');
                case 'closed'
                    GPIB.OD.SetShutter(2,'close');
            end
        end
        function data=vsource(obj,i,varargin)
            global GPIB
            handle= GPIB.Vsource(1);
            handle2=GPIB.Vsource(2);
            switch obj.mode
                case 'read'
                    fprintf(handle,':OUTP ON');
                    data=eval(['[',query(handle,':READ?'),']']);
                case 'source'
                    if ~isempty(strfind(obj.GPIB.vsource.idn,'KEITHLEY INSTRUMENTS INC.,MODEL 2410')) 
                        rampV_2410(handle2,V_sweep(i),0.1);
                    elseif ~isempty(strfind(obj.GPIB.vsource.idn,'KEITHLEY INSTRUMENTS,MODEL 2450')) 
                        fprintf(handle2,[':SOUR:VOLT:LEV ' obj.input_array(i)]);
                    end
            end
        end
    end
end

