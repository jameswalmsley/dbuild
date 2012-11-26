$(INSTALL_LIST:%=%.install_do):
		[ ! -f $(@:%.install_do=%)/Makefile ] || $(MAKE) -C $(@:%.install_do=%) DESTDIR=$(INSTALL_ROOT_DESTDIR)$(@:%.install_do=%).destdir install
.SECONDEXPANSION:
$(INSTALL_LIST:%=%.install): | $$@_pre $$@_do $$@_post
install: $(INSTALL_LIST:%=%.install)

info.installlist:
	@echo $(INSTALL_LIST)

.PHONY: install $(INSTALL_LIST:%=%.install) $(INSTALL_LIST:%=%.install_pre) $(INSTALL_LIST:%=%.install_do) $(INSTALL_LIST:%=%.install_post) info.installlist
