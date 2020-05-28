function p = NKT_SetPW(obj,PW) % NKT set power
    disp(['Setting',num2str(PW)])
    [exec_state,output]=system(['NKTcom\NKTcom.exe -p',num2str(PW)]);
    if exec_state==0
        disp(['Power set to ',num2str(PW),' %'])
        p=str2num(output(17:end));
    else
        p=[];
        error(output)
    end
end