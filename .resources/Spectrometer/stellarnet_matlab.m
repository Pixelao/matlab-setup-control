% Use the command below with correct python exe path to load the python version first time only
%pyversion C:\Python27\python.exe
spectrometer = py.stellarnet_driver.array_get_spec(0);% calling spectrometer device id
%test
% setting parameters
inttime =  int64(100);
xtiming = int64(1);
scansavg = int64(1);
smoothing = int64(4);

param = py.stellarnet_driver.setparam(spectrometer,inttime,xtiming,scansavg,smoothing); % calling lib to set parameter
for n=1:1000
wav = py.stellarnet_driver.array_get_wav(spectrometer); %getting wavelengths
spectrum = py.stellarnet_driver.array_spectrum(spectrometer); % getting spectrum
data = double(py.array.array('d',py.numpy.nditer(spectrum))); %d is for double, coverting spectrum to matlab type
x = double(py.array.array('d',py.numpy.nditer(wav))); %d is for double, coverting wavelengths to matlab type
figure(75)
plot(x,data) % plotting data
xlabel('Wavelength in nm')
ylabel('Counts')
end
