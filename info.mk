
info.config:
	@echo "CONFIG_  : " $(CONFIG_)
	@echo "TOOLCHAIN: " $($(CONFIG_)TOOLCHAIN)

info.toolchain:
	@echo "TOOLCHAIN: " $(TOOLCHAIN)
	@echo "CC       : " $(CC)
	@echo "CXX      : " $(CXX) 

info.subdirs:
	@echo $(SUBDIRS)
