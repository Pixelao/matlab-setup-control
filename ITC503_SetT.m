function Setpoint= ITC503_SetT(obj,SetT)
        fprintf(obj,['T' num2str(SetT)]); %set temperature
        pause(2)
        Setpoint=query(obj,'R0') % read setpoint
end
        