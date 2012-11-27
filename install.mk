.SECONDEXPANSION:
$(INSTALL_LIST:%=%.install_do): %.install_do: %.install_pre
		[ ! -f $(@:%.install_do=%)/Makefile ] || $(MAKE) -C $(@:%.install_do=%) DESTDIR=$(INSTALL_DESTDIR)$(@:%.install_do=%).destdir install
$(INSTALL_LIST:%=%.install_post): %.install_post: %.install_do
$(INSTALL_LIST:%=%.install): %.install: %.install_post
install: $(INSTALL_LIST:%=%.install)

info.installlist:
	@echo $(INSTALL_LIST)

.PHONY: install $(INSTALL_LIST:%=%.install) $(INSTALL_LIST:%=%.install_pre) $(INSTALL_LIST:%=%.install_do) $(INSTALL_LIST:%=%.install_post) info.installlist
