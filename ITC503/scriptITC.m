obj=gpib('ni',0,13);
obj.EOSMode='read&write';obj.EOSCharCode='CR';
fopen(obj)
        query(obj,'C3');
        query(obj,['T' num2str(4.000)]); %set temperature
        pause(0.2)
        clrdevice(obj)
        Setpoint=str2double(extractAfter(query(obj,'R0'),1))
        fclose(obj)