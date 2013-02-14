#
#	Dark Builder - Designed and Created by James Walmsley
#
#	Dark Builder attempts to provide a clean framework for creating organised
#	and "pretty" builds with minimal effort.
#
#	Dark Builder is based upon the vebuild as found in the FullFAT project
#	in the .vebuild directory.
#
#	@see		github.com/FullFAT/FullFAT/
#	@author		James Walmsley	<jwalmsley@riegl.com>
#
#	@version	1.3.0 (Archimedes)
#

DBUILD_VERSION_MAJOR=1
DBUILD_VERSION_MINOR=3
DBUILD_VERSION_REVISION=1

DBUILD_VERSION_NAME=Archimedes
DBUILD_VERSION_DATE=November 2012

#
#	Get dbuild root directory.
#
DBUILD_ROOT:=$(dir $(lastword $(MAKEFILE_LIST)))../

#
#	Let's ensure we have a pure make environment.
#	(Delete all rules and variables).
#
MAKEFLAGS += -rR --no-print-directory

all: dbuild_splash _all

#
#	A top-level configureation file can be found in the project root dir.
#
-include $(DBUILD_ROOT)dbuild.config.mk

#
#	A config file can be overidden or extended in any sub-directory
#
-include dbuild.config.mk

#
#	Optional Include directive, blue build attempts to build using lists of objects,
#	targets and subdirs as found in objects.mk and subdirs.mk
#
-include .config.mk
-include objects.mk
-include targets.mk
-include subdirs.mk

#
#	Simple backwards compatible for configurable object builds!
#
OBJECTS += $(OBJECTS-y)

#
#	Defaults for compile/build toolchain
#
override TOOLCHAIN 	?=
override AR			= $(TOOLCHAIN)ar
override AS			= $(TOOLCHAIN)as
override CC		 	= $(TOOLCHAIN)gcc
override CXX		= $(TOOLCHAIN)g++
override LD			= $(TOOLCHAIN)ld
override OBJCOPY	= $(TOOLCHAIN)objcopy
override OBJDUMP	= $(TOOLCHAIN)objdump
override SIZE		= $(TOOLCHAIN)size

CFLAGS		+= -c

CFLAGS 		+= $(ADD_CFLAGS)
CXXFLAGS 	+= $(ADD_CXXFLAGS)
LDFLAGS 	+= $(ADD_LDFLAGS)

#
#	Incase the objects.mk or the .config.mk file does not exist, create a blank one.
#	We should eventually integrate this with KConfig or something nice.
#
.config.mk:
	@touch .config.mk

objects.mk:
	@touch objects.mk

$(TARGETS): objects.mk .config.mk

include $(DBUILD_ROOT).dbuild/verbosity.mk
include $(DBUILD_ROOT).dbuild/pretty.mk
include $(DBUILD_ROOT).dbuild/subdirs.mk
include $(DBUILD_ROOT).dbuild/clean.mk
include $(DBUILD_ROOT).dbuild/module-link.mk
include $(DBUILD_ROOT).dbuild/c-objects.mk
include $(DBUILD_ROOT).dbuild/cpp-objects.mk
include $(DBUILD_ROOT).dbuild/asm-objects.mk
include $(DBUILD_ROOT).dbuild/info.mk


#
#	Provide a default target named all,
#	This is dependent on $(TARGETS), $(MODULE_TARGET) and $(SUBDIRS)
#
#	All is finally dependent on silent, to keep make silent when it has
#	nothing to do.
#
dbuild_entry: dbuild_splash | _all
_all: $(TARGETS) $(BASIC_TARGETS) $(SUBDIR_LIST) $(MODULE_TARGET) | silent

#
#	DBuild Splash
#
.PHONY: dbuild_splash
dbuild_splash:
ifeq ($(DBUILD_SPLASHED), 1)
else
	@echo " Dark Builder"
	@echo " Version ($(DBUILD_VERSION_MAJOR).$(DBUILD_VERSION_MINOR).$(DBUILD_VERSION_REVISION) - $(DBUILD_VERSION_NAME))"
endif

EXPORTS=CFLAGS

#
#	Finally provide an implementation of the silent target.
#
silent:
	@:

