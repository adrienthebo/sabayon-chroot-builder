#!/bin/bash

source ./pkgbuild-settings.sh || exit 1

mount -o bind   /dev "${PKGBUILD_ENV_DIR}/dev"
mount -t devpts none "${PKGBUILD_ENV_DIR}/dev/pts"
mount -t tmpfs  none "${PKGBUILD_ENV_DIR}/dev/shm"
mount -t proc   none "${PKGBUILD_ENV_DIR}/proc"
mount -t sysfs  none "${PKGBUILD_ENV_DIR}/sys"
