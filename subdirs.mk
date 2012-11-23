#
#	Riegl Builder - Subdirectory handling.
#
#	@author	James Walmsley <jwalmsley@riegl.com>
#

.PHONY:$(SUBDIRS)
.PHONY:$(SUB_KBUILD)
.PHONY:$(SUB_GENERIC)

#
#	Each listed item in the SUBDIRS variable shall be executed in parralel.
#	We must therefore take care to provide a make job server.
#	Hence the +make command.
#

include $(addsuffix objects.mk, $(SUB_OBJDIRS))

$(SUBDIRS):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $@"
endif
	$(Q)$(MAKE) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)


#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean).
#
$(SUBDIRS:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLDIR" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) -C $(@:%.clean_do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean

#
#	Calls a KBuild based make, but pipes through our pretty system to normalise output.
#
$(SUB_KBUILD):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $@"
endif
	$(Q)$(MAKE) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) |  $(PRETTY_SUBKBUILD) $@

$(SUB_KBUILD:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLDIR" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) -C $(@:%.clean_do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBKBUILD) "$(@:%.clean=%)"

#
#	A Generic Prettyfier for sub-makes that simply use full GCC output!
#
$(SUB_GENERIC):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $@"
endif
	$(Q)$(MAKE) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)  | $(PRETTY_SUBGENERIC) $@


#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean).
#
$(SUB_GENERIC:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLDIR" $(MODULE_NAME) "$(@:%.clean=%)"
endif
	$(Q)$(MAKE) -C $(@:%.clean_do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC)  $@


	
CLEAN_LIST=$(SUBDIRS) $(SUB_KBUILD) $(SUB_GENERIC)

.SECONDEXPANSION:
$(CLEAN_LIST:%=%.clean): | $$@_pre $$@_do $$@_post
clean: $(CLEAN_LIST:%=%.clean)

info.cleanlist:
	   @echo $(CLEAN_LIST)

.PHONY: clean clean.subdirs $(CLEAN_LIST:%=%.clean) $(CLEAN_LIST:%=%.clean_pre) $(CLEAN_LIST:%=%.clean_do) $(CLEAN_LIST:%=%.clean_post) info.cleanlist
