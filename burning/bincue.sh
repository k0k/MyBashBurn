#!/usr/bin/env bash
#
# bincue.sh	 - burn bin/cue files.
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
# $Id: bincue.sh 28 2007-01-06 17:05:14Z k0k $

# Read in language file
source ${BBROOTDIR}/lang/${BBLANG}/bincue.lang
# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

####PROGRAM START####

$DIALOG $OPTS --backtitle "${BACKTITLE}" \
  --title " $bb_information " --defaultno \
  --yesno "$bb_bincue_copy_1 ${BBBURNDIR} $bb_bincue_copy_1b \
  \n\n$bb_bincue_copy_2" 0 0
if [[ $? -ne 0 ]]; then
  $DIALOG $OPTS --backtitle "${BACKTITLE}" \
    --title " $bb_information " --msgbox "$bb_bincue_copy_3 ${BBBURNDIR} $bb_bincue_copy_3b" 0 0
else

  check_cd_status		# Check if CD is already written to
  ask_for_blanking

  if eval "${BB_CDIMAGECMD} write --device \"${BBCDWRITER}\" --driver generic-mmc --speed \"${BBSPEED}\" \
    -v 2 --eject \"${BBBURNDIR}\"/`ls \"${BBBURNDIR}\" | grep [Cc][Uu][Ee]`"; then
    echo $bb_bincue_burn_1
    wait_for_enter			# Press enter to return to main
  else
    echo $bb_bincue_burn_2
    wait_for_enter			# Press enter to return to main
  fi

fi
# vim: set ft=sh nowrap nu:
