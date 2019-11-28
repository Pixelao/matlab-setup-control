function [ r,theta ] = lockin_rt( instrument )
    % Measures R and Theta of lockin
    value = query(instrument, 'SNAP?3,4');
    % Convert string to double 2x1 array
    value = str2num(num2cell2mat(strsplit(value(:))));
    r=value(1);
    theta=value(2);
end

