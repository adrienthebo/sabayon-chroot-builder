#!/bin/bash

export ARCH="amd64"
export MIRROR="http://gentoo.osuosl.org"

GENTOO_BUILD="20140410"


download_stage3() {

    STAGE3="stage3-amd64-${GENTOO_BUILD}.tar.bz2"
    STAGE3_CHECKSUM="stage3-amd64-${GENTOO_BUILD}.tar.bz2.DIGESTS"

    BUILD_URL="${MIRROR}/releases/amd64/autobuilds/current-stage3-amd64"
    STAGE3_URL="${BUILD_URL}/${STAGE3}"
    STAGE3_CHECKSUM_URL="${BUILD_URL}/${STAGE3_CHECKSUM}"

    cd stage3

    echo "------"
    echo "DOWNLOADING STAGE3"


    if [[ -f $STAGE3 ]]; then
        echo "STAGE3 ${STAGE3} ALREADY DOWNLOADED"
    else
        wget $STAGE3_URL
        wget $STAGE3_CHECKSUM_URL
    fi

    echo "EXPECTED DIGESTS"
    sha512sum stage3-$ARCH-$GENTOO_BUILD.tar.bz2
    echo "ACTUAL DIGESTS"
    sed -ne '2p' stage3-$ARCH-$GENTOO_BUILD.tar.bz2.DIGESTS

    echo -n "DIFF: "
    diff <(sha512sum stage3-$ARCH-$GENTOO_BUILD.tar.bz2) <(sed -ne '2p' stage3-$ARCH-$GENTOO_BUILD.tar.bz2.DIGESTS)
    if [ $? -eq 0 ]; then
        echo "OK"
    else
        echo "NOT OK"
        echo "WORLD ON FIRE, RECTIFY THIS SITUATION AND RUN AGAIN."
        exit 1
    fi

    cd ..
}

download_portage_tree() {


    PORTAGE="portage-latest.tar.bz2"
    PORTAGE_URL="${MIRROR}/snapshots/${PORTAGE}"

    cd portage

    echo "------"
    echo "DOWNLOADING PORTAGE TREE"


    if [[ -f $PORTAGE ]]; then
        echo "PORTAGE TREE ${PORTAGE} ALREADY DOWNLOADED"
    else
        wget $PORTAGE_URL
    fi

    cd ..
}

unpack_chroot() {
    echo "------"
    echo "POPULATING CHROOT ${builddir}"
    mkdir -p $builddir
    cd $builddir

    if [[ -d usr ]]; then
        echo "STAGE3 ALREADY UNPACKED"
    else
        echo "UNPACKING STAGE3"
        tar -xjf ../../stage3/$STAGE3
    fi

    if [[ -d usr/portage ]]; then
        echo "PORTAGE ALREADY UNPACKED"
    else
        echo "UNPACKING PORTAGE"
        tar -xjf ../../portage/$PORTAGE -C usr
    fi
    cd $basedir
}

setup_mounts() {
    cd $builddir

    echo "------"
    echo "SETTING UP CHROOT MOUNTS"
    mount -o bind /dev ./dev
    mount -t devpts none ./dev/pts
    mount -t tmpfs none ./dev/shm
    mount -t proc none ./proc
    mount -t sysfs none ./sys

    cd $basedir
}

copy_bootstrapper() {
    cp bootstrap-sabayon.sh $builddir
}

prepare_environment() {
    if ! [[ -n $BASEDIR ]]; then
        echo "BASEDIR is unset, exiting."
    fi
    CHROOT_DIR=${CHROOT_DIR:-$BASEDIR/chroots}
}

chroot_name=$1
shift

basedir=$(dirname $0)
builddir="${basedir}/chroots/${chroot_name}"

download_stage3
download_portage_tree
unpack_chroot
setup_mounts
