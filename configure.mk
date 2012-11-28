$(CONFIGURE_LIST:%=%.configure_do): %.configure_do: %.configure_pre
	@cd  $(@:%.configure_do=%) && ./configure $(CONFIG_OPTIONS) CC=$(TOOLCHAIN)gcc CXX=$(TOOLCHAIN)c++ LD=$(TOOLCHAIN)ld AR=$(TOOLCHAIN)ar $(PIPE_OPTIONS)
$(CONFIGURE_LIST:%=%.configure_post): %.configure_post: %.configure_do
$(CONFIGURE_LIST:%=%.configure): %.configure: %.configure_post
configure: $(CONFIGURE_LIST:%=%.configure)

info.configurelist:
	@echo $(CONFIGURE_LIST)

.PHONY: configure $(CONFIGURE_LIST:%=%.configure) $(CONFIGURE_LIST:%=%.configure_pre) $(CONFIGURE_LIST:%=%.configure_do) $(CONFIGURE_LIST:%=%.configure_post) info.configurelist


$(CONFIGURE_LIST): PIPE_OPTIONS=$(PRETTY_SUBGENERIC)