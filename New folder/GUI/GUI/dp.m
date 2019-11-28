 function plotData=dp(hObject, eventdata, handles)
    global s
        plist = findobj('Tag','popuplist');
        val=get(plist,'value');
        
        r=get(s(val), 'visible');
        if strcmp(r,'off')
            st='on';
        else
            st='off';
        end
        set(s(val), 'visible',st);
        %axis off
        drawnow;
 end
