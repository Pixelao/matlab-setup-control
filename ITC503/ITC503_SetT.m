        function stabilization=ITC503_SetT(obj,SetT,Tol,Time)
        fopen(obj);
                queryITC(obj,'C3');%Remote Mode
                queryITC(obj,['T' num2str(SetT)]); %set temperature
                queryITC(obj,'A1');%Autoheater
                queryITC(obj,'L1');%Auto-PID
                Setpoint=str2double(extractAfter(queryITC(obj,'R0'),1));
                check=0;
                while check<Time
                    T=str2double(extractAfter(queryITC(obj,'R1'),1));% read temperature
                    disp(T)
                    if Setpoint<T+Tol && Setpoint>T-Tol
                        check=check+1;
                    else 
                        check=0;
                    end
                    pause(1)
                end
                stabilization=1
          fclose(obj)
        end