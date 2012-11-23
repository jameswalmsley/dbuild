$(DISTCLEAN_LIST:%=%.distclean_do):
		[ ! -f $(@:%.distclean_do=%)/Makefile ] || $(MAKE) -C $(@:%.distclean_do=%) distclean
.SECONDEXPANSION:
$(DISTCLEAN_LIST:%=%.distclean): | $$@_pre $$@_do $$@_post
distclean: $(DISTCLEAN_LIST:%=%.distclean)

info.distcleanlist:
	@echo $(DISTCLEAN_LIST)

.PHONY: distclean $(DISTCLEAN_LIST:%=%.distclean) $(DISTCLEAN_LIST:%=%.distclean_pre) $(DISTCLEAN_LIST:%=%.distclean_do) $(DISTCLEAN_LIST:%=%.distclean_post) info.distcleanlist
