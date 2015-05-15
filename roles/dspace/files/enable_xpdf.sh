#!/bin/bash
#
# enable_xpdf.sh - prepare maven repository to use Xpdf mediafilter
# see DSpace Manual section 6.4.2
#

# exit on error
set -e

# global vars
readonly TEMPDIR=$(/bin/mktemp -d)
readonly WGET=/usr/bin/wget
readonly TAR=/bin/tar
readonly MVN=/usr/bin/mvn
readonly RM=/usr/bin/rm

prepare () {
    local files="http://maven-us.nuxeo.org/nexus/content/groups/public/javax/media/jai_core/1.1.2_01/jai_core-1.1.2_01.jar http://download.java.net/media/jai-imageio/builds/release/1.1/jai_imageio-1_1-lib-linux-i586.tar.gz"
    local file

    cd $TEMPDIR

    for file in $files; do
        $WGET $file
    done
}

install () {
    # first jai_imageio
    $TAR zxf jai_imageio-1_1-lib-linux-i586.tar.gz
    $MVN install:install-file -Dfile=jai_imageio-1_1/lib/jai_imageio.jar -DgroupId=com.sun.media -DartifactId=jai_imageio -Dversion=1.0_01 -Dpackaging=jar -DgeneratePom=true

    # then jai_core
    $MVN install:install-file -Dfile=jai_core-1.1.2_01.jar -DgroupId=javax.media -DartifactId=jai_core -Dversion=1.1.2_01 -Dpackaging=jar -DgeneratePom=true

    echo "Configured on: `date`" > ~/.m2/xpdf_configured
}

cleanup () {
    $RM -rf $TEMPDIR
}

prepare && install
cleanup

# vim: set ts=4 sw=4:
