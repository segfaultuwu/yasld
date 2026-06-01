.PHONY: limine limine-check update-limine

update-limine:
	@test -d "$(LIMINE_DIR)" || (echo "missing $(LIMINE_DIR)"; exit 1)
	cd $(LIMINE_DIR) && git fetch origin && git switch "$(LIMINE_BRANCH)" && git pull --ff-only

limine:
	@test -d "$(LIMINE_DIR)" || (echo "missing $(LIMINE_DIR). clone limine first"; exit 1)
	$(MAKE) -C $(LIMINE_DIR)

limine-check:
	@test -d "$(LIMINE_DIR)" || (echo "missing $(LIMINE_DIR). clone limine first"; exit 1)
	@test -f "$(LIMINE_DIR)/limine-bios.sys" || $(MAKE) -C $(LIMINE_DIR)
	@test -f "$(LIMINE_DIR)/limine-bios-cd.bin" || $(MAKE) -C $(LIMINE_DIR)
	@test -f "$(LIMINE_DIR)/limine-uefi-cd.bin" || $(MAKE) -C $(LIMINE_DIR)
	@test -f "$(LIMINE_DIR)/BOOTX64.EFI" || (echo "missing $(LIMINE_DIR)/BOOTX64.EFI"; exit 1)
	@test -f "$(LIMINE_DIR)/BOOTIA32.EFI" || (echo "missing $(LIMINE_DIR)/BOOTIA32.EFI"; exit 1)
	@test -x "$(LIMINE_DIR)/limine" || (echo "missing executable $(LIMINE_DIR)/limine"; exit 1)
