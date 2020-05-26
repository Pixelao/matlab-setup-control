% GPIBManager - a class to manage GPIB lab equipment
% ---------------------------------------------------------
% Jakko de Jong - 21 november 2016
% Copyright (C) 2016 Jakko de Jong <jakkodejong (at) gmail (dot) com>
%
%
% Description
% -----------
% Matlab class to check a gpib interface for all connected devices and
% read voltages from connected keithley multimeters and lockin amplifiers. 
% 
% This scripts was written primarily to check the availability of Keithley
% 2000 (2010) multimeters and Stanford Research Systems (SRS) lockin amplifiers, 
% but can easily be expanded to control more laboratory equipment. 
% 
% The class provides a level of usability by checking user input for
% compatibility with the equipment and returning informative warnings and
% error messages. The class is a singleton, preventing the user from
% accidentally instantiating multiple objects that control the same gpib 
% interface.
%
% Currently, GPIBManager only checks for gpib instruments on secondary
% address '0'. To check at another secondary address, modify the FindAll
% function by changing the secondary address in the 'address' string.
%
% N.B.: Every time new equipment is (dis)connected, the UpdateConnections
% function should be run.
%
%
% Functions
% ---------
% getInstance - instantiate the GPIBManager object
% FindAll - check and store connected equipment on a gpib interface.
% InitKeithley - initialize keithley settings.
% InitLockin - initialize lockin settings.
% Open - open a visa-gpib connection with instruments.
% CloseAll - close all gpib connections to all connected instruments.
% ReadKeitleys - return a vector with the value of all connected keithleys.
% ReadLockins - Return two vectors with the x/r and y/theta values of all connected lockins.
% GetKeithleyNums - return a list with the gpib numbers of all connected keithleys.
% GetLockinNums - return a list with the gpib numbers of all connected lockins.
% GetEquipmentList - Return a list with equipment names.
% UpdateConnections - Recheck all gpib ports and store connected instruments
%
% A detailed description of all the class' functionality is provided by
% GPIBManager_matlab_class.pdf