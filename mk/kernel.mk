.PHONY: kernel kernel-config kernel-menuconfig kernel-clean

kernel-config:
	@test -d "$(LINUX_DIR)" || (echo "missing $(LINUX_DIR)"; exit 1)
	@if [ -f "$(KERNEL_CONFIG)" ]; then \
		cp "$(KERNEL_CONFIG)" "$(LINUX_DIR)/.config"; \
		$(MAKE) -C "$(LINUX_DIR)" olddefconfig; \
	else \
		echo "warning: missing $(KERNEL_CONFIG), using linux/.config or defconfig"; \
		if [ ! -f "$(LINUX_DIR)/.config" ]; then \
			$(MAKE) -C "$(LINUX_DIR)" defconfig; \
		fi; \
	fi

kernel: kernel-config
	$(MAKE) -C $(LINUX_DIR) -j$(JOBS)
	@test -f "$(KERNEL_IMAGE)" || (echo "missing $(KERNEL_IMAGE)"; exit 1)

kernel-menuconfig:
	@test -d "$(LINUX_DIR)" || (echo "missing $(LINUX_DIR)"; exit 1)
	$(MAKE) -C $(LINUX_DIR) menuconfig
	cp "$(LINUX_DIR)/.config" "$(KERNEL_CONFIG)"

kernel-clean:
	$(MAKE) -C $(LINUX_DIR) clean
