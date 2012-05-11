#!/usr/bin/env bash
#
# datadefine.sh        - copy/delete/link data dir.
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
# $Id: datadefine.sh 31 2007-01-10 00:07:16Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/datadefine.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

#####PROGRAM START#####
MakeTempFile
while true; do
# <menu>
$DIALOG $OPTS --help-label $bb_help_button --backtitle "${BACKTITLE}" \
        --begin 2 2 --title " $bb_mnt_menu_title " \
        --cancel-label $bb_return \
        --menu "$bb_menu_input" 0 0 0 \
   	"1)" "$bb_dc_menu_1${BBBURNDIR}" \
	"2)" "$bb_dc_menu_2${BBBURNDIR}" \
	"3)" "$bb_dc_menu_3${BBBURNDIR}" 2>${TMPFILE}
STDOUT=$?       # Return status
EventButtons
ReadAction 
# </menu>
    
    case $action in
	1\))      # Copy Link data
	    $DIALOG --backtitle "${BACKTITLE}" --title " $bb_information " \
	      --msgbox "$bb_dc_explain2b $bb_dc_explain3 $bb_dc_explain4 $bb_dc_explain5" 0 0

	    MakeTempFile
	    $DIALOG --backtitle "${BACKTITLE}" \
	      --title " $bb_dc_menu_1${BBBURNDIR} " --fselect ${HOME}/ 14 48 0 2>${TMPFILE}
	    unset LINK && LINK=$(cat ${TMPFILE})   
	    ln -sf "${LINK}" ${BBBURNDIR}
	    continue
	    ;;
	2\))	# View what's in it
	    if [ $(ls ${BBBURNDIR} | wc -l) == 0 ]; then
                StatusBar "$bb_dc_ch3_4 ${BBBURNDIR}"
                ShowWarn && wait_for_enter
            else
		MakeTempFile 2
	        ls -lhgGL ${BBBURNDIR} > ${TMPFILE_1}
		$DIALOG --backtitle "${BACKTITLE} " --title " $bb_information " \
		  --exit-label $bb_return --tailbox ${TMPFILE_1} 24 70 2>${TMPFILE_2}

	        continue
	    fi
	    ;;
	3\))      # Delete data
	    if [ $(ls ${BBBURNDIR} | wc -l) == 0 ]; then
	      StatusBar "$bb_dc_ch3_4 ${BBBURNDIR}"
	      ShowWarn && wait_for_enter
	    else
	      MakeTempFile
	      ls -lhgGL ${BBBURNDIR} >${TMPFILE}
	      $DIALOG $OPTS --backtitle "${BACKTITLE}" \
		--begin 2 2 --exit-label $bb_return --tailbox ${TMPFILE} 24 70 --and-widget \
		--defaultno --title " $bb_information " --yesno "$bb_dc_ch3_1" 0 0

		if [[ $? -eq 0 ]]; then
		  rm -rf ${BBBURNDIR}/*
		  StatusBar "$bb_dc_ch3_2" 1.4
		else
		  StatusBar "$bb_dc_ch3_3" 1.4
		fi
	    fi
	    ;;
    esac
done

# vim: set ft=sh nowrap nu:
