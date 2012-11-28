$(INSTALL_LIST:%=%.install):
	$(Q)$(MAKE) $@.pre
	[ ! -f $(@:%.install=%)/Makefile ] || $(MAKE) -C $(@:%.install=%) DESTDIR=$(INSTALL_DESTDIR)$(@:%.install=%).destdir install
	$(Q)$(MAKE) $@.post

install: $(INSTALL_LIST:%=%.install)

info.installlist:
	@echo $(INSTALL_LIST)

.PHONY: \
		install \
		$(INSTALL_LIST:%=%.install) \
		$(INSTALL_LIST:%=%.install.pre) \
		$(INSTALL_LIST:%=%.install.post) \
		info.installlist
