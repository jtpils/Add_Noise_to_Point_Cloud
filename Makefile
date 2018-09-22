#*****************************************************************************
#  Makefile.kvs
#*****************************************************************************

#=============================================================================
#  KVS_DIR.
#=============================================================================
ifndef KVS_DIR
$(error KVS_DIR is not defined.)
endif


#=============================================================================
#  SOURCES, OBJECTS, INCLUDE_PATH, LIBRARY_PATH, LINK_LIBRARY, INSTALL_DIR.
#=============================================================================
SOURCES :=
OBJECTS :=


INCLUDE_PATH :=-I/usr/local/include/pcl-1.8 -I/opt/local/include/eigen3 -I/opt/local/include
LIBRARY_PATH :=-L/opt/local/lib -L/usr/local/lib
#LINK_LIBRARY :=-lpcl_kdtree -lpcl_common -lpcl_search -lpcl_features -framework vecLib 
#LINK_LIBRARY :=-lpcl_kdtree -lpcl_common -lpcl_search -lpcl_features -framework Accelerate
LINK_LIBRARY :=-lpcl_kdtree -lpcl_common -lpcl_search -framework Accelerate

INSTALL_DIR  :=


#=============================================================================
#  Include.
#=============================================================================
include $(KVS_DIR)/kvs.conf

-include kvsmake.conf

include $(KVS_DIR)/Makefile.def


#=============================================================================
#  Project name.
#=============================================================================
PROJECT_NAME := addNoise

ifeq "$(findstring CYGWIN,$(shell uname -s))" "CYGWIN"
TARGET_EXE := $(PROJECT_NAME).exe
else
TARGET_EXE := $(PROJECT_NAME)
endif

TARGET_LIB := lib$(PROJECT_NAME).a

TARGET_DYLIB := lib$(PROJECT_NAME).so

TARGET_OCL := $(PROJECT_NAME).so


#=============================================================================
#  Source.
#=============================================================================
SOURCES += $(wildcard *.cpp)

ifeq "$(KVS_SUPPORT_CUDA)" "1"
CUDA_SOURCES := $(wildcard *.cu)
endif


#=============================================================================
#  Object.
#=============================================================================
OBJECTS += $(SOURCES:.cpp=.o)

ifeq "$(KVS_SUPPORT_CUDA)" "1"
CUDA_OBJECTS := $(CUDA_SOURCES:.cu=.o)

OBJECTS += $(CUDA_OBJECTS)
endif


#=============================================================================
#  Include path.
#=============================================================================
ifeq "$(KVS_SUPPORT_CUDA)" "1"
INCLUDE_PATH += $(CUDA_INCLUDE_PATH)
endif

ifeq "$(KVS_SUPPORT_GLUT)" "1"
INCLUDE_PATH += $(GLUT_INCLUDE_PATH)
endif

ifeq "$(KVS_SUPPORT_OPENCV)" "1"
INCLUDE_PATH += $(OPENCV_INCLUDE_PATH)
endif

INCLUDE_PATH += -I$(KVS_DIR)/include
INCLUDE_PATH += $(GLEW_INCLUDE_PATH)
INCLUDE_PATH += $(GL_INCLUDE_PATH)


#=============================================================================
#  Library path.
#=============================================================================
ifeq "$(KVS_SUPPORT_CUDA)" "1"
LIBRARY_PATH += $(CUDA_LIBRARY_PATH)
endif

ifeq "$(KVS_SUPPORT_GLUT)" "1"
LIBRARY_PATH += $(GLUT_LIBRARY_PATH)
endif

ifeq "$(KVS_SUPPORT_OPENCV)" "1"
LIBRARY_PATH += $(OPENCV_LIBRARY_PATH)
endif

LIBRARY_PATH += -L$(KVS_DIR)/lib
LIBRARY_PATH += $(GLEW_LIBRARY_PATH)
LIBRARY_PATH += $(GL_LIBRARY_PATH)


#=============================================================================
#  Link library.
#=============================================================================
ifeq "$(KVS_SUPPORT_CUDA)" "1"
LINK_LIBRARY += -lkvsSupportCUDA $(CUDA_LINK_LIBRARY)
endif

ifeq "$(KVS_SUPPORT_GLUT)" "1"
LINK_LIBRARY += -lkvsSupportGLUT $(GLUT_LINK_LIBRARY)
endif

ifeq "$(KVS_SUPPORT_OPENCV)" "1"
LINK_LIBRARY += -lkvsSupportOpenCV $(OPENCV_LINK_LIBRARY)
endif

LINK_LIBRARY += -lkvsCore
LINK_LIBRARY += $(GLEW_LINK_LIBRARY)
LINK_LIBRARY += $(GL_LINK_LIBRARY)


#=============================================================================
#  Build rule.
#=============================================================================
$(TARGET_EXE): $(OBJECTS)
	$(LD) $(LDFLAGS) $(LIBRARY_PATH) -o $@ $^ $(LINK_LIBRARY)

$(TARGET_LIB): $(OBJECTS)
	$(AR) $@ $^
	$(RANLIB) $@

$(TARGET_DYLIB): $(OBJECTS)
	$(LD) $(LDFLAGS) -shared -rdynamic $(LIBRARY_PATH) -o $@ $^ $(LINK_LIBRARY)

$(TARGET_OCL): $(OBJECTS)
	$(LD) $(LDFLAGS) -shared -rdynamic $(LIBRARY_PATH) -o $@ $^ $(LINK_LIBRARY) $(OPENCABIN_LINK_LIBRARY)

%.o: %.cpp %.h
	$(CPP) -c $(CPPFLAGS) $(DEFINITIONS) $(INCLUDE_PATH) -o $@ $<

%.o: %.cpp
	$(CPP) -c $(CPPFLAGS) $(DEFINITIONS) $(INCLUDE_PATH) -o $@ $<

ifeq "$(KVS_SUPPORT_CUDA)" "1"
%.o: %.cu %.cuh
	$(NVCC) -c $(NVCCFLAGS) $(DEFINITION) $(INCLUDE_PATH) -o $@ $<

%.o: %.cu
	$(NVCC) -c $(NVCCFLAGS) $(DEFINITION) $(INCLUDE_PATH) -o $@ $<
endif


#=============================================================================
#  build.
#=============================================================================
build: $(TARGET_EXE)


#=============================================================================
#  lib.
#=============================================================================
lib: $(TARGET_LIB)


#=============================================================================
#  dynamic lib.
#=============================================================================
dylib: $(TARGET_DYLIB)


#=============================================================================
#  dynamic lib for OpenCABIN.
#=============================================================================
ocl: $(TARGET_OCL)


#=============================================================================
#  clean.
#=============================================================================
clean:
	$(RM) $(TARGET_EXE) $(TARGET_LIB) $(OBJECTS)


#=============================================================================
#  distclean.
#=============================================================================
distclean: clean
	$(RM) Makefile.kvs


#=============================================================================
#  install.
#=============================================================================
ifneq "$(INSTALL_DIR)" ""
install:
	$(MKDIR) $(INSTALL_DIR)/include
	$(INSTALL) *.h $(INSTALL_DIR)/include
	$(MKDIR) $(INSTALL_DIR)/lib
	$(INSTALL) $(TARGET_LIB) $(INSTALL_DIR)/lib
	$(RANLIB) $(INSTALL_DIR)/lib/$(TARGET_LIB)
endif

