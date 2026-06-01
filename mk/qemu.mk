.PHONY: run run-serial run-kvm

run:
	$(QEMU) \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-vga $(QEMU_VGA) \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0

run-serial:
	$(QEMU) \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-vga $(QEMU_VGA) \
		-serial stdio \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0

run-kvm:
	$(QEMU) \
		-enable-kvm \
		-cpu host \
		-m $(QEMU_MEM) \
		-cdrom $(ISO) \
		-boot d \
		-vga $(QEMU_VGA) \
		-netdev user,id=net0,hostfwd=tcp::2222-:22 \
		-device virtio-net-pci,netdev=net0
