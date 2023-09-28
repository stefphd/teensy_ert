
include $(START_DIR)/slprj/teensy_prefs.mk

LOCAL_GCC_TOOLS_PATH = $(TOOL_ROOT)/arm/bin

LOCAL_OPT       = -g -O2 -Wall -ffunction-sections -fdata-sections $(DIALOG_OPTIONS)

OPTIONS = -DF_CPU=$(F_CPU) -DLAYOUT_US_ENGLISH -DUSING_MAKEFILE
OPTIONS += -D__$(MCU)__ -DARDUINO=10813 -DTEENSYDUINO=159 -D$(MCU_DEF)

# External mode uses dual serial
ifeq ($(EXT_MODE),1)
OPTIONS += -DUSB_DUAL_SERIAL
else
OPTIONS += -DUSB_SERIAL
endif

LOCAL_CDEFS     = $(OPTIONS) -D__true_false_are_keywords -Dtrue=0x1 -Dfalse=0x0 -DEXIT_FAILURE=1
LOCAL_CXXDEFS   = $(OPTIONS) -D__true_false_are_keywords -Dtrue=0x1 -Dfalse=0x0
LOCAL_CSTANDARD = -std=gnu++17
LOCAL_CWARN     = -Wall -fno-exceptions -Wno-error=narrowing
LOCAL_MCU_OPT   = -mcpu=$(CPUARCH) $(CPUFLAGS)
CDEBUG          = 

# Compiler command and options
CC                  = $(LOCAL_GCC_TOOLS_PATH)/arm-none-eabi-gcc
CFLAGS              = $(LOCAL_MCU_OPT) -I. $(LOCAL_CDEFS)
CFLAGS             += $(LOCAL_OPT) $(LOCAL_CWARN)

# Specify the output extension from compiler
CCOUTPUTFLAG        = -o
OBJ_EXT             = .o

CXX                 = $(LOCAL_GCC_TOOLS_PATH)/arm-none-eabi-g++
CXXFLAGS            = $(LOCAL_MCU_OPT) -MMD -I. $(LOCAL_CXXDEFS) $(LOCAL_OPT) $(LOCAL_CSTANDARD)

# Linker command and options
LD                  = $(LOCAL_GCC_TOOLS_PATH)/arm-none-eabi-gcc
LDFLAGS             = $(LOCAL_MCU_OPT) $(LOCAL_CDEFS) $(LOCAL_OPT) $(LOCAL_CWARN) $(LOCAL_CSTANDARD) \
                      -Os -Wl,--gc-sections,--relax,-Map,mapFile.map,--cref,--defsym=__rtc_localtime=0 -T$(CORE_ROOT)/$(CORE)/$(MCU_LD) \
                      -felide-constructors -fpermissive -fno-rtti
LDFLAGS            += $(CPULDFLAGS)

# Specify extension from linker
LDOUTPUTFLAG        = -o
PROGRAM_FILE_EXT    = .elf

# Archiver command and options
AR                  = $(LOCAL_GCC_TOOLS_PATH)/arm-none-eabi-gcc-ar
ARFLAGS             = rcs

# Binary file format converter command and options
OBJCOPY             = $(LOCAL_GCC_TOOLS_PATH)/arm-none-eabi-objcopy
OBJCOPYFLAGS        = -O ihex -R .eeprom
BINARY_FILE_EXT     = .hex

# Binary size
SIZE                = $(TOOL_ROOT)/teensy_size

# Disassembler
OBJDUMP             = $(LOCAL_GCC_TOOLS_PATH)/arm-none-eabi-objdump
OBJDUMPFLAGS        = -d -S

# Specify extension for final product at end of build
EXE_FILE_EXT = $(BINARY_FILE_EXT)

TEENSY_INC_LIBS    = -I$(CORE_ROOT)/../libraries/Wire \
                     -I$(CORE_ROOT)/../libraries/Wire/utility \
                     -I$(CORE_ROOT)/../libraries/SPI \
                     -I$(CORE_ROOT)/../libraries/TeensyTimerTool/src

TARGET_INC_DIR       = -I$(CORE_ROOT)/$(CORE)

TARGET_INCS         = $(TARGET_INC_DIR) $(TEENSY_INC_LIBS)
TARGET_SRC_DIR      = $(CORE_ROOT)/$(CORE)
LOCAL_TEENSY_SRCS  = $(notdir $(wildcard $(TARGET_SRC_DIR)/*.cpp)) $(notdir $(wildcard $(TARGET_SRC_DIR)/*.c))
TARGET_SRCS         = $(filter-out main.cpp mk20dx128.c,$(LOCAL_TEENSY_SRCS))


ifeq ($(USERTOS),1)
TARGET_INC_DIR      += -I$(TEENSY_SL)/RTOS
TARGET_SRCS         +=  $(wildcard $(TEENSY_SL)/RTOS/*.c)
endif

# Here we add some Teensy library files from different folders
EXTRA_SRCS		=	

# Add low-level communication for ExtMode
ifeq ($(EXT_MODE),1)
EXTRA_SRCS		+= $(TEENSY_SL)/rtiostream_serial.cpp 
endif

TARGET_SRCS		+= $(notdir	$(EXTRA_SRCS))
VPATH			= $(sort $(dir $(EXTRA_SRCS)))

