#!/bin/sh
set -eu

if [ "$#" -lt 2 ]; then
	echo "usage: $0 <rootfs-dir> <file-or-dir> [file-or-dir...]" >&2
	exit 1
fi

ROOT="$1"
shift

COPIED_LIST="$(mktemp)"
trap 'rm -f "$COPIED_LIST"' EXIT INT TERM

already_seen() {
	dst="$1"
	grep -Fxq "$dst" "$COPIED_LIST" 2>/dev/null
}

mark_seen() {
	dst="$1"
	printf '%s\n' "$dst" >> "$COPIED_LIST"
}

copy_one() {
	src="$1"

	[ -e "$src" ] || return 0

	dst="$ROOT$src"
	mkdir -p "$ROOT$(dirname "$src")"

	# If file already exists in initramfs, skip it.
	# This also skips symlinks, because user asked: if exists -> skip.
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		if ! already_seen "$dst"; then
			echo "  skip existing $src"
			mark_seen "$dst"
		fi
		return 0
	fi

	if already_seen "$dst"; then
		return 0
	fi

	# Always dereference source symlinks when copying new files.
	real="$(readlink -f "$src" 2>/dev/null || true)"

	if [ -n "$real" ] && [ -e "$real" ]; then
		cp -L "$real" "$dst"
	else
		cp -L "$src" "$dst"
	fi

	mark_seen "$dst"
	echo "  copy $src"
}

is_elf() {
	file "$1" 2>/dev/null | grep -q 'ELF'
}

copy_interp() {
	bin="$1"

	interp="$(file "$bin" 2>/dev/null | sed -n 's/.*interpreter \([^,]*\).*/\1/p')"

	if [ -n "$interp" ] && [ -e "$interp" ]; then
		copy_one "$interp"
	fi
}

copy_ldd() {
	bin="$1"

	ldd "$bin" 2>/dev/null | while read -r line; do
		case "$line" in
			*" => /"*)
				lib="$(printf '%s\n' "$line" | awk '{print $3}')"
				copy_one "$lib"
				;;
			/*)
				lib="$(printf '%s\n' "$line" | awk '{print $1}')"
				copy_one "$lib"
				;;
		esac
	done
}

copy_elf_deps() {
	bin="$1"

	[ -f "$bin" ] || return 0

	dst="$ROOT$bin"

	# If this exact file already exists in initramfs, skip dependency scan too.
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		if ! already_seen "$dst"; then
			echo "skip deps existing: $bin"
			mark_seen "$dst"
		fi
		return 0
	fi

	is_elf "$bin" || return 0

	echo "copy deps: $bin"

	copy_interp "$bin"
	copy_ldd "$bin"
}

scan_path() {
	path="$1"

	if [ -d "$path" ]; then
		find "$path" -type f | while read -r file; do
			copy_elf_deps "$file"
		done
	else
		copy_elf_deps "$path"
	fi
}

for path in "$@"; do
	scan_path "$path"
done

# Runtime libs loaded by glibc/dlopen or needed by git/curl/dropbear/bash.
for lib in \
	/usr/lib/libnss_files.so.2 \
	/usr/lib/libnss_dns.so.2 \
	/usr/lib/libresolv.so.2 \
	/usr/lib/libcrypt.so.2 \
	/usr/lib/libldap.so.2 \
	/usr/lib/liblber.so.2 \
	/usr/lib/libsasl2.so.3 \
	/usr/lib/libkrb5.so.3 \
	/usr/lib/libgssapi_krb5.so.2 \
	/usr/lib/libk5crypto.so.3 \
	/usr/lib/libkrb5support.so.0 \
	/usr/lib/libcom_err.so.2 \
	/usr/lib/libkeyutils.so.1
do
	if [ -e "$lib" ]; then
		copy_one "$lib"
	fi
done

# Extra dependency passes.
# Copied shared libraries may have their own deps.
for pass in 1 2 3; do
	echo "dependency pass $pass"

	find "$ROOT" -type f 2>/dev/null | while read -r copied; do
		rel="/${copied#$ROOT/}"

		if [ -e "$rel" ]; then
			copy_elf_deps "$rel"
		fi
	done
done
