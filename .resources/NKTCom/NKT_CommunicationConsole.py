import sys
from classes.NKTP_DLL import *

program_name = sys.argv[0]
arguments = sys.argv[1:]
count = len(arguments)
ming = 0
maxg = 100

if count > 0:
    if sys.argv[1] == "--power" or sys.argv[1] == "-p" and count >= 2:
        if int(ming) <= int(sys.argv[2]) <= int(maxg):
            power = sys.argv[2]
            powerset = registerWriteU8('COM4', 1, 0x3E, int(power), -1)
            print('Setting Power:', RegisterResultTypes(powerset))
        else:
            print("The power % must be between the values "+str(ming)+" and "+str(maxg))
    
    elif sys.argv[1] == "--help" or sys.argv[1] == "-h":
        print("----------------------- NKT COMPACT V1.0 -------------------------")
        print("Program created by, Adrián Martín Ramos, contacto@adrianmr.com.")
        print("------------------------------------------------------------------")
        print("POWER: NKTcom.exe --power or -p Power")
        print("       Power = ("+str(ming)+" to "+str(maxg)+") %")
        print("")
        print("EMISSION ON: NKTcom.exe --poweron or -on ")
        print("")
        print("EMISSION OFF: NKTcom.exe --poweroff or -off ")
    
    elif sys.argv[1] == "--poweron" or sys.argv[1] == "-on":
        poweron = registerWriteU8('COM4', 1, 0x30, 0x01, -1)
        print('Setting lasser emission ON: ', RegisterResultTypes(poweron)) 
        
    elif sys.argv[1] == "--poweroff" or sys.argv[1] == "-off":
        poweroff = registerWriteU8('COM4', 1, 0x30, 0x00, -1)
        print('Setting lasser emission OFF: ', RegisterResultTypes(poweroff))

    else:
        print("The argument is incorrect, please send a correct argument. (Check --help or -h)")

else:
    print("Please send a correct argument. (Check --help or -h)")