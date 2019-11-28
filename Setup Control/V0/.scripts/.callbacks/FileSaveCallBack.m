function [] = FileSaveCallBack(varargin)
h=gcf;
[filename, pathname] = uiputfile('*.fig', 'Save the file as');
    if isnumeric(filename)
       disp('User pushed cancel. Not saving anything')
    else
       savefig(h,fullfile(pathname, filename))
    end
end