classdef LA < handle
    properties
        equipment
    end
    methods
        
        %LA Functions
        function r = LAread(~)
            [exec_state,output]=system('.resources\NKTcom\NKTcom.exe -r');
            if exec_state==0
                r = output;
            else
                r=999;
                error(output)
            end
        end
        function LAgo(~,PW)
            system(['.resources\NKTcom\NKTcom.exe -p ',num2str(PW)]);
        end
        function LAon(~)
            system('.resources\NKTcom\NKTcom.exe -on');
        end
        function LAoff(~)
            system('.resources\NKTcom\NKTcom.exe -off ');
        end
    
    end
end