classdef SPM < handle
    properties
        equipment
    end
    methods

        %Spectrometer Functions
        function maxWL=SPread(~)
            spectrometer = py.stellarnet_driver.array_get_spec(0);% calling spectrometer device id
            % setting parameters
            inttime =  int64(100);
            xtiming = int64(1);
            scansavg = int64(1);
            smoothing = int64(2);
            param = py.stellarnet_driver.setparam(spectrometer,inttime,xtiming,scansavg,smoothing); % calling lib to set parameter
            wav = py.stellarnet_driver.array_get_wav(spectrometer); %getting wavelengths
            spectrum = py.stellarnet_driver.array_spectrum(spectrometer); % getting spectrum
            data = double(py.array.array('d',py.numpy.nditer(spectrum))); %d is for double, coverting spectrum to matlab type
            x = double(py.array.array('d',py.numpy.nditer(wav))); %d is for double, coverting wavelengths to matlab type
            maxWL=x(data==max(data));
        end
    
    end
end