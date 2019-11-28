global GPIB SOL1 SOL2 OD WLM
clear GPIB SOL1 SOL2 OD WLM
GPIB = GPIBManager.getInstance();
%% Create Solstis manager object
SOL_IP='192.168.1.221';
SOL_IP2='192.168.1.222';
SOL_PORT=39933;
SOL1 = Solstis.getInstance(SOL_IP,SOL_PORT);
SOL1.OpenTCPIP();
SOL2 = Solstis.getInstance(SOL_IP2,SOL_PORT);
SOL2.OpenTCPIP();

%SOL.GoToWL(wl_sweep(1));
%% Create OPTODAC object
OD = Optodac.getInstance('COM5');
%OD = Optodac.getInstance('COM5');
OD.OpenSerial();
%% Create WLM object
WLM = WLM.getInstance();
