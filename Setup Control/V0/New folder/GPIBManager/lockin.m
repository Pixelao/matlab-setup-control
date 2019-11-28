instrument = 'GPIB0::10::0::INSTR'; % GPIB-VISA resource name
lockin=gpib_open(instrument); % Open GPIB connection
init_lockin(lockin) % Send device specific commands
n=100; % Number of measurements
tic;
xy=[];

for i=1:n
s=str2num(lockin_xy(lockin)); % GPIB gives ASCII output, convert to numbers
xy=[xy; s];
end

% Present the data
t=toc;
disp(['Measuring ' num2str(n) ' times took ' num2str(t) ' seconds.']);
plot(xy);


gpib_close(lockin) % Close the connection