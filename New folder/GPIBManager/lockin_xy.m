function [ x,y ] = lockin_xy( instrument )
    % Measures X and Y of lockin
    handle = query(instrument, 'SNAP?1,2');
    %Convert output string to 2x1 double array
    handle = str2num(num2cell2mat(strsplit(handle(:))));
    x=handle(1);
    y=handle(2);
end

