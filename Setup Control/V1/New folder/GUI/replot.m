function replot(hObject, eventdata, handles)
    xdata=NaN;
    ydata=NaN;
    global plots s measurement plotData b_Pause
    set(b_Pause,'Value',1);
    [len_plot,~]=size(plots);

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
        clear plotData
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
    set(b_Pause,'Value',0);
end