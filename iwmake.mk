##############################################################
#                                                            #
#  (c) 2018 Tripwire, Inc.                                   #
#                                                            #
#  PROPRIETARY AND CONFIDENTIAL INFORMATION                  #
#                                                            #
#  The information contained herein is the proprietary and   #
#  confidential property of Tripwire, Inc. and may not be    #
#  used, distributed, modified, disclosed or reproduced      #
#  without the express written permission of Tripwire, Inc.  #
#                                                            #
##############################################################

IWMAKE_MK_VERSION := 2

IWMAKE_MK_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
ifeq ($(IWMAKE_SETTINGS),)
    IWMAKE_SETTINGS := $(HOME)/.iwmake/iwsettings.mk
endif
-include $(IWMAKE_SETTINGS)
-include $(IWMAKE_MK_DIR)/iwsettings.mk

ifeq ($(IWMAKE_LOCAL_REPOSITORY),)
    ifeq ($(TEAMCITY_VERSION),)
        IWMAKE_LOCAL_REPOSITORY := $(HOME)/.iwmake/repository
    else
        IWMAKE_LOCAL_REPOSITORY := $(IWMAKE_MK_DIR)/.iwmake/repository
    endif
endif
ifeq ($(IWMAKE_ARTIFACTORY),)
    IWMAKE_ARTIFACTORY := https://artifactory.scm.tripwire.com/artifactory
endif
ifeq ($(IWMAKE_REPOSITORY),)
    IWMAKE_REPOSITORY := libs-tripwire-local
endif
ifeq ($(IWMAKE_GROUPID),)
    IWMAKE_GROUPID := com.tripwire.ironwood.ironwood.make
endif
ifeq ($(IWMAKE_NAME),)
    IWMAKE_NAME := ironwood-make
endif
IWMAKE_CONSTRAINT := $(IWMAKE_VERSION)

ifeq ($(IWMAKE_DIR),)
    iwmake_curl := curl --fail --silent --show-error --insecure
    ifneq ($(IWMAKE_USERNAME),)
        iwmake_curl += --user '$(IWMAKE_USERNAME):$(IWMAKE_PASSWORD)'
    endif
    ifeq ($(shell echo $(IWMAKE_CONSTRAINT) | sed '/[*%]/d'),)
        IWMAKE_VERSION := $(shell $(iwmake_curl) '$(IWMAKE_ARTIFACTORY)/api/search/latestVersion?repos=$(IWMAKE_REPOSITORY)&g=$(IWMAKE_GROUPID)&a=$(IWMAKE_NAME)&v=$(IWMAKE_CONSTRAINT)')
        ifeq ($(IWMAKE_VERSION),)
            $(error Unable to find latest $(IWMAKE_NAME) version from "$(IWMAKE_CONSTRAINT)")
        endif
    endif
    iwmake_artifact_dir := $(subst .,/,$(IWMAKE_GROUPID))/$(IWMAKE_NAME)/$(IWMAKE_VERSION)
    IWMAKE_DIR := $(IWMAKE_LOCAL_REPOSITORY)/$(iwmake_artifact_dir)
    ifeq ($(wildcard $(IWMAKE_DIR)/initialize.mk),)
        $(shell mkdir -p $(IWMAKE_DIR))
        iwmake_artifact_name := $(IWMAKE_NAME)-$(IWMAKE_VERSION).tar.bz2
        ERROR := $(shell $(iwmake_curl) --output $(IWMAKE_DIR)/$(iwmake_artifact_name) $(IWMAKE_ARTIFACTORY)/$(IWMAKE_REPOSITORY)/$(iwmake_artifact_dir)/$(iwmake_artifact_name) 2>&1)
        ifneq ($(ERROR),)
            $(error Unable to download $(IWMAKE_NAME)-$(IWMAKE_VERSION): $(ERROR)))
        endif
        $(shell tar --extract --bzip2 --file=$(IWMAKE_DIR)/$(iwmake_artifact_name) --directory=$(IWMAKE_DIR))
        iwmake_artifact_name :=
    endif
    iwmake_curl :=
    iwmake_artifact_dir :=
endif

include $(IWMAKE_DIR)/initialize.mk
