#####################################
# Caution: do not rename this file. #
#####################################

# what is the path of the dir we are in?
GERONIMO_PLUGIN_MKFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
GERONIMO_PLUGIN_DIR    := $(shell dirname $(GERONIMO_PLUGIN_MKFILE))

GERONIMO_BASENAME_RAW         := $(firstword $(subst :, ,$(notdir $(GERONIMO_PLUGIN_DIR))))
GERONIMO_BASENAME_CLEAN_L1    := $(shell echo '$(GERONIMO_BASENAME_RAW)' | sed 's/-/_/g')
GERONIMO_BASENAME_CLEAN_L2    := $(shell echo '$(GERONIMO_BASENAME_CLEAN_L1)' | sed 's/[^a-zA-Z0-9_]/_/g')
GERONIMO_BASENAME             := $(shell echo '$(GERONIMO_BASENAME_CLEAN_L2)' | sed 's/\(\<.\)\.*/\u\1/g')
GERONIMO_BASENAME_AND_METHOD  := $(GERONIMO_BASENAME)-$(METHOD)
GERONIMO_LIB_NAME             := lib$(GERONIMO_BASENAME_AND_METHOD)

# provide a constant named MOOSEAPPNAME holding the users MooseApp name
ADDITIONAL_CPPFLAGS += -DMOOSEAPPNAME='"$(APPLICATION_NAME)App"'

# source files
GERONIMO_PLUGIN_SRC          := $(GERONIMO_PLUGIN_DIR)/src
GERONIMO_PLUGIN_INCLUDE      := $(GERONIMO_PLUGIN_DIR)/include
GERONIMO_PLUGIN_SRCFILES     := $(shell find $(GERONIMO_PLUGIN_SRC) -name "*.C")

GERONIMO_PLUGIN_INCLUDE_DIRS := $(foreach i, $(shell find $(GERONIMO_PLUGIN_INCLUDE) -type d), -I $(i))
GERONIMO_PLUGIN_SRC_DIRS     := $(foreach i, $(shell find $(GERONIMO_PLUGIN_SRC) -type d), -I $(i))

# object files
GERONIMO_PLUGIN_OBJECTS      := $(patsubst %.C, %.$(obj-suffix), $(GERONIMO_PLUGIN_SRCFILES))

# file name (including path) to the library for this plugin
GERONIMO_PLUGIN_LIB          := $(GERONIMO_PLUGIN_DIR)/$(firstword $(subst :, ,$(GERONIMO_LIB_NAME))).la

# dependencies (C, C++ files only)
GERONIMO_PLUGIN_DEPS := $(patsubst %.C, %.$(obj-suffix).d, $(GERONIMO_PLUGIN_SRCFILES))

# clang static analyzer files
GERONIMO_PLUGIN_ANALYZER := $(patsubst %.C, %.plist.$(obj-suffix), $(GERONIMO_PLUGIN_SRCFILES))

# register to ADDITIONAL_XZY (to enforce immediate expansion, "A := A B" is used)
ADDITIONAL_INCLUDES    := $(ADDITIONAL_INCLUDES) -I$(GERONIMO_PLUGIN_SRC) $(GERONIMO_PLUGIN_SRC_DIRS) $(GERONIMO_PLUGIN_INCLUDE_DIRS)
ADDITIONAL_LIBS        := $(ADDITIONAL_LIBS) -L$(GERONIMO_PLUGIN_DIR) -l$(GERONIMO_BASENAME_AND_METHOD)
ADDITIONAL_DEPEND_LIBS := $(ADDITIONAL_DEPEND_LIBS) $(GERONIMO_PLUGIN_LIB)
ADDITIONAL_CPPFLAGS    := $(ADDITIONAL_CPPFLAGS) $(GERONIMO_PLUGIN_INCLUDE_DIRS)

# Include dependencies (see note above)
-include $(GERONIMO_PLUGIN_DEPS)

# $(GERONIMO_PLUGIN_SRC)/%.$(obj-suffix): %.C
# 	@echo "Compiling C++ (codeplugin) "$@"..."
# 	$(CXX) $(CPPFLAGS) $(GERONIMO_PLUGIN_INCLUDE_DIRS) $(CXXFLAGS) -c $< -o $@

include $(GERONIMO_PLUGIN_OBJECTS)

$(GERONIMO_PLUGIN_LIB) : $(GERONIMO_PLUGIN_OBJECTS)
	@echo "Linking Library ($(GERONIMO_LIB_NAME)) "$@"..."
	@$(libmesh_LIBTOOL) --tag=CXX $(LIBTOOLFLAGS) --mode=link --quiet \
		$(libmesh_CXX) $(libmesh_CXXSHAREDFLAG) -o $@ $(GERONIMO_PLUGIN_OBJECTS) $(libmesh_LDFLAGS) $(EXTERNAL_FLAGS) -rpath $(GERONIMO_PLUGIN_DIR)
	@$(libmesh_LIBTOOL) --mode=install --quiet install -c $(GERONIMO_PLUGIN_LIB) $(GERONIMO_PLUGIN_DIR)

include $(GERONIMO_PLUGIN_LIB)
