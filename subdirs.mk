#
#	Riegl Builder - Subdirectory handling.
#
#	@author	James Walmsley <jwalmsley@riegl.com>
#

#
#	Each listed item in the SUBDIRS variable shall be executed in parralel.
#	We must therefore take care to provide a make job server.
#	Hence the +make command.
#

include $(addsuffix objects.mk, $(SUB_OBJDIRS))

SUBDIR_LIST= $(SUBDIRS) \
			 $(SUB_KBUILD) \
			 $(SUB_GENERIC) \
			 $(SUB_SAFE)

###########################################################################################################
#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean).
#


$(SUBDIRS:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%=%)"
	@echo $@ "Depends on:" $^
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post


#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUBDIRS:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

###########################################################################################################
#
#	Calls a KBuild based make, but pipes through our pretty system to normalise output.
#
$(SUB_KBUILD:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $@"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) |  $(PRETTY_SUBKBUILD) $@
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUB_KBUILD:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBKBUILD) "$(@:%.clean=%)"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

###########################################################################################################
#
#	A Generic Prettyfier for sub-makes that simply use full GCC output!
#
$(SUB_GENERIC:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)  | $(PRETTY_SUBGENERIC) $@
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUB_GENERIC:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC)  "$(@:%.clean=%)"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

###########################################################################################################
#
#	A Prettyfier for safe sub-makes!
#
$(SUB_SAFE:%=%):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "!SAFE!" $(MODULE_NAME) "Building $(@:%=%)"
endif
	$(Q)cd $@ && bash -c "$(MAKE) -j1 $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) | $(PRETTY_SUBGENERIC) $@"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

#
#   Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUB_SAFE:%=%.clean):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)cd $($@:%.clean=%) && bash -c "$(MAKE) -j1 $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC) $(@:%.clean_do=%)"
	$(Q)$(MAKE) -s $(MAKE_FLAGS) BUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

###########################################################################################################
#
#	Handle pre and post targets
#

$(SUBDIR_LIST:%=%): %: %.pre
$(SUBDIR_LIST:%=%.clean): %.clean: %.clean.pre

clean: $(SUBDIR_LIST:%=%.clean)

info.cleanlist:
	   @echo $(SUBDIR_LIST:%=%.clean)

.PHONY: \
		$(SUBDIRS) \
		$(SUBDIR_LIST:%=%.pre) \
		$(SUBDIR_LIST:%=%.post) \
		clean \
		$(SUBDIR_LIST:%=%.clean) \
		$(SUBDIR_LIST:%=%.clean.pre) \
		$(SUBDIR_LIST:%=%.clean.post) \
		info.cleanlist
