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

#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean).
#
$(SUBDIRS):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $@"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $@ DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)


#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean).
#
$(SUBDIRS:%=%.do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%.do=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)

#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUBDIRS:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean_do=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean_do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean

#
#
#	Calls a KBuild based make, but pipes through our pretty system to normalise output.
#
$(SUB_KBUILD:%=%.do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%.do=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) |  $(PRETTY_SUBKBUILD) $(@:%.do=%)

#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUB_KBUILD:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean_do=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean_do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBKBUILD) "$(@:%.clean_do=%)"

#
#
#	A Generic Prettyfier for sub-makes that simply use full GCC output!
#
$(SUB_GENERIC:%=%.do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "BUILD" $(MODULE_NAME) "Building $(@:%.do=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET)  | $(PRETTY_SUBGENERIC) $(@:%.do=%)

#
#	Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUB_GENERIC:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLEAN" $(MODULE_NAME) "$(@:%.clean_do=%)"
endif
	$(Q)$(MAKE) $(MAKE_FLAGS) -C $(@:%.clean_do=%) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC)  "$(@:%.clean_do=%)"

#
#
#	A Prettyfier for safe sub-makes!
#
$(SUB_SAFE:%=%.do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "!SAFE!" $(MODULE_NAME) "Building $(@:%.do=%)"
endif
	$(Q)cd $(@:%.do=%) && bash -c "$(MAKE) -j1 $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $(SUBDIR_TARGET) | $(PRETTY_SUBGENERIC) $(@:%.do=%)"

#
#   Sub-dir Clean targets. (Creates $SUBDIR.clean_do).
#
$(SUB_SAFE:%=%.clean_do):
ifeq ($(DBUILD_VERBOSE_CMD), 0)
	$(Q)$(PRETTY) --dbuild "CLDIR" $(MODULE_NAME) "$(@:%.clean_do=%)"
endif
	$(Q)cd $(@:%.clean_do=%) && bash -c "$(MAKE) -j1 $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) clean | $(PRETTY_SUBGENERIC) $(@:%.clean_do=%)"

#
#	Handle pre and post targets
#

$(SUBDIR_LIST:%=%.do): %.do: %.pre
$(SUBDIR_LIST:%=%.post): %.post: %.do
$(SUBDIR_LIST:%=%): %: %.post

$(SUBDIR_LIST:%=%.clean_do): %.clean_do: %.clean_pre
$(SUBDIR_LIST:%=%.clean_post): %.clean_post: %.clean_do
$(SUBDIR_LIST:%=%.clean): %.clean: %.clean_post
clean: $(SUBDIR_LIST:%=%.clean)

info.cleanlist:
	   @echo $(SUBDIR_LIST:%=%.clean)

.PHONY: \
		$(SUBDIRS) \
		$(SUBDIR_LIST:%=%.pre) \
		$(SUBDIR_LIST:%=%.do) \
		$(SUBDIR_LIST:%=%.post) \
		clean \
		$(SUBDIR_LIST:%=%.clean) \
		$(SUBDIR_LIST:%=%.clean_pre) \
		$(SUBDIR_LIST:%=%.clean_do) \
		$(SUBDIR_LIST:%=%.clean_post) \
		info.cleanlist
