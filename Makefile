
PRJ=$(OO_SDK_HOME)
SETTINGS=$(PRJ)/settings

include $(SETTINGS)/settings.mk
include $(SETTINGS)/std.mk
include $(SETTINGS)/dk.mk

EXTENSION_VERSION=$(shell $(CAT) VERSION)
EXTENSION_STATE=
EXTENSION_ID=mytools.sheet.QuadraticEquationAddIn
EXTENSION_NAME=qd
EXTENSION_DISPLAY_NAME=Calculate solution of quadratic equation.
IMPLE_NAME=mytools.sheet.QuadraticEquationAddIn

ifeq "$(SDKVERSION)" "3.4"
ifneq "$(PLATFORM)" "windows"
EXTENSION_PLATFORM=$(PLATFORM)_x86
else
ifneq "$(PLATFORM)" "linux"
ifneq "$(PROCTYPE)" "i386"
EXTENSION_PLATFORM=$(PLATFORM)_x86
else
ifneq "$(PROCTYPE)" "x86_64"
EXTENSION_PLATFORM=$(PLATFORM)_x86_64
endif
endif
endif
endif
else
# since AOO4
include $(SETTINGS)/platform.mk
endif

COMP_NAME=qd
COMP_IMPL_NAME=$(COMP_NAME).uno.$(SHAREDLIB_EXT)

ifeq "$(OS)" "WIN"
ORIGIN_NAME=%%origin%%
CC_FLAGS+= /O2 
else
ORIGIN_NAME=%origin%
CC_FLAGS=-c -Os -fpic
COMP_LINK_FLAGS=$(LIBRARY_LINK_FLAGS) 
#ifeq "$(SDKVERSION)" "3.4"
CC_FLAGS+= -fvisibility=hidden
#else
#COMP_LINK_FLAGS+= -Wl,--version-script,$(SETTINGS)/component.uno.map 
#endif
endif

SRC=./src
OUT=.
BUILD_DIR=./build
GEN_DIR=./gen
IDL_LOC_DIR=./idl

OUT_COMP_INC=$(OUT_INC)/$(COMP_NAME)
OUT_COMP_GEN=$(OUT_MISC)/$(COMP_NAME)
OUT_COMP_SLO=$(OUT_SLO)/$(COMP_NAME)

CXXFILES = qd.cpp qd_service.cpp 
OBJFILES = $(patsubst %.cpp,$(OUT_SLO)/%.$(OBJ_EXT),$(CXXFILES))

SHEET_PATH=mytools/sheet
ADDIN_IDL_FILES = XQuadraticEquationAddIn.idl

ADDIN_IDL_FILES2 = $(patsubst %.idl,$(IDL_LOC_DIR)/$(SHEET_PATH)/%.idl,$(ADDIN_IDL_FILES))
ADDIN_URD_FILES = $(patsubst %.idl,$(OUT_MISC)/%.urd,$(ADDIN_IDL_FILES))
ADDINTYPE_NAMES = $(patsubst %.idl,-Tmytools.sheet.%,$(ADDIN_IDL_FILES))

ADDINRDB_FILE_NAME=qd.rdb

IDL_LOC_INC=./inc
CC_INCLUDES=-I. -I$(IDL_LOC_INC) -I../ww/inc -I$(OO_SDK_HOME)/include 

MANIFEST=$(BUILD_DIR)/META-INF/manifest.xml
DESCRIPTION=$(BUILD_DIR)/description.xml
COMP_DIR=$(BUILD_DIR)/libs
COMP_REGISTRATION=$(COMP_DIR)/registration.components

UNO_PKG_NAME=.$(PS)files$(PS)$(EXTENSION_NAME)-$(EXTENSION_VERSION)-$(subst _,-,$(EXTENSION_PLATFORM)).$(UNOOXT_EXT)

.PHONY: ALL
ALL : AddIn

AddIn : $(UNO_PKG_NAME)

include $(SETTINGS)/stdtarget.mk

PAKCAGE_CONTENTS=META-INF/* description.xml README LICENSE libs/* descriptions/* *.xcu *.rdb


$(UNO_PKG_NAME) : $(COMP_DIR)/$(COMP_IMPL_NAME) $(MANIFEST) $(COMP_REGISTRATION) 
	$(COPY) README $(subst /,$(PS),$(BUILD_DIR)/README)
	$(COPY) LICENSE $(subst /,$(PS),$(BUILD_DIR)/LICENSE)
	$(COPY) -r $(GEN_DIR)/* $(BUILD_DIR)
	cd $(BUILD_DIR) && $(SDK_ZIP) -9 -r -o ../$(UNO_PKG_NAME) $(PAKCAGE_CONTENTS)


$(OUT_SLO)/%.$(OBJ_EXT) : $(SRC)/%.cpp $(BUILD_DIR)/$(ADDINRDB_FILE_NAME) 
	-$(MKDIR) $(subst /,$(PS),$(@D))
	$(CC) $(CC_OUTPUT_SWITCH)$(subst /,$(PS),$@) $(CC_FLAGS) $< $(CC_INCLUDES) $(CC_DEFINES) $(VERSION_DEF) $(TASKPANE_DEF)
#$(SDKTYPEFLAG)

ifeq "$(OS)" "WIN"
LINK_OUT_FLAG=/OUT:
MATH_LIB=-lm
ADDITIONAL_LIBS=msvcrt.lib kernel32.lib
else
LINK_OUT_FLAG=-o 
MATH_LIB=
ADDITIONAL_LIBS=-Wl,--as-needed -ldl -lpthread -lm -Wl,--no-as-needed -Wl,-Bdynamic
endif

# ToDo
LINK_LIBS=-L $(OFFICE_BASE_PROGRAM_PATH) -L $(PRJ)$(PS)lib

$(COMP_DIR)/$(COMP_IMPL_NAME) : $(OBJFILES) 
	-$(MKDIR) $(subst /,$(PS),$(COMP_DIR))
	$(LINK) $(COMP_LINK_FLAGS) $(LINK_OUT_FLAG)$(COMP_DIR)/$(COMP_IMPL_NAME) $(OBJFILES) $(COJBFILES) $(LINK_LIBS) $(MATH_LIB) $(CPPUHELPERLIB) $(CPPULIB) $(SALLIB) $(STC++LIB) $(CPPUHELPERDYLIB) $(CPPUDYLIB) $(SALDYLIB) $(SALHELPERLIB) $(ADDITIONAL_LIBS)


#REGMERGE=$(OFFICE_BASE_PROGRAM_PATH)/regmerge
#OFFICE_TYPES=$(OFFICE_BASE_PROGRAM_PATH)/types.rdb

$(BUILD_DIR)/$(ADDINRDB_FILE_NAME) : $(ADDIN_IDL_FILES2)
	-$(MKDIR) $(subst /,$(PS),$(BUILD_DIR))
	$(IDLC) -I"$(OO_SDK_HOME)/idl" -I$(IDL_LOC_DIR) -O$(OUT_MISC) $(ADDIN_IDL_FILES2)
	$(REGMERGE) $(BUILD_DIR)/$(ADDINRDB_FILE_NAME) /UCR $(ADDIN_URD_FILES)
	$(CPPUMAKER) -BUCR -O$(IDL_LOC_INC) $(ADDINTYPE_NAMES) $(OFFICE_TYPES) $(URE_TYPES) $(BUILD_DIR)/$(ADDINRDB_FILE_NAME)
#	$(CPPUMAKER) -BUCR -O$(IDL_LOC_INC) $(ADDINTYPE_NAMES) $(OFFICE_TYPES) $(BUILD_DIR)/$(ADDINRDB_FILE_NAME)


$(MANIFEST) : 
	@-$(MKDIR) $(subst /,$(PS),$(@D))
	@echo $(OSEP)?xml version="$(QM)1.0$(QM)" encoding="$(QM)UTF-8$(QM)"?$(CSEP) > $@
	@echo $(OSEP)manifest:manifest$(CSEP) >> $@
	@echo $(OSEP)manifest:file-entry manifest:full-path="$(QM)$(ADDINRDB_FILE_NAME)$(QM)" >> $@
	@echo manifest:media-type="$(QM)application/vnd.sun.star.uno-typelibrary;type=RDB$(QM)"/$(CSEP) >> $@
	@echo $(OSEP)manifest:file-entry manifest:full-path="$(QM)libs/registration.components$(QM)"  >> $@
	@echo manifest:media-type="$(QM)application/vnd.sun.star.uno-components;platform=$(UNOPKG_PLATFORM)$(QM)"/$(CSEP)  >> $@
	@echo $(OSEP)manifest:file-entry manifest:full-path="$(QM)AddInInfo.xcu$(QM)" >> $@
	@echo manifest:media-type="$(QM)application/vnd.sun.star.configuration-data$(QM)"/$(CSEP) >> $@
	@echo $(OSEP)/manifest:manifest$(CSEP) >> $@

$(COMP_REGISTRATION) : 
	@echo $(OSEP)?xml version="$(QM)1.0$(QM)" encoding="$(QM)UTF-8$(QM)"?$(CSEP) >> $@
	@echo $(OSEP)components xmlns="$(QM)http://openoffice.org/2010/uno-components$(QM)"$(CSEP) >> $@
	@echo $(OSEP)component loader="$(QM)com.sun.star.loader.SharedLibrary$(QM)" uri="$(QM)$(COMP_IMPL_NAME)$(QM)"$(CSEP) >> $@
	@echo $(OSEP)implementation name="$(QM)$(IMPLE_NAME)$(QM)"$(CSEP) >> $@
	@echo $(OSEP)service name="$(QM)$(IMPLE_NAME)$(QM)"/$(CSEP) >> $@
	@echo $(OSEP)service name="$(QM)com.sun.star.sheet.AddIn$(QM)"/$(CSEP) >> $@
	@echo $(OSEP)/implementation$(CSEP) >> $@
	@echo $(OSEP)/component$(CSEP) >> $@
	@echo $(OSEP)/components$(CSEP) >> $@

clean : 
	@- $(DELRECURSIVE) $(subst \,$(PS),$(OUT_SLO))
	@- $(RM) $(UNO_PKG_NAME)
	@- $(DELRECURSIVE) $(BUILD_DIR)

