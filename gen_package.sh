#!/bin/bash

#------------------------------------------------------------------------------#
# Copyright 2002-2015, OpenNebula Project, OpenNebula Systems                  #
#                                                                              #
# Licensed under the Apache License, Version 2.0 (the "License"); you may      #
# not use this file except in compliance with the License. You may obtain      #
# a copy of the License at                                                     #
#                                                                              #
# http://www.apache.org/licenses/LICENSE-2.0                                   #
#                                                                              #
# Unless required by applicable law or agreed to in writing, software          #
# distributed under the License is distributed on an "AS IS" BASIS,            #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     #
# See the License for the specific language governing permissions and          #
# limitations under the License.                                               #
#------------------------------------------------------------------------------#

VERSION=${VERSION:-2.1.0}
MAINTAINER=${MAINTAINER:-OpenNebula Systems <contact@opennebula.systems>}
LICENSE=${LICENSE:-Apache}
VENDOR=${VENDOR:-OpenNebula Systems}
DESC="
OpenNebula Apps is a group of tools for users and administrators of OpenNebula that simplifies and optimizes cloud application management.
"
DESCRIPTION=${DESCRIPTION:-$DESC}
PACKAGE_TYPE=${PACKAGE_TYPE:-deb}
URL=${URL:-https://github.com/OpenNebula/addon-appmarket}
COMPONENT="${1-appmarket}"

PACKAGE_NAME=${PACKAGE_NAME:-appmarket}
INIT_SCRIPT=opennebula-${PACKAGE_NAME}


DEPS="opennebula-common"
RPM_DEPS="$DEPS ruby rubygems ruby-devel gcc libxml2-devel libxslt-devel"
DEB_DEPS="$DEPS ruby ruby-dev make"

case "${COMPONENT}-${PACKAGE_TYPE}" in
"appmarket-rpm")
    DEPS="$RPM_DEPS"
    ;;
"appmarket-deb")
    DEPS="$DEB_DEPS"
    ;;
esac

DEP_STRING=""

for d in $DEPS; do
    DEP_STRING="$DEP_STRING -d $d"
done

SCRIPTS_DIR=${SCRIPTS_DIR:-PWD}

[ $PACKAGE_TYPE = rpm ] && PKGARGS="--rpm-os linux"
NAME="${PACKAGE_NAME}_${VERSION}.${PACKAGE_TYPE}"
rm $NAME

export DESTDIR=$PWD/tmp

if [ "$(id -u)" = "0" ]; then
    FLAGS='-u oneadmin -g oneadmin'
fi

rm -rf $DESTDIR
mkdir $DESTDIR

./install.sh $FLAGS

mkdir -p $DESTDIR/etc/init.d
cp init-scripts/${INIT_SCRIPT}.${PACKAGE_TYPE} $DESTDIR/etc/init.d/${INIT_SCRIPT}

cd tmp

fpm -n "$PACKAGE_NAME" -t "$PACKAGE_TYPE" $PKGARGS -s dir --vendor "$VENDOR" \
    --license "$LICENSE" --description "$DESCRIPTION" --url "$URL" \
    -m "$MAINTAINER" -v "$VERSION" \
    $DEP_STRING \
    -a all -p $SCRIPTS_DIR/$NAME *

echo $NAME
