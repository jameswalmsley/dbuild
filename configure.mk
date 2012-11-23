$(CONFIGURE_LIST:%=%.configure_do):
		cd  $(@:%.configure_do=%) && ./configure --build=$(CONFIGURE_BUILD) --host=$(CONFIGURE_HOST) --prefix=/ $(CONFIG_OPTIONS)
.SECONDEXPANSION:
$(CONFIGURE_LIST:%=%.configure): | $$@_pre $$@_do $$@_post
										  
configure: $(CONFIGURE_LIST:%=%.configure)

info.configurelist:
	@echo $(CONFIGURE_LIST)

.PHONY: configure $(CONFIGURE_LIST:%=%.configure) $(CONFIGURE_LIST:%=%.configure_pre) $(CONFIGURE_LIST:%=%.configure_do) $(CONFIGURE_LIST:%=%.configure_post) info.configurelist

