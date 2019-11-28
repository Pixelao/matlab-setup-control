instrument = 'GPIB0::18::0::INSTR'; % GPIB-VISA resource name
integration_time=10; % integration time in number of power cylces
n=1000; % number of measurements
keithley=gpib_open(instrument);
init_keithley(integration_time,keithley);
data=[];
t=[];
% Make a function of this
for i=1:n
tic;
% Communicating with instrument object, obj1.
data1=keithley_measure_single(keithley);
data(i)=str2double(data1);
t(i)=toc;
end
gpib_close(keithley);
% Calculate average time per measurement
tgem=sum(t)/i;
disp('Average time per measurement in seconds: ')
disp(tgem);

% Add times of each measurement
plot(t,data);t=cumsum(t);

xlabel('Time')
ylabel('Voltage')
hold on 