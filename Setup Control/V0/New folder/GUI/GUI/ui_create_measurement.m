%% The UI that sets all the measurement parameters.

function varargout = ui_create_measurement(varargin)
% UI_CREATE_MEASUREMENT MATLAB code for ui_create_measurement.fig
%      UI_CREATE_MEASUREMENT, by itself, creates a new UI_CREATE_MEASUREMENT or raises the existing
%      singleton*.
%
%      H = UI_CREATE_MEASUREMENT returns the handle to a new UI_CREATE_MEASUREMENT or the handle to
%      the existing singleton*.
%
%      UI_CREATE_MEASUREMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function namedguide CALLBACK in UI_CREATE_MEASUREMENT.M with the given input arguments.
%
%      UI_CREATE_MEASUREMENT('Property','Value',...) creates a new UI_CREATE_MEASUREMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ui_create_measurement_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ui_create_measurement_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% edit_dev the above text to modify the response to help ui_create_measurement

% Last Modified by GUIDE v2.5 06-Jul-2018 11:24:35

% Begin initialization code - DO NOT EDIT_DEV
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui_create_measurement_OpeningFcn, ...
                   'gui_OutputFcn',  @ui_create_measurement_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT_DEV


% --- Executes just before ui_create_measurement is made visible.
function ui_create_measurement_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ui_create_measurement (see VARARGIN)

% Choose default command line output for ui_create_measurement
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ui_create_measurement wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ui_create_measurement_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
h = findobj('Tag','avail_dev');
set(h,'String',measurement_device.ts);


% --- Executes on selection change in avail_dev.
function avail_dev_Callback(hObject, eventdata, handles)
%% This function lists the device numbers in dev_no, when a type is selected from avail_dev. Solstis and shutters are fixed, while GPIB devices are retrieved live
    global GPIB
    idx  = get(hObject,'Value'); % The value selected in the "avail_dev" dropdown
    strings  = get(hObject,'String'); % The strings in the "avail_dev" dropdown
    name = strings{idx}; % The string of the current selected 
    devno=findobj('Tag','dev_no'); % 
    box = findobj('Tag','custom_array_check');
    custom_array = findobj('Tag','custom_array');

    % Find out which kind of device we have
    % TODO: Get the device types from the measurement_device class
    if strcmp(name,'shutter')
        t={'Shutter 1','Shutter 2'};
        set(devno,'String',t);
    elseif strcmp(name,'solstis')
        t={'Solstis 1','Solstis 2'};
        set(devno,'String',t);
    elseif strcmp(name,'pause')
        t={'Delay (s)'};
        set(devno,'String',t);
        set(devno,'String',t);
        set(handles.array_panel,'Visible','On'); 
        set(box,'Value',0);
        set(custom_array,'String','1');
        box = findobj('Tag','custom_array_check');
        set(box,'Value',1);
    else
        t=eval(['GPIB.equipment.' name '.name']);
        set(devno,'String',t);
    end
    
    % Select the minimum and maximum values in the GUI for this measurement device
    h2 = findobj('Tag','ar_min');
    h4 = findobj('Tag','ar_max');

    
    h3 = findobj('Tag','avail_dev');
    val = get(h3,'value');
    
    % Fetch suggested measurement start/stop parameters for the device
    ar_min=min(eval(measurement_device.def_val{val}));
    ar_max=max(eval(measurement_device.def_val{val}));

    set(h2,'String',ar_min);
    set(h4,'String',ar_max);


% --- Executes during object creation, after setting all properties.
function avail_dev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to avail_dev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dev_no.
function dev_no_Callback(hObject, eventdata, handles)
% hObject    handle to dev_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dev_no contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dev_no


% --- Executes during object creation, after setting all properties.
function dev_no_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dev_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function custom_array_Callback(hObject, eventdata, handles)
% hObject    handle to custom_array (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of custom_array as text
%        str2double(get(hObject,'String')) returns contents of custom_array as a double


% --- Executes during object creation, after setting all properties.
function custom_array_CreateFcn(hObject, eventdata, handles)
% hObject    handle to custom_array (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in custom_array_check.
function custom_array_check_Callback(hObject, eventdata, handles)
% hObject    handle to custom_array_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of custom_array_check



function ar_min_Callback(hObject, eventdata, handles)
% hObject    handle to ar_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_min as text
%        str2double(get(hObject,'String')) returns contents of ar_min as a double


% --- Executes during object creation, after setting all properties.
function ar_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ar_max_Callback(hObject, eventdata, handles)
% hObject    handle to ar_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_max as text
%        str2double(get(hObject,'String')) returns contents of ar_max as a double


% --- Executes during object creation, after setting all properties.
function ar_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ar_step_Callback(hObject, eventdata, handles)
% hObject    handle to ar_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_step as text
%        str2double(get(hObject,'String')) returns contents of ar_step as a double


% --- Executes during object creation, after setting all properties.
function ar_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% This function adds a measurement step to the measurement array.
function add_ms_Callback(hObject, eventdata, handles)

% Load the measurement array into this function
global measurement

% Load custom_array check value
custom_array_check=findobj('Tag','custom_array_check'); % 

% Load the minium and maximum array values (ignored if custom_array
% checked)
ar_min=findobj('Tag','ar_min');
ar_max=findobj('Tag','ar_max');
step=findobj('Tag','ar_step');

% Load custom array
custom_array=findobj('Tag','custom_array');

% Check if a custom array should be used from the checkmark in th GUI
if get(custom_array_check,'Value')==1
            input_array=eval(get(custom_array,'String'));
        else
            input_array=[str2num(get(ar_min,'String')):str2num(get(step,'String')):str2num(get(ar_max,'String'))];
end
clear t
t=measurement_device;
id=findobj('Tag','name');
type=findobj('Tag','avail_dev');
t.id=get(id,'String');
t.GPIB='yes';

ncycli=findobj('Tag','ncycli');
t.ntimes=str2double(get(ncycli,'string'));

num=findobj('Tag','dev_no');
t.num=get(num,'value');
quantity=findobj('Tag','quantity');
t.quantity=get(quantity,'String');

mode_set = findobj('Tag','ms_set');
mode_str = get(mode_set,'String');
mode=get(mode_set,'Value');
mr=cell2mat(mode_str(mode));
disp(mr)
t.mode=mr;
types=get(type,'String');
typed=get(type,'value');
t.type=cell2mat(types(typed));

arraySize = getArraySize();
if ~(arraySize == length(input_array) || strcmp(t.type,'pause')||arraySize <= 1)
    f = warndlg('Measurement array sizes are not equal for all measurement devices.','Warning');
end
t.input_array=input_array;
disp(t)
measurement{length(measurement)+1,1}=t;


% --- Executes on button press in update_ms.
updatePlotables();
updateMS();


%% This function updates a measurement step in the measurement array
function update_ms_Callback(hObject, eventdata, handles)
global measurement edited
% hObject    handle to add_ms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get custom array check
custom_array_check=findobj('Tag','custom_array_check');

% Get the min and max values for the measurement device
ar_min=findobj('Tag','ar_min');
ar_max=findobj('Tag','ar_max');
step=findobj('Tag','ar_step');

% And the custom array
custom_array=findobj('Tag','custom_array');

% Check if the custom array is checked
if get(custom_array_check,'Value')==1
            input_array=eval(get(custom_array,'String'));
        else
            input_array=[str2num(get(ar_min,'String')):str2num(get(step,'String')):str2num(get(ar_max,'String'))];
end

% Clear any previous temporary measurement devices
clear t

% Set t as class measurement_device
t=measurement_device;
id=findobj('Tag','name'); % get the name
type=findobj('Tag','avail_dev'); % get  the type
t.id=get(id,'String'); % the id of which the device was previously stored
t.GPIB='yes';

ncycli=findobj('Tag','ncycli'); % Number of measurement cycles
t.ntimes=str2double(get(ncycli,'string'));

% Replace the values in the measurement array with the new ones
num=findobj('Tag','dev_no');
t.num=get(num,'value');
quantity=findobj('Tag','quantity');
t.quantity=get(quantity,'String');

mode_set = findobj('Tag','ms_set');
mode_str = get(mode_set,'String');
mode=get(mode_set,'Value');
mr=cell2mat(mode_str(mode));

t.mode=mr;
types=get(type,'String');
typed=get(type,'value');
t.type=cell2mat(types(typed));

t.input_array=input_array;

% Input the temporary measurement device in the measurement array
measurement{edited,1}=t;


% Update the plotable units as well was the measurement list
updatePlotables();
updateMS();

% --- Executes on selection change in itemsx.
function itemsx_Callback(hObject, eventdata, handles)
% hObject    handle to itemsx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns itemsx contents as cell array
%        contents{get(hObject,'Value')} returns selected item from itemsx


% --- Executes during object creation, after setting all properties.
function itemsx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itemsx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
updatePlotables();




% --- Executes on selection change in itemsy.
function itemsy_Callback(hObject, eventdata, handles)
% hObject    handle to itemsy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns itemsy contents as cell array
%        contents{get(hObject,'Value')} returns selected item from itemsy


% --- Executes during object creation, after setting all properties.
function itemsy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to itemsy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% This function adds a plot to the plots cell array
function addplot_Callback(hObject, eventdata, handles)
% hObject    handle to addplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plots n plotids
x=findobj('Tag','itemsx');
y=findobj('Tag','itemsy');
xv=get(x,'String');
yv=get(y,'String');
xn=get(x,'Value');
yn=get(y,'Value');
xv=xv(xn);
yv=yv(yn);
[n,~]=size(plots);
n=n+1;
plots{n,1}=xv;
plots{n,2}=yv;
plots{n,3}=get(x,'Value');
plots{n,4}=get(y,'Value');
xv=cell2mat(xv);
yv=cell2mat(yv);

updatePlots();



% --- Executes on button press in removeplot.
function removeplot_Callback(hObject, eventdata, handles)
% hObject    handle to removeplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plots
handl=findobj('Tag','plotlist');
val=get(handl,'value');


plots(val,:)=[];


clear pls
[m,~]=size(plots);
pls={};
for n=1:m
    pls{n} = cell2mat([plots{n,1} ' VS ' plots{n,2}]);
end
set(handl,'String',pls,'Value',1)

% --- Executes on selection change in plotlist.
function plotlist_Callback(hObject, eventdata, handles)
% hObject    handle to plotlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns plotlist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotlist


% --- Executes during object creation, after setting all properties.
function plotlist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotlist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
updatePlots();


% --- Executes on selection change in cyclus.
function cyclus_Callback(hObject, eventdata, handles)
% hObject    handle to cyclus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cyclus contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cyclus



% --- Executes during object creation, after setting all properties.
function cyclus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyclus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
list = findobj('Tag','cyclus');

clear ids
global measurement
[m,~]=size(measurement);
ids={};
for n=1:m
    ids{n} = measurement{n,1}.id;
end

set(list,'String',ids,'Value',1)

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plots measurement
[file,path] = uiputfile('*.mat','Workspace File');
save([path file],'plots','measurement')
disp('Saved')

% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plots measurement
[file,path] = uigetfile;
load([path file])
disp('Loaded')


function quantity_Callback(hObject, eventdata, handles)
% hObject    handle to quantity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of quantity as text
%        str2double(get(hObject,'String')) returns contents of quantity as a double

% --- Executes during object creation, after setting all properties.
function quantity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to quantity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ncycli_Callback(hObject, eventdata, handles)
% hObject    handle to ncycli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with hand    les and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ncycli as text
%        str2double(get(hObject,'String')) returns contents of ncycli as a double


% --- Executes during object creation, after setting all properties.
function ncycli_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ncycli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    



function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name as text
%        str2double(get(hObject,'String')) returns contents of name as a double


% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit_dev controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in edit_dev.
function edit_dev_Callback(hObject, eventdata, handles)
% hObject    handle to edit_dev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global measurement edited
list = findobj('Tag','cyclus');
the_id=get(list,'Value');

clear t
t=measurement{the_id};

name=findobj('Tag','name');
num=findobj('Tag','dev_no');
quantity=findobj('Tag','quantity');
mode=findobj('Tag','mode');
custom_array=findobj('Tag','custom_array');


set(name,'String',t.id);
set(quantity,'String',t.quantity);
set(mode,'String',t.mode);
set(custom_array,'String',t.input_array);
edited = the_id;

% --- Executes on selection change in ms_set.
function ms_set_Callback(hObject, eventdata, handles)
% hObject    handle to ms_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ms_set contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ms_set

contents = cellstr(get(hObject,'String'));
val=contents{get(hObject,'Value')};
box = findobj('Tag','custom_array_check');

 custom_array = findobj('Tag','custom_array');
if strcmp(val,'read')
 set(handles.array_panel,'Visible','Off');
 
 set(box,'Value',1);
 set(custom_array,'String','0:1');
elseif strcmp(val,'source')
 set(handles.array_panel,'Visible','On'); 
 set(box,'Value',0);
 set(custom_array,'String','1:10');

end

% --- Executes during object creation, after setting all properties.
function ms_set_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ms_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset_btn.
function reset_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reset_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global measurement plots
measurement=[];
plots=[];
updatePlots();
updateMS();
updatePlotables();

% --- Executes on button press in clear_plots.
function clear_plots_Callback(hObject, eventdata, handles)
% hObject    handle to clear_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global plots n plotids
plots=[];
n=[];
plotids=[];
plotlist = findobj('Tag','plotlist');
set(plotlist,'String',plots,'Value',1)
disp('Done.')


% --- Executes on button press in delstep.
function delstep_Callback(hObject, eventdata, handles)
% hObject    handle to delstep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global measurement
handl=findobj('Tag','cyclus');
val=get(handl,'value');



measurement(val)=[];

list = findobj('Tag','cyclus');

clear ids
global measurement
[m,r]=size(measurement);
ids={};

if ~r==0
    for n=1:m
        ids{n} = measurement{n,1}.id;
    end
end

set(list,'String',ids,'Value',1)
updateMS();
updatePlotables();

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to custom_array (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of custom_array as text
%        str2double(get(hObject,'String')) returns contents of custom_array as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to custom_array (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in custom_array_check.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to custom_array_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of custom_array_check



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to ar_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_min as text
%        str2double(get(hObject,'String')) returns contents of ar_min as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to ar_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_max as text
%        str2double(get(hObject,'String')) returns contents of ar_max as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to ar_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ar_step as text
%        str2double(get(hObject,'String')) returns contents of ar_step as a double


% --- Executes during object creation, after setting all properties.

function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ar_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function updatePlotables()
    global measurement
    x=findobj('Tag','itemsx');
    y=findobj('Tag','itemsy');
    x_str={'Time'};
    for n=1:length(measurement)
        x_str{end+1}=measurement{n}.quantity;
    end
    set(x,'String',x_str);
    set(y,'String',x_str);

function updateMS()
    global measurement
    list = findobj('Tag','cyclus');

    clear ids
    ids={};
    [m,r]=size(measurement);
    if ~r==0
        for n=1:m
            ids{n} = measurement{n,1}.id;
        end
    end

    set(list,'String',ids,'Value',1)
function updatePlots()
    global plots
    handl=findobj('Tag','plotlist');




    clear pls
    [m,~]=size(plots);
    pls={};
    for n=1:m
        pls{n} = cell2mat([plots{n,1} ' VS ' plots{n,2}]);
    end
    set(handl,'String',pls,'Value',1)

% --- Executes on button press in timed.
function timed_Callback(hObject, eventdata, handles)
% hObject    handle to timed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global measurement_settings
timed = findobj('Tag','timed');
val=get(timed,'Value');
if val==true
    measurement_settings.timed='yes';
else
    measurement_settings.timed='no';
end

function array_max=getArraySize
    global measurement
% Find out which is the array and which isn't
    array_size = 0;
    for i=1:length(measurement)
        measurement_step  = measurement{i};
        array=measurement_step.input_array;
        array_size(i)=length(array);
    end
    array_max = max(array_size);    


% Hint: get(hObject,'Value') returns toggle state of timed


% --- Executes on button press in equalize.
function equalize_Callback(hObject, eventdata, handles)
% hObject    handle to equalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = questdlg('Are you sure you want to make the length of all measurements equal to the length of the longest measurement?','Are you sure?','Yes','No','Cancel','Yes');

switch answer
    case 'Yes'
        detect();
    case 'No'
        disp('Nothing changed');
end
