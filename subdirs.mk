#
#	Riegl Builder - Subdirectory handling.
#
#	@author	James Walmsley <jwalmsley@riegl.com>
#

#
#	Each listed item in the SUBDIRS variable shall be executed in parallel.
#	We must therefore take care to provide a make job server.
#	Hence the +make command via $(MAKE).
#

#
#	This is a special feature allowing make to descend into multiple directories,
#	without having to call another makefile recursively.
#
include $(addsuffix objects.mk, $(SUB_OBJDIRS))
include $(addsuffix objects.mk, $(SUB_OBJDIRS-y))

#
#	Add optional SUBDIR variables for simple build configuration system.
#
SUBDIRS 	+= $(SUBDIRS-y)
SUB_KBUILD 	+= $(SUB_KBUILD-y)
SUB_GENERIC += $(SUB_GENERIC-y)
SUB_SAFE 	+= $(SUB_SAFE-y)

#
#	Concatenate all lists into a single SUBDIR_LIST variable for convenience.
#
SUBDIR_LIST += $(SUBDIRS)
SUBDIR_LIST += $(SUB_KBUILD)
SUBDIR_LIST += $(SUB_GENERIC)
SUBDIR_LIST += $(SUB_SAFE)


###########################################################################################################
#
#	Deps Generation.
#
DSUBDIR_LIST += $(DSUB_GENERIC) 
DSUBDIR_LIST += $(DSUB_SAFE) 

SUBDIR_LIST += $(DSUBDIR_LIST)

DEPS_ROOT_DIR = .deps/

$(DSUBDIR_LIST:%=%.deps):
	$(Q)mkdir -p $(DEPS_ROOT_DIR)$(dir $@)
	$(Q)bash $(BASE).dbuild/makedeps.sh $(@:%.deps=%) $(@:%.deps=%) > $(DEPS_ROOT_DIR)$(@:%.deps=%).d

deps: $(DSUBDIR_LIST:%=%.deps)

.PHONY: deps $(DSUBDIR_LIST:%=%.deps)

-include $(DEPS_ROOT_DIR)$(DSUBDIR_LIST:%=%.d)

###########################################################################################################
#
#	Standard SUBDIR mechanism for the best case, that the SUBDIR contains a project
#	that also uses DBUILD.
#
$(SUBDIRS:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%=%)"
ifeq ($(DBUILD_VERBOSE_DEPS), 1)
	$(Q)$(PRETTY) --dbuild "^DEPS^" "$@" "$^"
endif
endif
	$(Q)$(MAKE) -s BUILD_SPLASHED=1 $@.pre
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post


#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean).
#
$(SUBDIRS:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) -s BUILD_SPLASHED=1 $@.pre
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post


#
#	A number of projects use KBuild, from kernel.org. We want to allow the KBuild output
#	to be normalised into the standard DBUILD output format.
#
#	Hence we have a separate rule...
#
$(SUB_KBUILD:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $@"
ifeq ($(DBUILD_VERBOSE_DEPS), 1)
	$(Q)$(PRETTY) --dbuild "^DEPS^" "$@" "$^"
endif
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) |  $(PRETTY_SUBKBUILD) $@
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#	Again the same, adding a .clean() method to the SUB_KBUILD targets.
#
$(SUB_KBUILD:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBKBUILD) "$(@:%.clean=%)"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#	99.99999% of Makefile projects simply output the GCC/libtool or whatever else they use.
#	This provides thes case for normalising these outputs as much as possible.
#	The PRETTY_SUBGENERIC parser is used, is very basic, and should be improved over time.
#
$(SUB_GENERIC:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%=%)"
ifeq ($(DBUILD_VERBOSE_DEPS), 1)
	$(Q)$(PRETTY) --dbuild "^DEPS^" "$@" "$^"
endif
endif
	$(Q)$(MAKE) MAKEFLAGS= BUILD_SPLASHED=1 -s $@.pre
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)  | $(PRETTY_SUBGENERIC) $@
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#	Again provide a clean method for that.
#
$(SUB_GENERIC:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC)  "$(@:%.clean=%)"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

###########################################################################################################
#
#	This provides a method for building modules in the absolute worst case scenario!
#	This is required if its impossible to build the target in parrallel reliably.
#
#	It just forces the build to use a single thread (-j1) and attempts to silence MAKEs
#	inscessant need to nag you its attention.
#
#	Yes "WARNING: Jobserver disabled message... I'm talking about you....pointless!
#
$(SUB_SAFE:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "!SAFE!" $(MODULE_NAME) "Building $(@:%=%)"
ifeq ($(DBUILD_VERBOSE_DEPS), 1)
	$(Q)$(PRETTY) --dbuild "^DEPS^" "$@" "$^"
endif
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)cd $@ && bash -c "$(MAKE) -s -j1 $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) | $(PRETTY_SUBGENERIC) $@"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#   .... Of course another clean method!
#
$(SUB_SAFE:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)cd $(@:%.clean=%) && bash -c "$(MAKE) -s -j1 $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC) $(@:%.clean=%)"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post


$(DSUB_GENERIC:%=$(DEPS_ROOT_DIR)%.stamp): $($(@:$(DEPS_ROOT_DIR)%.stamp=DEPS_%))
#ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:$(DEPS_ROOT_DIR)%.stamp=%)"
#ifeq ($(DBUILD_VERBOSE_DEPS), 1)
#	$(Q)$(PRETTY) --dbuild "^DEPS^" "$(@:$(DEPS_ROOT_DIR)%.stamp=%)" "$^"
#endif
#endif
	$(Q)$(MAKE) MAKEFLAGS= -s $(@:$(DEPS_ROOT_DIR)%.stamp=%).pre
	$(Q)$(MAKE) MAKEFLAGS= -C $(@:$(DEPS_ROOT_DIR)%.stamp=%) $(SUBDIR_TARGET) | $(PRETTY_SUBGENERIC) "$(@:$(DEPS_ROOT_DIR)%.stamp=%)"
	$(Q)$(MAKE) MAKEFLAGS= -s $(@:$(DEPS_ROOT_DIR)%.stamp=%).post
	$(Q)touch $@

$(DSUB_GENERIC:%=%):
	$(Q)$(MAKE) $(@:%=$(DEPS_ROOT_DIR)%.stamp)

$(DSUB_GENERIC:%=%.force):
	$(Q)rm -f $(@:%.force=$(DEPS_ROOT_DIR)%.stamp)
	$(Q)$(MAKE) $(@:%.force=%)

$(DSUB_GENERIC:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)$(MAKE) MAKEFLAGS= -C $(@:%.clean=%) BUILD_SPLASHED=1 clean | $(PRETTY_SUBGENERIC)  "$(@:%.clean=%)"
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.post
	$(Q)rm -f $(@:%.clean=$(DEPS_ROOT_DIR)%.stamp)



$(DSUB_SAFE:%=$(DEPS_ROOT_DIR)%.stamp): $($(@:$(DEPS_ROOT_DIR)%.stamp=DEPS_%))
	$(Q)$(PRETTY) --dbuild "!SAFE!" $(MODULE_NAME) "Building $(@:$(DEPS_ROOT_DIR)%.stamp=%)"
#ifeq ($(DBUILD_VERBOSE_DEPS), 1)
	$(Q)$(PRETTY) --dbuild "^DEPS^" "$(@:$(DEPS_ROOT_DIR)%.stamp=%)" "$^"
#endif
#endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $(@:$(DEPS_ROOT_DIR)%.stamp=%).pre
	$(Q)cd $(@:$(DEPS_ROOT_DIR)%.stamp=%) && bash -c "$(MAKE) MAKEFLAGS= -j1 BUILD_SPLASHED=1 $(SUBDIR_TARGET) | $(PRETTY_SUBGENERIC) $(@:$(DEPS_ROOT_DIR)%.stamp=%)"
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $(@:$(DEPS_ROOT_DIR)%.stamp=%).post
	$(Q)touch $@

$(DSUB_SAFE:%=%):
	$(Q)$(MAKE) $(@:%=$(DEPS_ROOT_DIR)%.stamp)

$(DSUB_SAFE:%=%.force):
	$(Q)rm -f $(@:%.force=$(DEPS_ROOT_DIR)%.stamp)
	$(Q)$(MAKE) $(@:%.force=%)

$(DSUB_SAFE:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.pre
	$(Q)cd $(@:%.clean=%) && bash -c "$(MAKE) MAKEFLAGS= -j1 BUILD_SPLASHED=1 clean | $(PRETTY_SUBGENERIC) $(@:%.clean=%)"
	$(Q)$(MAKE) MAKEFLAGS= -s BUILD_SPLASHED=1 $@.post
	$(Q)rm -f $(@:%.clean=$(DEPS_ROOT_DIR)%.stamp)


clean: $(SUBDIR_LIST:%=%.clean)

info.cleanlist:
	@echo $(SUBDIR_LIST:%=%.clean)

$(SUBDIR_LIST:%=%.pre): | silent
$(SUBDIR_LIST:%=%.post): | silent

.PHONY: \
		$(SUBDIR_LIST) \
		$(SUBDIR_LIST:%=%.pre) \
		$(SUBDIR_LIST:%=%.post) \
		$(SUBDIR_LIST:%=%.force) \
		clean \
		$(SUBDIR_LIST:%=%.clean) \
		$(SUBDIR_LIST:%=%.clean.pre) \
		$(SUBDIR_LIST:%=%.clean.post) \
		info.cleanlist
