#!/usr/bin/env bash
#
# apply_options.sh        - Apply changes.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# $Id: apply_options.sh 30 2007-01-06 17:26:49Z k0k $

# Make sure BashBurn knows it is configured.
BBISCONF="1"

BBTEMPFILE=$(tempfile -s .mbb 2> /dev/null) || \
    BBTEMPFILE=$(mktemp -q -t mbb.XXXXXX 2> /dev/null) || \
    { touch /tmp/bbtempfile; BBTEMPFILE="/tmp/bbtempfile"; }
sed -e "s°^BBCDWRITER.*°BBCDWRITER: $BBCDWRITER°"	\
    -e "s°^BBCDROM.*°BBCDROM: $BBCDROM°"	\
    -e "s°^BBCDMNT.*°BBCDMNT: $BBCDMNT°"	\
    -e "s°^BBSPEED.*°BBSPEED: $BBSPEED°"	\
    -e "s°^BBBLANKING.*°BBBLANKING: $BBBLANKING°"	\
    -e "s°^BBNUMDEV.*°BBNUMDEV: $BBNUMDEV°"	\
    -e "s°^BBROOTDIR.*°BBROOTDIR: $BBROOTDIR°"	\
    -e "s°^BBBURNDIR.*°BBBURNDIR: $BBBURNDIR°"	\
    -e "s°^BBLABEL.*°BBLABEL: $BBLABEL°"	\
    -e "s°^BBCOPYRIGHT.*°BBCOPYRIGHT: $BBCOPYRIGHT°"	\
    -e "s°^BBDESCRIPTION.*°BBDESCRIPTION: $BBDESCRIPTION°"	\
    -e "s°^BBAUTHOR.*°BBAUTHOR: $BBAUTHOR°"	\
    -e "s°^BBPUBLISHER.*°BBPUBLISHER: $BBPUBLISHER°"	\
    -e "s°^BBNAMEOFPACKAGE.*°BBNAMEOFPACKAGE: $BBNAMEOFPACKAGE°"	\
    -e "s°^BBNORMALIZE.*°BBNORMALIZE: $BBNORMALIZE°"	\
    -e "s°^BBOPT_ONE.*°BBOPT_ONE: $BBOPT_ONE°"	\
    -e "s°^BBFIFODIR.*°BBFIFODIR: $BBFIFODIR°"	\
    -e "s°^BBDELTEMPBURN.*°BBDELTEMPBURN: $BBDELTEMPBURN°"	\
    -e "s°^BBOVERBURN.*°BBOVERBURN: $BBOVERBURN°"	\
    -e "s°^BBCOPY_PROTECT.*°BBCOPY_PROTECT: $BBCOPY_PROTECT°"	\
    -e "s°^BBBITRATE.*°BBBITRATE: $BBBITRATE°"	\
    -e "s°^BBLANG.*°BBLANG: $BBLANG°"	\
    -e "s°^BBISCONF.*°BBISCONF: $BBISCONF°"	\
    -e "s°^BBDTAO.*°BBDTAO: $BBDTAO°" $BBCONFFILE > ${BBTEMPFILE}
cat ${BBTEMPFILE} > $BBCONFFILE
rm ${BBTEMPFILE}

# vim: set ft=sh nowrap nu:
