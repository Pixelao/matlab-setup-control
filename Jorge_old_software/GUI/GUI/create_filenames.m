function full_str = create_filenames(filename)
    % First, get the name of the main data folder.
   % if(isempty(varargin))
        mainFolder='Y:\staff\LowCost\fse\QDG\Data\Valleytronics_Feitze,Talieh,Jorge\Sample_L1\AutoSave';
   % else
       % mainFolder=varargin{1};
   % end
    dataFolder=datestr(now,'yyyy_mm_dd');

    % Create a name for a subfolder within that.
    newSubFolder = [mainFolder '\' dataFolder];

    % Create the folder if it doesn't exist already.
    if ~exist(newSubFolder, 'dir')
      mkdir(newSubFolder);
    end


    full_str = [newSubFolder '\' filename];
    n=1;
    while exist([full_str '.mat'], 'file') == 2
        full_str = [newSubFolder '\' filename num2str(n)];
        n=n+1;
    end

    if(~isempty(strfind(filename,'.')))
        full_str = [full_str '.mat'];
    end

end

