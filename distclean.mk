$(DISTCLEAN_LIST:%=%.distclean): 
	$(Q)$(MAKE) $@.pre
	[ ! -f $(@:%.distclean=%)/Makefile ] || $(MAKE) -C $(@:%.distclean=%) distclean
	$(Q)$(MAKE) $@.post

distclean: $(DISTCLEAN_LIST:%=%.distclean)

info.distcleanlist:
	@echo $(DISTCLEAN_LIST)

.PHONY: \
		distclean \
		$(DISTCLEAN_LIST:%=%.distclean) \
		$(DISTCLEAN_LIST:%=%.distclean.pre) \
		$(DISTCLEAN_LIST:%=%.distclean.post) \
		info.distcleanlist
