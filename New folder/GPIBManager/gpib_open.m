% Function that initializes a VISA-GPIB device, resets it and sets the
% integration time of a digital multimeter. instrument is the device
% identifier, int_t is the integration time in number of AC power cycles
function handle = gpib_open(instrument)

    
    % Find a VISA-GPIB object.
    handle = instrfind('Type', 'visa-gpib', 'RsrcName', instrument, 'Tag', '');

    % Create the VISA-GPIB object if it does not exist
    % otherwise use the object that was found. Redundant?
    if isempty(handle)
        handle = visa('NI', instrument);
    else
        fclose(handle);
        handle = handle(1);
    end
    fopen(handle);
    disp('GPIB-VISA connection established.')
end