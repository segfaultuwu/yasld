BUILD_DIR ?= ../build/third_party
ROOT_DIR := $(BUILD_DIR)/root
PREFIX ?= /usr

JOBS ?= $(shell nproc)

CURL_DIR := curl
CURL_BIN := $(ROOT_DIR)$(PREFIX)/bin/curl
CURL_STAMP := $(BUILD_DIR)/curl-built

DROPBEAR_DIR := dropbear
DROPBEAR_BIN := $(ROOT_DIR)$(PREFIX)/sbin/dropbear
DROPBEARKEY_BIN := $(ROOT_DIR)$(PREFIX)/bin/dropbearkey
DBCLIENT_BIN := $(ROOT_DIR)$(PREFIX)/bin/dbclient
SCP_BIN := $(ROOT_DIR)$(PREFIX)/bin/scp
DROPBEAR_STAMP := $(BUILD_DIR)/dropbear-built
DROPBEAR_PROGRAMS := dropbear dbclient scp dropbearkey
BASH_DIR := bash
BASH_BIN := $(ROOT_DIR)$(PREFIX)/bin/bash
BASH_STAMP := $(BUILD_DIR)/bash-built

GIT_DIR := git
GIT_BIN := $(ROOT_DIR)$(PREFIX)/bin/git
GIT_STAMP := $(BUILD_DIR)/git-built

.PHONY: all \
	curl curl-build curl-clean curl-distclean check-curl print-curl \
	dropbear dropbear-build dropbear-clean dropbear-distclean check-dropbear print-dropbear \
	bash bash-build bash-clean bash-distclean check-bash print-bash \
	clean distclean print-root git git-build git-clean git-distclean check-git print-git

all: curl dropbear bash git

BASH_CFLAGS := -std=gnu89 -Wno-implicit-int -Wno-implicit-function-declaration -Wno-old-style-definition -Wno-strict-prototypes

check-bash:
	@test -d "$(BASH_DIR)" || (echo "missing third_party/bash"; exit 1)
	@command -v make >/dev/null || (echo "missing make"; exit 1)
	@command -v cc >/dev/null || (echo "missing C compiler"; exit 1)
	@command -v bison >/dev/null || (echo "missing bison"; exit 1)

bash: check-bash
	@if [ ! -f "$(BASH_BIN)" ]; then \
		rm -f "$(BASH_STAMP)"; \
	fi
	$(MAKE) bash-build

bash-build: $(BASH_STAMP)

check-git:
	@test -d "$(GIT_DIR)" || (echo "missing third_party/git"; exit 1)
	@command -v make >/dev/null || (echo "missing make"; exit 1)
	@command -v cc >/dev/null || (echo "missing C compiler"; exit 1)
	@command -v pkg-config >/dev/null || (echo "missing pkg-config"; exit 1)
	@command -v autoconf >/dev/null || (echo "missing autoconf"; exit 1)

git: check-git
	@if [ ! -f "$(GIT_BIN)" ]; then \
		rm -f "$(GIT_STAMP)"; \
	fi
	$(MAKE) git-build

git-build: $(GIT_STAMP)

$(GIT_STAMP):
	mkdir -p $(ROOT_DIR)
	mkdir -p $(ROOT_DIR)$(PREFIX)/bin
	mkdir -p $(ROOT_DIR)$(PREFIX)/libexec/git-core

	cd $(GIT_DIR) && $(MAKE) clean || true

	cd $(GIT_DIR) && $(MAKE) configure
	cd $(GIT_DIR) && ./configure \
		--prefix=$(PREFIX) \
		--without-tcltk \
		--without-iconv \
		--without-gettext

	$(MAKE) -C $(GIT_DIR) -j$(JOBS) \
		NO_GETTEXT=YesPlease \
		NO_TCLTK=YesPlease \
		NO_PERL=YesPlease \
		NO_PYTHON=YesPlease \
		NO_EXPAT= \
		NO_CURL=

	$(MAKE) -C $(GIT_DIR) DESTDIR="$$(realpath $(ROOT_DIR))" install \
		NO_GETTEXT=YesPlease \
		NO_TCLTK=YesPlease \
		NO_PERL=YesPlease \
		NO_PYTHON=YesPlease \
		NO_EXPAT= \
		NO_CURL=

	@test -f "$(GIT_BIN)" || (echo "missing $(GIT_BIN)"; exit 1)

	@mkdir -p $(BUILD_DIR)
	@touch $(GIT_STAMP)

	@echo
	@echo "git binary:"
	@file $(GIT_BIN)
	@echo
	@echo "git version:"
	@LD_LIBRARY_PATH="$(ROOT_DIR)$(PREFIX)/lib" $(GIT_BIN) --version || true
	@echo
	@echo "git dynamic deps:"
	@LD_LIBRARY_PATH="$(ROOT_DIR)$(PREFIX)/lib" ldd $(GIT_BIN) || true

print-git:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "GIT_BIN: $(GIT_BIN)"
	@find $(ROOT_DIR) \( -name 'git' -o -path '*/git-core/*' \) -print 2>/dev/null | sort || true

git-clean:
	@if [ -d "$(GIT_DIR)" ]; then \
		$(MAKE) -C $(GIT_DIR) clean || true; \
	fi
	rm -f $(GIT_STAMP)

git-distclean:
	@if [ -d "$(GIT_DIR)" ]; then \
		$(MAKE) -C $(GIT_DIR) distclean || true; \
	fi
	rm -f $(GIT_STAMP)

$(BASH_STAMP):
	mkdir -p $(ROOT_DIR)
	mkdir -p $(ROOT_DIR)$(PREFIX)/bin

	cd $(BASH_DIR) && $(MAKE) distclean || true

	cd $(BASH_DIR) && CFLAGS="$(BASH_CFLAGS)" ./configure \
		--prefix=$(PREFIX) \
		--without-bash-malloc \
		--enable-readline

	$(MAKE) -C $(BASH_DIR) -j$(JOBS) CFLAGS="$(BASH_CFLAGS)"
	$(MAKE) -C $(BASH_DIR) DESTDIR="$$(realpath $(ROOT_DIR))" install

	@test -f "$(BASH_BIN)" || (echo "missing $(BASH_BIN)"; exit 1)

	@mkdir -p $(BUILD_DIR)
	@touch $(BASH_STAMP)

	@echo
	@echo "bash binary:"
	@file $(BASH_BIN)
	@echo
	@echo "bash version:"
	@LD_LIBRARY_PATH="$(ROOT_DIR)$(PREFIX)/lib" $(BASH_BIN) --version || true
	@echo
	@echo "bash dynamic deps:"
	@ldd $(BASH_BIN) || true

print-bash:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "BASH_BIN: $(BASH_BIN)"
	@find $(ROOT_DIR) \( -name 'bash' -o -name 'bashbug' \) -print 2>/dev/null | sort || true

bash-clean:
	@if [ -d "$(BASH_DIR)" ]; then \
		$(MAKE) -C $(BASH_DIR) clean || true; \
	fi
	rm -f $(BASH_STAMP)

bash-distclean:
	@if [ -d "$(BASH_DIR)" ]; then \
		$(MAKE) -C $(BASH_DIR) distclean || true; \
	fi
	rm -f $(BASH_STAMP)

bash-clean:
	@if [ -d "$(BASH_DIR)" ]; then \
		$(MAKE) -C $(BASH_DIR) clean || true; \
	fi
	rm -f $(BASH_STAMP)

bash-distclean:
	@if [ -d "$(BASH_DIR)" ]; then \
		$(MAKE) -C $(BASH_DIR) distclean || true; \
	fi
	rm -f $(BASH_STAMP)

check-curl:
	@test -d "$(CURL_DIR)" || (echo "missing third_party/curl"; exit 1)
	@command -v autoreconf >/dev/null || (echo "missing autoreconf"; exit 1)
	@command -v make >/dev/null || (echo "missing make"; exit 1)
	@command -v cc >/dev/null || (echo "missing C compiler"; exit 1)
	@command -v perl >/dev/null || (echo "missing perl"; exit 1)
	@command -v pkg-config >/dev/null || (echo "missing pkg-config"; exit 1)

curl: check-curl
	@if [ ! -f "$(CURL_BIN)" ]; then \
		rm -f "$(CURL_STAMP)"; \
	fi
	$(MAKE) curl-build

curl-build: $(CURL_STAMP)

$(CURL_STAMP):
	rm -rf $(ROOT_DIR)
	mkdir -p $(ROOT_DIR)

	cd $(CURL_DIR) && $(MAKE) distclean || true
	cd $(CURL_DIR) && autoreconf -fi

	cd $(CURL_DIR) && ./configure \
		--prefix=$(PREFIX) \
		--enable-shared \
		--disable-static \
		--with-openssl \
		--with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
		--enable-alt-svc \
		--enable-cookies \
		--enable-doh \
		--enable-ipv6 \
		--enable-threaded-resolver \
		--enable-unix-sockets

	$(MAKE) -C $(CURL_DIR) -j$(JOBS)
	$(MAKE) -C $(CURL_DIR) DESTDIR="$$(realpath $(ROOT_DIR))" install

	@test -f "$(CURL_BIN)" || (echo "missing $(CURL_BIN)"; exit 1)

	@mkdir -p $(BUILD_DIR)
	@touch $(CURL_STAMP)

	@echo
	@echo "curl binary:"
	@file $(CURL_BIN)
	@echo
	@echo "curl version/features:"
	@LD_LIBRARY_PATH="$(ROOT_DIR)$(PREFIX)/lib" $(CURL_BIN) --version || true
	@echo
	@echo "curl dynamic deps:"
	@LD_LIBRARY_PATH="$(ROOT_DIR)$(PREFIX)/lib" ldd $(CURL_BIN) || true
	@echo
	@echo "installed libcurl:"
	@find $(ROOT_DIR) -name 'libcurl.so*' -print

check-dropbear:
	@test -d "$(DROPBEAR_DIR)" || (echo "missing third_party/dropbear"; exit 1)
	@command -v autoreconf >/dev/null || (echo "missing autoreconf"; exit 1)
	@command -v make >/dev/null || (echo "missing make"; exit 1)
	@command -v cc >/dev/null || (echo "missing C compiler"; exit 1)

dropbear: check-dropbear
	@if [ ! -f "$(DROPBEAR_BIN)" ]; then \
		rm -f "$(DROPBEAR_STAMP)"; \
	fi
	$(MAKE) dropbear-build

dropbear-build: $(DROPBEAR_STAMP)

$(DROPBEAR_STAMP):
	mkdir -p $(ROOT_DIR)
	mkdir -p $(ROOT_DIR)$(PREFIX)/bin
	mkdir -p $(ROOT_DIR)$(PREFIX)/sbin
	mkdir -p $(ROOT_DIR)/etc/dropbear
	mkdir -p $(ROOT_DIR)/root/.ssh

	cd $(DROPBEAR_DIR) && $(MAKE) distclean || true
	cd $(DROPBEAR_DIR) && autoreconf -fi

	cd $(DROPBEAR_DIR) && ./configure \
		--prefix=$(PREFIX) \
		--sysconfdir=/etc/dropbear \
		--disable-lastlog \
		--disable-utmp \
		--disable-utmpx \
		--disable-wtmp \
		--disable-wtmpx

	$(MAKE) -C $(DROPBEAR_DIR) -j$(JOBS) PROGRAMS="$(DROPBEAR_PROGRAMS)"

	install -m 755 $(DROPBEAR_DIR)/dropbear $(DROPBEAR_BIN)
	install -m 755 $(DROPBEAR_DIR)/dbclient $(DBCLIENT_BIN)
	install -m 755 $(DROPBEAR_DIR)/scp $(SCP_BIN)
	install -m 755 $(DROPBEAR_DIR)/dropbearkey $(DROPBEARKEY_BIN)

	@test -f "$(DROPBEAR_BIN)" || (echo "missing installed $(DROPBEAR_BIN)"; exit 1)
	@test -f "$(DROPBEARKEY_BIN)" || (echo "missing installed $(DROPBEARKEY_BIN)"; exit 1)
	@test -f "$(DBCLIENT_BIN)" || (echo "missing installed $(DBCLIENT_BIN)"; exit 1)
	@test -f "$(SCP_BIN)" || (echo "missing installed $(SCP_BIN)"; exit 1)

	@mkdir -p $(BUILD_DIR)
	@touch $(DROPBEAR_STAMP)

	@echo
	@echo "dropbear binaries:"
	@file $(DROPBEAR_BIN)
	@file $(DBCLIENT_BIN)
	@file $(SCP_BIN)
	@file $(DROPBEARKEY_BIN)
	@echo
	@echo "dropbear dynamic deps:"
	@ldd $(DROPBEAR_BIN) || true

print-curl:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "CURL_BIN: $(CURL_BIN)"
	@find $(ROOT_DIR) -maxdepth 5 \( -type f -o -type l \) 2>/dev/null | sort || true

print-dropbear:
	@echo "ROOT_DIR: $(ROOT_DIR)"
	@echo "DROPBEAR_BIN: $(DROPBEAR_BIN)"
	@echo "DROPBEARKEY_BIN: $(DROPBEARKEY_BIN)"
	@echo "DBCLIENT_BIN: $(DBCLIENT_BIN)"
	@echo "SCP_BIN: $(SCP_BIN)"
	@find $(ROOT_DIR) \( \
		-name 'dropbear' -o \
		-name 'dbclient' -o \
		-name 'scp' -o \
		-name 'dropbearkey' \
	\) -print 2>/dev/null | sort || true

print-root:
	@find $(ROOT_DIR) -maxdepth 6 \( -type f -o -type l \) 2>/dev/null | sort || true

curl-clean:
	@if [ -d "$(CURL_DIR)" ]; then \
		$(MAKE) -C $(CURL_DIR) clean || true; \
	fi
	rm -f $(CURL_STAMP)

curl-distclean:
	@if [ -d "$(CURL_DIR)" ]; then \
		$(MAKE) -C $(CURL_DIR) distclean || true; \
	fi
	rm -f $(CURL_STAMP)

dropbear-clean:
	@if [ -d "$(DROPBEAR_DIR)" ]; then \
		$(MAKE) -C $(DROPBEAR_DIR) clean || true; \
	fi
	rm -f $(DROPBEAR_STAMP)

dropbear-distclean:
	@if [ -d "$(DROPBEAR_DIR)" ]; then \
		$(MAKE) -C $(DROPBEAR_DIR) distclean || true; \
	fi
	rm -f $(DROPBEAR_STAMP)

clean: curl-clean dropbear-clean bash-clean git-clean

distclean: curl-distclean dropbear-distclean bash-distclean git-distclean
	rm -rf $(ROOT_DIR)
