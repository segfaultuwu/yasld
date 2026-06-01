include mk/config.mk
include mk/tools.mk
include mk/fs.mk
include mk/limine.mk
include mk/kernel.mk
include mk/gobox.mk
include mk/third_party.mk
include mk/gcc.mk
include mk/initramfs.mk
include mk/iso.mk
include mk/qemu.mk

.PHONY: all clean distclean update-submodules

all: iso

update-submodules:
	git submodule sync --recursive
	git submodule update --init --recursive --remote --depth=1

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	$(MAKE) -C $(LINUX_DIR) clean
	$(MAKE) -C $(GOBOX_DIR) clean
	@if [ -d "$(THIRD_PARTY_DIR)" ]; then \
		$(MAKE) -C $(THIRD_PARTY_DIR) distclean; \
	fi
