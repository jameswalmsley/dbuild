$(DISTCLEAN_LIST:%=%.distclean_do): %.distclean_do: %.distclean_pre
		[ ! -f $(@:%.distclean_do=%)/Makefile ] || $(MAKE) -C $(@:%.distclean_do=%) distclean
$(DISTCLEAN_LIST:%=%.distclean_post): %.distclean_post: %.distclean_do
$(DISTCLEAN_LIST:%=%.distclean): %.distclean: %.distclean_post
distclean: $(DISTCLEAN_LIST:%=%.distclean)

info.distcleanlist:
	@echo $(DISTCLEAN_LIST)

.PHONY: distclean $(DISTCLEAN_LIST:%=%.distclean) $(DISTCLEAN_LIST:%=%.distclean_pre) $(DISTCLEAN_LIST:%=%.distclean_do) $(DISTCLEAN_LIST:%=%.distclean_post) info.distcleanlist
