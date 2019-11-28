function init_keithley(handle,int_t)
%INIT_KEITHLEY Summary of this function goes here
    % Check if the supplied integration time is in the range supported by the
    % Keithley 2000
    if int_t < 0.1 || int_t > 10
        error('Integration time out of range. The integration time should be between 0.1 and 10');
    end
    % Prepare the Keithley 2000 for measuring
    fprintf(handle, '*rst;status:preset;*cls');
    % Turn error beep off
    fprintf(handle, ':SYST:BEEP:STAT OFF');
    % Display off for lower measurement speeds
    fprintf(handle, ':DISPlay:ENABle 0');
    % Never go to idle between measurements
    fprintf(handle,':init:cont on');
    % Set the integration time in Number of Power Line Cycles (NPLC)
    fprintf(handle,[':SENSE:VOLT:DC:NPLC ' num2str(int_t)]);
    disp('Keithley succesfully initialized.')


end

