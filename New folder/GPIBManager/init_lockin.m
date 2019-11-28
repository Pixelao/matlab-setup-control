function init_lockin( handle )
%INIT_LOCKIN Summary of this function goes here
%   Detailed explanation goes here
% Set output of lockin to GPIB
    fprintf(handle, 'OUTX1');
    % Unlock front panel
    fprintf(handle, 'OVRM 1');
    
    disp('Lockin succesfully initialized.');
end

