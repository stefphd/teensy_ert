# Teensy build preferences

# Teensy 4.1
CORE_ROOT = C:/Users/LabUser/DOCUME~1/GitHub/TEENSY~1/teensy/avr/cores
TOOL_ROOT = C:/Users/LabUser/DOCUME~1/GitHub/TEENSY~1/tools
TEENSY_SL = C:/Users/LabUser/Documents/GitHub/teensy_ert/teensy_ert
MCU_LD = imxrt1062_t41.ld
CORE = teensy4
F_CPU = 600000000
MCU_DEF = ARDUINO_TEENSY41
MCU = IMXRT1062
CPUARCH = cortex-m7
CPUFLAGS = -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb 
CPULDFLAGS = -lm -lstdc++ -larm_cortexM7lfsp_math
