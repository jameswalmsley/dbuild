#
#	Sub-module DISTCLEAN calling convention.
#
#	@author Andreas Friedl <afriedl@riegl.com>
#


$(DISTCLEAN_LIST:%=%.distclean): 
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.pre
	@[ ! -f $(@:%.distclean=%)/Makefile ] || $(MAKE) -C $(@:%.distclean=%) $(MAKE_FLAGS) $(SUBDIR_PARAMS) distclean
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) $@.post

distclean: $(DISTCLEAN_LIST:%=%.distclean)

$(DISTCLEAN_LIST:%=%.distclean.pre): | silent
$(DISTCLEAN_LIST:%=%.distclean.post): | silent

info.distcleanlist:
	@echo $(DISTCLEAN_LIST)

.PHONY: distclean $(DISTCLEAN_LIST:%=%.distclean) $(DISTCLEAN_LIST:%=%.distclean.pre) $(DISTCLEAN_LIST:%=%.distclean.post) info.distcleanlist
