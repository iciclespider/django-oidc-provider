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

include iwmake.mk

NAME := $(shell sed -n "s|^ *name *= *'\([^']\+\)'.*|\1|p" setup.py)
VERSION := $(shell cat oidc_provider/VERSION)

ifeq ($(RUNTIME),)
  RUNTIME := $(build)
endif

####################################################################
# Python virtual environment creation
####################################################################

python := python3.6
python_release_file := oidc_provider/RELEASE
python_venv_prerequisites += ~/.pypirc
python_venv_no_binary := :none:
python_venv_build := $(RUNTIME)/venv

include $(MK_DIR)/python_venv.mk

####################################################################
# runtime scripts
####################################################################

runtime_entrypoint := $(RUNTIME)/entrypoint
runtime_uwsgi_ini := $(RUNTIME)/uwsgi.ini

$(runtime_entrypoint): entrypoint
	$(call START,Copy entrypoint)
	@mkdir -p $(dir $@)
	cp $< $@
	$(call FINISH,Copy entrypoint)

$(runtime_uwsgi_ini): uwsgi.ini
	$(call START,Copy uwsgi.ini)
	@mkdir -p $(dir $@)
	cp $< $@
	$(call FINISH,Copy uwsgi.ini)

.PHONY: runtime
runtime: $(python_venv_dependencies) $(runtime_entrypoint) $(runtime_uwsgi_ini)

####################################################################
# lint and test
####################################################################

.PHONY: lint
lint:: $(python_venv_dependencies)
	$(call START,Lint python)
	$(python_venv_build)/bin/python setup.py lint
	$(call FINISH,Lint python)

.PHONY: test
test:: $(python_venv_dependencies)
	$(call START,Test python)
	$(python_venv_build)/bin/python setup.py test
	$(call FINISH,Test python)

####################################################################
# Development helpers
####################################################################

.PHONY: dev-vinstall
dev-vinstall:
	PYTHON_DEV=true $(MAKE) vinstall

####################################################################
# docker build
####################################################################

DOCKER_FROM_REPOSITORY := docker-tripwire-local
DOCKER_FROM := com/tripwire/rav/centos/base/centos-base

include $(MK_DIR)/docker.mk
include $(MK_DOCKER)/image.mk
