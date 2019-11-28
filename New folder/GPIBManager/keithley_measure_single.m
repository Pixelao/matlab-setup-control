% This function measures the voltage of the keithley  it reguires a
% variable with the GPIB-VISA device in it
function [value] = keithley_measure_single(handle)
    value = str2num(query(handle, ':SENS:DATA?'));
end