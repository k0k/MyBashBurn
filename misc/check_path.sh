#!/usr/bin/env bash
#
# check_path.sh        - check some required programs.
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
#
# $Id: check_path.sh 28 2007-01-06 17:05:14Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/check_path.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

# Read in vars
source ${BBROOTDIR}/misc/variables.idx

# Some variables
BBBURNING="${BB_CDIMAGECMD} ${BB_CDBURNCMD} ${BB_ISOCMD} ${BB_DVDBURNCMD}"
BBRIPPERS="${BB_CDAUDIORIP} ${BB_READCD}"
BBXCODERS="${BB_MP3ENC} ${BB_OGGENC} ${BB_OGGDEC} ${BB_FLACCMD}"
BBMISC="cut ${BB_EJECT} ${BB_NORMCMD} ${BB_MP3DEC} sed tr"
bb_found_all_apps=0


# Function that check the paths of applications 
# used for BashBurn.
check_path()
{
    for program in $*; do
	
	if which ${program} &> /dev/null; then
	    echo -e "\t ${program} $bb_cp_1 $bb_cp_2 `which ${program}`"
	    (( bb_found_all_apps += 1 )) # Add a one for each app found
	else
	    echo -e "\t ${program} $bb_cp_3 $bb_cp_4"
	fi
    done
    return
}

#####PROGRAM START#####

MakeTempFile
while true; do
	(
	echo "20" ;sleep 1
	echo -e "|>$bb_cp_6" >> ${TMPFILE}
	check_path ${BBBURNING} >> ${TMPFILE}
	echo "XXX";echo "${BBBURNING}"; echo "XXX"

	echo "40" ;sleep 1
	echo -e "|>$bb_cp_7" >> ${TMPFILE}
	check_path ${BBRIPPERS} >> ${TMPFILE}
	echo "XXX";echo "${BBRIPPERS}"; echo "XXX"
	
	echo "60" ; sleep 1
	echo -e "|>$bb_cp_8"	>> ${TMPFILE}
	check_path ${BBXCODERS} >> ${TMPFILE}
	echo "XXX";echo "${BBXCODERS}"; echo "XXX"
	
	echo "80" ; sleep 1
	echo -e "|>$bb_cp_9"	>> ${TMPFILE}
	check_path ${BBMISC} >> ${TMPFILE}
	echo "XXX";echo "${BBMISC}"; echo "XXX"
	echo "100" ;sleep 1
	) | ${DIALOG} ${OPTS} --backtitle "${BACKTITLE}" --title " ${bb_cp_5} " \
	--gauge "$bb_cp_13" 8 40
	break
done
	$DIALOG $OPTS --backtitle "${BACKTITLE}" --title " $bb_information " \
	  --no-shadow --exit-label $bb_return --textbox "${TMPFILE}" 0 0

# Only output this if some apps were not found. We don't want to scare people unless necessary :-)
    if [ $bb_found_all_apps != 16 ]; then
	$DIALOG $OPTS --backtitle "${BACKTITLE}" --title " $bb_cp_5 " \
           --msgbox "$bb_cp_10  $bb_cp_11" 0 0
    fi

# vim: set ft=sh nowrap nu:

