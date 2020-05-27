function r = MS257_SetWL (obj,WL) % MS257 set Wavelenght
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

function r = MS257_ReadWL(obj) % MS257 read Wavelenght
    %TODO
end