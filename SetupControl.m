classdef SetupControl < handle
    properties
        equipment
    end
    methods
        function obj = SetupControl
            obj.equipment.LI=[]; %Lock-Inss
            obj.equipment.SM=[]; %Source Meters
            obj.equipment.EM=[]; %Electrometers
            obj.equipment.ITC503=[];%TemperatureController
        end
        function InitComms(obj)
            instrreset;
            obj.equipment.LI = gpib('ni',0,8); fopen(obj.equipment.LI); %Lock-in SR830
            %obj.equipment.LI(2) = gpib('ni',0,9); fopen(obj.equipment.LI(2)); %Lock-in SR830
            obj.equipment.SM = gpib('ni',0,26); fopen(obj.equipment.SM(1)); %Source meter
            obj.equipment.SM(2) = gpib('ni',0,28); fopen(obj.equipment.SM(2)); %Source meter
            obj.equipment.ITC503 =gpib('ni',0,13); fopen(obj.equipment.ITC503);...
                obj.equipment.ITC503.EOSMode='read&write';...
                obj.equipment.ITC503.EOSCharCode='CR';%TemperatureController
            %obj.equipment.SM(2) = gpib('ni',0,28); fopen(obj.equipment.SM(2)); %Source meter
            %obj.equipment.EM = gpib('ni',0,13); fopen(obj.equipment.EM(1)); %Electrometer
            %obj.equipment.EM(2) = gpib('ni',0,14); fopen(obj.equipment.EM(2)); %Electrometer
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
                        Name=query(obj.equipment.ITC503,'V')
                    else
                        Name=''
                    end
            end
        end
        function r = SM_ReadI(obj,ind,channel)
            if ind > length(obj.equipment.SM)
                r= 'NaN';
            else
                switch channel % select channel
                    case 1
                        r=query(obj.equipment.SM(ind),'print(smua.measure.i())');
                    case 2
                        r=query(obj.equipment.SM(ind),'print(smub.measure.i())');
                end
            end
        end
        function r = SM_ReadV(obj,ind,channel)
            if ind > length(obj.equipment.SM)
                r= 'NaN';
            else
                switch channel % select channel
                    case 1
                        r=query(obj.equipment.SM(ind),'print(smua.measure.v())');
                    case 2
                        r=query(obj.equipment.SM(ind),'print(smub.measure.v())');
                end
            end
        end
        function [] = SM_RampV(obj,ind,channel,Vstart,Vend,stepsize,delay)
            if Vstart>Vend
                stepsize=-abs(stepsize);
            elseif Vstart<Vend
                stepsize=abs(stepsize);
            end
            Vstart
            stepsize
            Vend
            V=[Vstart:stepsize:Vend Vend] %define ramp
            disp(['ramping channel ',num2str(channel),' to V = ',num2str(Vend)])
            switch channel % select channel
                case 1
                    command='smua.source.levelv = ';
                case 2
                    command='smub.source.levelv = ';
            end
            for n=1:length(V) % do ramp
                message=strcat(command,num2str(V(n)));
                fprintf(obj.equipment.SM(ind),message);
                pause(delay)
            end
            disp('ramp done')
        end
        function [] = SM_RampI(obj,ind,channel,Istart,Iend,stepsize,delay)
            if Istart>Iend
                stepsize=-abs(stepsize);
            elseif Istart<Iend
                stepsize=abs(stepsize);
            end
            I=[Istart:stepsize:Iend Iend]; %define ramp
            disp(['ramping channel ',num2str(channel),' to V = ',num2str(Iend)])
            switch channel % select channel
                case 1
                    command='smua.source.leveli = ';
                case 2
                    command='smub.source.leveli = ';
            end
            for n=1:length(I) % do ramp
                message=strcat(command,num2str(I(n)));
                fprintf(obj.equipment.SM(ind),message);
                pause(delay)
            end
            disp('ramp done')
        end
        function [] = SM_SetV(obj,ind,channel,V)
            switch channel % select channel
                case 1
                    command='smua.source.levelv = ';
                case 2
                    command='smub.source.levelv = ';
            end
            message=strcat(command,num2str(V));
            fprintf(obj.equipment.SM(ind),message);
        end
        function [] = SM_SetI(obj,ind,channel,I)
            switch channel % select channel
                case 1
                    command='smua.source.leveli = ';
                case 2
                    command='smub.source.leveli = ';
            end
            message=strcat(command,num2str(I));
            fprintf(obj.equipment.SM(ind),message);
        end
        function x=queryITC(obj,command)
            clrdevice(obj.equipment.ITC503)
            x=query(obj.equipment.ITC503,command);
        end
        function T = ITC503_ReadT(obj)
            queryITC(obj,'C3');
            x=queryITC(obj,'R1');
            T=str2double(extractAfter(x,1));% read temperature
        end
        function St = ITC503_ReadSetT(obj)
            queryITC(obj,'C3');
            x=queryITC(obj,'R0');
            St=str2double(extractAfter(x,1));% read set temperature
        end
        function stabilizationT = ITC503_SetT(obj,SetT,Tol,Time)
                queryITC(obj.equipment.ITC503,'C3');%Remote Mode
                queryITC(obj.equipment.ITC503,['T' num2str(SetT)]); %set temperature
                queryITC(obj.equipment.ITC503,'A1');
                queryITC(obj.equipment.ITC503,'L1');%Auto-PID
                Setpoint=str2double(extractAfter(queryITC(obj.equipment.ITC503,'R0'),1));
                check=0;
                while check<Time
                    T=str2double(extractAfter(queryITC(obj.equipment.ITC503,'R1'),1));% read temperature
                    stabilization=0;
                    if Setpoint<T+Tol && Setpoint>T-Tol
                        check=check+1;
                    else 
                        check=0;
                    end
                    pause(1)
                end
                stabilizationT=1;
        end
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
        function EM_Init(obj,ind,mode)
            %fprintf(obj.equipment.EM(ind),'*RST')
            fprintf(obj.equipment.EM(ind),'VOLT:GUAR OFF')% funcion interna?
            fprintf(obj.equipment.EM(ind),'SENS:FUNC ''VOLT''')% mode
            fprintf(obj.equipment.EM(ind),'VOLT:RANG:AUTO OFF')% auto range
            fprintf(obj.equipment.EM(ind),'SYST:ZCOR OFF')% offset corr off
            fprintf(obj.equipment.EM(ind),'SYST:ZCH OFF')% internal zero off
        end
        function EM_Start(obj,ind,mode)
            %fprintf(obj.equipment.EM(ind),'VOLT:GUAR ON')% funcion interna?
            %fprintf(obj.equipment.EM(ind),'SENS:FUNC ''VOLT''')% mode
            %fprintf(obj.equipment.EM(ind),'VOLT:RANG:AUTO ON')% auto range
            %fprintf(obj.equipment.EM(ind),'SYST:ZCOR ON')% offset corr on
            %fprintf(obj.equipment.EM(ind),'SYST:ZCH ON')% internal zero on
            %fprintf(obj.equipment.EM(ind),'SYST:ZCOR OFF')% offset corr off
            %fprintf(obj.equipment.EM(ind),'SYST:ZCH OFF')% internal zero off
        end
        function r = EM_Read(obj,ind)
            EM_Start(obj,ind,1);
            r=query(obj.equipment.EM(ind),'READ?'); %read signal
        end
        function r = GoToWL (obj,WL)
            disp(['Moving to ',num2str(WL)])
            [exec_state,output]=system(['.resources\MS257com\MS257com.exe -m ',num2str(WL)]);
            if exec_state==0
                disp(['Laser set to ',num2str(WL),' nm'])
                r=str2num(output(17:end));
            else
                r=[];
                error(output)
            end
        end

        function p = GoToPW(obj,PW)
            disp(['Setting',num2str(PW)])
            output=system(['.resources\NKTcom\NKTcom.exe -p',num2str(PW)]);
            if output=="DONE"
                disp(['Power set to ',num2str(PW),' %'])
                p=str2double(PW);
            else
                p=[];
                error(output)
            end
        end
        
        %LA functions
        function r = LAread(~)
            [exec_state,output]=system('.resources\NKTcom\NKTcom.exe -r');
            if exec_state==0
                r = extractAfter(output,".dll");
            else
                r=999;
                error(output)
            end
        end

        function LAgo(~,PW)
            system(['.resources\NKTcom\NKTcom.exe -p ',num2str(PW)]);
            disp(['Laser Power set to',PW,'%'])
        end

        function LAon(~)
            system('.resources\NKTcom\NKTcom.exe -on');
            disp('Laser Emission ON')
        end

        function LAoff(~)
            system('.resources\NKTcom\NKTcom.exe -off ');
            disp('Laser Emission OFF')
        end
    end
end