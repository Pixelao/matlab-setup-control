%measurement
%plots
global plotData s
fig = figure(7198); clf
grahp_panel = uipanel(...
'Parent',fig,...
'FontUnits','points',...
'Units','normalized',...
'Title','Measurement',...
'Position',[0.237424547283702 0.125983327462722 0.519785378940309 0.75860044616649],...
'ResizeFcn',blanks(0),...
'ButtonDownFcn',blanks(0),...
'Tag','uibuttongroup3');

ax = axes(...
'Parent',grahp_panel,...
'FontUnits',get(0,'defaultaxesFontUnits'),...
'Units',get(0,'defaultaxesUnits'),...
'PlotBoxAspectRatio',[1 0.857787810383747 0.857787810383747],...
'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
'Tag','axes',...
'Position',[0.237424547283702 0.125983327462722 0.519785378940309 0.75860044616649],...
'ActivePositionProperty','position',...
'LooseInset',[0.127975891511803 0.101043841336117 0.0935208437970869 0.0688935281837161],...
'SortMethod','childorder');
hold on

% Measurement loop
times=[];
data=[];
% Find out which is the array and which isn't
    for i=1:length(measurement)
        measurement_step  = measurement{i};
        array=measurement_step.input_array;
        array_size(i)=length(array);
    end
array_max = max(array_size);

for i=1:length(measurement)
        measurement_step  = measurement{i};
        array=measurement_step.input_array;
        array_size=length(array);
        if array_size==array_max
            main_id=measurement_step.id;
            disp('Main loop found.')
            break;
        end
end
clear i
xdata=NaN;
ydata=NaN;
[len_plot,~]=size(plots);
clear plotnox plotnoy
for n=1:len_plot
    
    disp(num2str(n))
    xnum=plots{n,3}-1;
    ynum=plots{n,4}-1;
    plotnox(1,n)=xnum;
    plotnoy(1,n)=ynum;
    if xnum==0
        xnum='Time';
    end
    if ynum==0
        ynum='Time';
    end
    if len_plot > 3
        np=2;
        nx=round(len_plot/2);
        disp('Subplotting')
    else
        np=1;
        nx=len_plot;
    end
    s(n)=subplot(nx,np,n);
    plotData(n) = plot(s(n), xdata, ydata, 'linewidth', 3);
    unitx='Time (s)';
    unity='Time (s)';
    title('Time')
    if ~strcmp(xnum,'Time')
        unitx=measurement{xnum}.quantity;
        title([measurement{xnum}.id ' - dev no: ' num2str(measurement{xnum}.num)])
    end
    if ~strcmp(ynum,'Time')
        unity=measurement{ynum}.quantity;
        title([measurement{ynum}.id ' - dev no: ' num2str(measurement{ynum}.num)])
    end
    plot_lst{n} = ([unitx ' VS ' unity]);
    xlabel(unitx, 'fontsize', 12)
    ylabel(unity, 'fontsize', 12)
end
  btn = uicontrol('Style', 'pushbutton', 'String', 'Toggle',...
        'Position', [20 20 50 20],...
        'Callback', @dp); 
    
   popup_plots = uicontrol('Style', 'popup',...
           'String', plot_lst,...
           'Tag','popuplist',...
           'Position', [20 340 100 50]);    

timerVal = tic;
for n=1:array_max
    for i=1:length(measurement)
        measurement_step  = measurement{i};
        func=measurement_step.type;
        mode=measurement_step.mode;
        for j=1:measurement_step.ntimes
            data_j(j)=eval(['measurement_step.' func '(' num2str(n) ')']);
        end
        pause(0.1)
        yd=mean(data_j);
        data(:,i)=yd;
        time=toc(timerVal);
        times_temp(:,i)=time;
        
        if ismember(i,plotnox)||ismember(i,plotnoy)
                    if ismember(i,plotnox(1,:))
                        id=find(plotnox(1,:)==i);
                        xdata=yd;
                        disp('X')
                    else
                        xdata=time;
                    end
                    if ismember(i,plotnoy(1,:))
                        id=find(plotnoy(1,:)==i);
                        ydata=yd;
                        disp(ydata)
                        disp('Y')
                    else
                        ydata=time;
                    end
            set(plotData(id), 'xdata', [get(plotData(id),'YData') yd], 'ydata', [get(plotData(id),'YData') ydata])
            drawnow
        else
            disp('No plot for this device.')
        end
    end
    results(n,:)=data;
    times(n,:)=times_temp;
   
    data=[];
    times_temp=[];

end


% Todo: savedate and plot