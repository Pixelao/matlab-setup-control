classdef MS257 < handle
    properties
        equipment
    end
    methods
    
        %MS257 Functions
        function r = MS257move (~,WL)
            [exec_state,output]=system(['.resources\MS257com\MS257com.exe -m ',num2str(WL)]);
            if exec_state==0
                disp(['MS257 Moving wl to ',num2str(WL),' nm'])
                r=str2double(output(17:end));
            else
                r=[];
                error(output)
            end
        end
        function MS257scan (~,startwl,endwl)
            [exec_state,output]=system(['.resources\MS257com\MS257com.exe -s ',num2str(startwl),' ',num2str(endwl)]);
            if exec_state==0
                disp(['MS257 Starting scan from ',num2str(startwl),' to ',num2str(endwl),'.'])
            else
                error(output)
            end
        end
        function MS257abort (~)
            [exec_state,output]=system('.resources\MS257com\MS257com.exe -a');
            if exec_state==0
                disp('MS257 Aborting scan.')
            else
                error(output)
            end
        end
        function MS257status (~)
            [exec_state,output]=system('.resources\MS257com\MS257com.exe -st');
            if exec_state==0
                disp('MS257 Status.')
            else
                error(output)
            end
        end

    end
end