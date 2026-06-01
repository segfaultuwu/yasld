.PHONY: check-tools

check-tools:
	@command -v $(GO) >/dev/null || (echo "missing go"; exit 1)
	@command -v $(CPIO) >/dev/null || (echo "missing cpio"; exit 1)
	@command -v $(XORRISO) >/dev/null || (echo "missing xorriso"; exit 1)
	@command -v $(QEMU) >/dev/null || echo "warning: qemu-system-x86_64 not found"
