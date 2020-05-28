classdef SM < handle
    properties
        equipment
    end

    methods

        function SM_Init(obj,ind,gpibaddress) % Initialize instrument
            obj.equipment.SM = gpib('ni',ind,gpibaddress);
            fopen(obj.SM(ind)); % SourceMeter 
        end

        function r = SM_ReadI(obj,ind,channel) % SourceMeter Read I
            if ind > length(SM)
                r= 'NaN';
            else
                switch channel % select channels
                    case 1
                        r=query(obj.equipment.SM(ind),'print(smua.measure.i())');
                    case 2
                        r=query(obj.equipment.SM(ind),'print(smub.measure.i())');
                end
            end
        end

        function r = SM_ReadV(obj,ind,channel) % SourceMeter Read V
            if ind > length(SM)
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

        function [] = SM_RampV(obj,ind,channel,Vstart,Vend,stepsize,delay) % SourceMeter V Ramp
            if Vstart>Vend
                stepsize=-abs(stepsize);
            elseif Vstart<Vend
                stepsize=abs(stepsize);
            end
            V=[Vstart:stepsize:Vend Vend]; %define ramp
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

        function [] = SM_RampI(obj,ind,channel,Istart,Iend,stepsize,delay) % SourceMeter I Ramp
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

        function [] = SM_SetV(obj,ind,channel,V) % SourceMeter Set V
            switch channel % select channel
                case 1
                    command='smua.source.levelv = ';
                case 2
                    command='smub.source.levelv = ';
            end
            message=strcat(command,num2str(V));
            fprintf(obj.equipment.SM(ind),message);
        end

        function [] = SM_SetI(obj,ind,channel,I) % SourceMeter Set I
            switch channel % select channel
                case 1
                    command='smua.source.leveli = ';
                case 2
                    command='smub.source.leveli = ';
            end
            message=strcat(command,num2str(I));
            fprintf(obj.equipment.SM(ind),message);
        end
    end
end