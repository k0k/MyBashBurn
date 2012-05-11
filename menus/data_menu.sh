#!/usr/bin/env bash
#
# data_menu.sh        - burn data.
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
# $Id: data_menu.sh 28 2007-01-06 17:05:14Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/data_menu.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

# Function: Checks number of devices. {{{1
#-----------------------------------------------------------------------------
function dev_check()
{
if [[ "${BBNUMDEV}" == 1 ]]; then
	insert_new_CD
	continue
fi
}

# Function: Lets you swap cds if NUMDEV is set to 1. {{{1
#-----------------------------------------------------------------------------
function insert_new_CD()
{
while true; do
	echo $bb_dm_newcd
	read temp
	if [[ "$temp" = "" ]]; then
		break
	else
		continue
	fi
done
}

# Function: Copy data cd. {{{1
#-----------------------------------------------------------------------------
function copy_data_cd()
{
if [[ ${BBNUMDEV} == 2 ]]; then
    mkfifo BBCDCOPY
    ${BB_READCD} dev=${BBCDROM} f=BBCDCOPY | ${BB_CDBURNCMD} dev=${BBCDWRITER} ${BBDTAO} -v -data -eject BBCDCOPY
    $DIALOG --backtitle "${BACKTITLE}" --title " $bb_information " \
      --msgbox "$bb_dm_ch2_5" 0 0
    rm BBCDCOPY
elif 	$(find ${BBBURNDIR} -iname *iso) =! "" &> /dev/null; then	# Does an ISO file exist?
    $DIALOG --backtitle "${BACKTITLE}" --title " $bb_information " \
      --msgbox "$bb_dm_ch2_2${BBBURNDIR}.$bb_dm_ch2_3 \n$bb_dm_ch2_4"
else
    StatusBar "$bb_dm_cdcopy${BBBURNDIR}..."
    if eval "${BB_READCD} ${BB_READCD_OPTS} dev=$BBCDROM f=\"$BBBURNDIR\"/BashBurn.iso"; then
	insert_new_CD

	check_cd_status
	ask_for_blanking

	${BB_CDBURNCMD} dev=${BBCDWRITER} ${BBDTAO} -v -data -eject "$BBBURNDIR"/BashBurn.iso 
	rm ${BBBURNDIR}/BashBurn.iso
	echo $bb_dm_ch2_5
	wait_for_enter
	break
    else
	echo $bb_dm_cdcopy_err1
	echo $bb_dm_cdcopy_err2
	wait_for_enter
	break
    fi
fi
}

# Function: Run main part. {{{1
#-----------------------------------------------------------------------------
#####PROGRAM START#####
MakeTempFile
while true; do
        # <menu>
        $DIALOG $OPTS --help-label "$bb_help_button" \
	  --backtitle "${BACKTITLE}" \
          --begin 2 2 --title " $bb_dm_menu_title " \
          --cancel-label $bb_return \
          --menu "$bb_menu_input" 0 0 0 \
        "1)" "$bb_dm_menu_1" \
        "2)" "$bb_dm_menu_2" \
        "3)" "$bb_dm_menu_3" 2>${TMPFILE}

STDOUT=$?       # Return status
EventButtons
ReadAction

 case $action in  
                1\))      # Burn data
                        ${BBROOTDIR}/burning/burning.sh --data
                ;;
		2\))	# Copy data cd
			copy_data_cd
		;;
                3\))      # Burn data DVD
	                ${BBROOTDIR}/burning/burning.sh --dvddata
                ;;
        esac
done

# vim: set ft=sh nowrap nu foldmethod=marker:
