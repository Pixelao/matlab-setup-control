function detect
% Get the measurement array
    global measurement
    % Find out which is the array and which isn't
    array_max = 0;
    % Find max array size
    for i=1:length(measurement)
        measurement_step  = measurement{i};
        array=measurement_step.input_array;
        array_size(i)=length(array);
    end
        array_max = max(array_size);
    % Replace the arrays for ones of the max size
    for i=1:length(measurement)
            measurement_step  = measurement{i};
            array=measurement_step.input_array;
            array_sizeCurrent=length(array);
            if array_max ~= array_sizeCurrent
                array_maxV = max(array);
                array_minV = min(array);
                stepsize = (array_maxV - array_minV + 2)/array_max;
                measurement_step.input_array=array_minV:stepsize:array_maxV;
            end
    end
    disp(array_size)
end

