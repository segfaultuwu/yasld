.PHONY: iso inspect-iso print-tree

iso: check-tools limine-check kernel initramfs
	rm -rf $(ISO_ROOT)
	mkdir -p $(ISO_ROOT)/boot/limine
	mkdir -p $(ISO_ROOT)/EFI/BOOT

	cp $(KERNEL_IMAGE) $(ISO_ROOT)/boot/bzImage
	cp $(INITRAMFS) $(ISO_ROOT)/boot/initramfs.cpio
	cp $(CFG_DIR)/limine.conf $(ISO_ROOT)/boot/limine/limine.conf

	cp $(LIMINE_DIR)/limine-bios.sys $(ISO_ROOT)/boot/limine/
	cp $(LIMINE_DIR)/limine-bios-cd.bin $(ISO_ROOT)/boot/limine/
	cp $(LIMINE_DIR)/limine-uefi-cd.bin $(ISO_ROOT)/boot/limine/

	cp $(LIMINE_DIR)/BOOTX64.EFI $(ISO_ROOT)/EFI/BOOT/BOOTX64.EFI
	cp $(LIMINE_DIR)/BOOTIA32.EFI $(ISO_ROOT)/EFI/BOOT/BOOTIA32.EFI

	$(XORRISO) -as mkisofs \
		-b boot/limine/limine-bios-cd.bin \
		-no-emul-boot \
		-boot-load-size 4 \
		-boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part \
		--efi-boot-image \
		--protective-msdos-label \
		-o $(ISO) \
		$(ISO_ROOT)

	$(LIMINE_DIR)/limine bios-install $(ISO)

	@echo
	@echo "ISO ready: $(ISO)"
	@echo
	@$(MAKE) print-tree

inspect-iso:
	xorriso -indev $(ISO) -find / -type f

print-tree:
	@echo "ISO contents:"
	@xorriso -indev $(ISO) -find / -type f 2>/dev/null | grep -E 'bzImage|initramfs|limine|BOOT' || true
	@echo
	@echo "Initramfs important files:"
	@find $(INITRAMFS_DIR) -maxdepth 3 \( -type f -o -type l \) | sort | grep -E '/init|/bin/gobox|/bin/sh|/usr/bin/bash|/usr/bin/git|/usr/bin/curl|/usr/sbin/dropbear|/etc/' || true
