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

GERONIMO_PLUGIN_MKT           := $(GERONIMO_PLUGIN_DIR)/codeplugin.template.mk
GERONIMO_PLUGIN_MKX           := $(GERONIMO_PLUGIN_DIR)/codeplugin.local.mk

$(shell echo '$(AA_GERONIMO_BASENAME_RAW)' | sed 's/GERONIMO_/$(GERONIMO_BASENAME)_GERONIMO_/g' $(GERONIMO_PLUGIN_MKT) > $(GERONIMO_PLUGIN_MKX))

include $(GERONIMO_PLUGIN_MKX)
