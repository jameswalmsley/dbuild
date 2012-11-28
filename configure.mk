$(CONFIGURE_LIST:%=%.configure):
	$(Q)$(MAKE) $@.pre
	@cd  $(@:%.configure=%) && ./configure $(CONFIG_OPTIONS) CC=$(TOOLCHAIN)gcc CXX=$(TOOLCHAIN)c++ LD=$(TOOLCHAIN)ld AR=$(TOOLCHAIN)ar $(PIPE_OPTIONS)
	$(Q)$(MAKE) $@.post

configure: $(CONFIGURE_LIST:%=%.configure)

info.configurelist:
	@echo $(CONFIGURE_LIST)

$(CONFIGURE_LIST): PIPE_OPTIONS=$(PRETTY_SUBGENERIC)

.PHONY: \
		configure \
		$(CONFIGURE_LIST:%=%.configure) \
		$(CONFIGURE_LIST:%=%.configure.pre) \
		$(CONFIGURE_LIST:%=%.configure.post) \
		info.configurelist
