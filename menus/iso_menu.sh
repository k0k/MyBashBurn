#!/usr/bin/env bash
#
# iso_menu.sh        - create iso file.
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
# $Id: iso_menu.sh 27 2007-01-02 16:47:02Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/iso_menu.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

# Function: Check whether ISO files exist. {{{1
#-----------------------------------------------------------------------------
function check_for_iso()
{
	existing="no"
	cd ${BBBURNDIR}
	while read ISOFILES; do
        	existing="yes"
	done < <(find ${BBBURNDIR} -iname "*.[Ii][Ss][Oo]" | sort)
}

# Function: Create iso from dir. {{{1
#-----------------------------------------------------------------------------
function create_iso_from_dir()
{
    if [`ls ${BBBURNDIR}` = ""]; then
	echo "$bb_im_error_files $BBBURNDIR"
	wait_for_enter
    else
	# Does an ISO file exist?
	check_for_iso
	if [ $existing = "no" ]; then
	# Creating ISO from files
	    echo; echo $bb_im_ch2_4
	#### i want a question regarding the BBLABEL ####
	    if [ "$BBLABEL" = "<ask-me>" ]; then
		read -p "$bb_im_ch2_4b" BBLABEL
	    fi
	    
	    if eval "${BB_ISOCMD} -r -f -v -J -hide-joliet-trans-tbl -copyright \"$BBCOPYRIGHT\" \
	    -A \"$BBDESCRIPTION\" -p \"$BBAUTHOR\" -publisher \"$BBPUBLISHER\" \
				-volset \"$BBNAMEOFPACKAGE\" -V \"$BBLABEL\" \
	    -o ${BBBURNDIR}/BashBurn.iso ${BBBURNDIR}"; then
		echo $bb_im_ch2_5
		wait_for_enter
		continue
	    else		#Some error occured
		echo $bb_im_ch2_6
		echo $bb_im_ch2_7
		wait_for_enter
		break
	    fi
	else
	    echo "$bb_im_ch2_1${BBBURNDIR}.$bb_im_ch2_2"
	    echo $bb_im_ch2_3
	    wait_for_enter
	fi
    fi
}

# Function: Create iso from cd. {{{1
#-----------------------------------------------------------------------------
function create_iso_from_cd()
{
	# Does an ISO file exist?
	check_for_iso
	if [ $existing = "no" ]; then
	
	echo "$bb_im_ch3_2${BBCDROM}"
	# Creating ISO using readcd      
	if eval "${BB_READCD} ${BB_READCD_OPTS} dev=${BBCDROM} f=${BBBURNDIR}/BashBurn.iso"; then
	    echo $bb_im_ch2_5
	    wait_for_enter
	else
	    echo $bb_im_ch2_6
	    echo $bb_im_ch2_7
	    wait_for_enter
	    break
	fi
    else
	echo "$bb_im_ch2_1${BBBURNDIR}.$bb_im_ch2_2"
	echo $bb_im_ch2_3
	wait_for_enter
    fi
}
 

# Run: Main part {{{1
#-----------------------------------------------------------------------------
MakeTempFile
####PROGRAM START#####
while true; do
        # <menu>
        $DIALOG $OPTS --help-label "$bb_help_button" \
	  --backtitle "${BACKTITLE}" \
          --begin 2 2 --title " $bb_im_menu_title " \
          --cancel-label $bb_return \
          --menu "$bb_menu_input" 0 0 0 \
        "1)" "$bb_im_menu_1" \
        "2)" "$bb_im_menu_2${BBBURNDIR}" \
        "3)" "$bb_im_menu_3" \
        "4)" "$bb_im_menu_4" 2>${TMPFILE}

STDOUT=$?       # Return status
EventButtons
ReadAction
    
    case $action in
	1\))      # Burn ISO
	    ${BBROOTDIR}/burning/burning.sh --iso
	    ;;
	2\))	#Create ISO from BBBURNDIR
	    create_iso_from_dir
	    ;;
	3\))	# Create ISO from cd
	    create_iso_from_cd
	    ;;
	4\))      # Burn DVD image
	    ${BBROOTDIR}/burning/burning.sh --dvdimage
	    ;;
    esac
done

# vim: set ft=sh nowrap nu foldmethod=marker:
