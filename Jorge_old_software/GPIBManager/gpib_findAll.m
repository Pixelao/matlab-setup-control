function [handle_array,idn_cell] = gpib_findAll()
    
    handle_array = [];
    idn_cell = {};
    
    for i = 0:30
        address = ['GPIB0::' num2str(i) '::0::INSTR'];
        try 
            handle = gpib_open(address);
            idn = query(handle, '*IDN?');
            if ~isempty(strfind(idn,'SR830')) || ~isempty(strfind(idn,'KEITHLEY'))
                handle_array = [handle_array handle];
                idn_cell{length(idn_cell)+1} = idn;
                disp(['Succesfully connected to GPIB: ' handle.Name '; Name: ' idn])
            else
                fclose(handle);
            end
        catch
            %disp(['Could not connect with GPIB ' num2str(i) '.'])
        end
    end
end