#
#	Sub-module Installation calling convention.
#
#	@author	Andreas Friedl <afriedl@riegl.com>
#

$(INSTALL_LIST:%=%.install):
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) DESTDIR=$(INSTALL_DESTDIR) $@.pre 
	@[ ! -f $(@:%.install=%)/Makefile ] || $(MAKE) -C $(@:%.install=%) $(MAKE_FLAGS) $(SUBDIR_PARAMS) DESTDIR=$(INSTALL_DESTDIR)$(@:%.install=%).destdir install
	$(Q)$(MAKE) -s $(MAKE_FLAGS) DBUILD_SPLASHED=1 $(SUBDIR_PARAMS) DESTDIR=$(INSTALL_DESTDIR) $@.post

$(INSTALL_LIST:%=%.install):

install: $(INSTALL_LIST:%=%.install)

$(INSTALL_LIST:%=%.install.pre): | silent
$(INSTALL_LIST:%=%.install.post): | silent


info.installlist:
	@echo $(INSTALL_LIST)

.PHONY: install $(INSTALL_LIST:%=%.install) $(INSTALL_LIST:%=%.install.pre) $(INSTALL_LIST:%=%.install.post) info.installlist
