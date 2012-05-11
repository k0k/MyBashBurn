#!/usr/bin/env bash
#
# multi.sh        - make/finished a multisession cd.
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
# $Id: multi.sh 38 2007-08-26 19:03:51Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/multi.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

burn_function()
{
    if [ "$BBMULTI" = "-multi" ]; then
	OLD_BB_CDBURNCMD=$BB_CDBURNCMD
	BB_CDBURNCMD="$OLD_BB_CDBURNCMD $BBMULTI"
    fi

    # Burn the created ISO-file
    ${BB_CDBURNCMD} dev="$BBCDWRITER" speed="$BBSPEED" ${BBOPT_ONE:+"driveropts=$BBOPT_ONE"} -eject -v "$BBBURNDIR"/*.[Ii][Ss][Oo]
    echo $bb_multi_burn_5
}

burn_multi()
{

    #Does an ISO-file exist?
    if [[ "$(find ${BBBURNDIR} -iname '*[Ii][Ss][Oo]')" != "" ]]; then
	# Yes it did
	echo $bb_multi_burn_1
	echo $bb_multi_burn_2
	echo $bb_multi_burn_3
	echo $bb_multi_burn_4
	burn_function
	wait_for_enter
    else
	# An ISO did not exist, we attempt to create one
	echo $bb_multi_burn_6
	if [ $BBGET_PREV_SESSION = "0" ];then
	    # First session, no need to get -msinfo data
	    echo; echo $bb_multi_burn_13
	    sleep 2s
	else
	    # Save old mkisofs command
	    OLD_BB_ISOCMD=$BB_ISOCMD
	    BBMSINFODATA=$($BB_CDBURNCMD dev=$BBCDWRITER -msinfo)
	    # echo "BBMSINFODATA: $BBMSINFODATA"
	    # sleep 5s
	    BB_ISOCMD="$OLD_BB_ISOCMD -C \"$BBMSINFODATA\" -M $BBCDWRITER"
	    # echo "BB_ISOCMS: $BB_ISOCMD"
	    # sleep 5s
	fi
	
	echo; echo $bb_multi_burn_14
	#### i want a question regarding the BBLABEL ####
	if [ "$BBLABEL" = "<ask-me>" ]; then
	    read -p "$bb_multi_burn_14b" BBLABEL
	fi
	# Create the ISO
	if eval "$BB_ISOCMD -r -f -v -J -hide-joliet-trans-tbl -copyright \"$BBCOPYRIGHT\" \
		-A \"$BBDESCRIPTION\" -p \"$BBAUTHOR\" -publisher \"$BBPUBLISHER\" \
		-volset \"$BBNAMEOFPACKAGE\" -V \"$BBLABEL\" \
		-o \"$BBBURNDIR\"/MyBashBurn.iso \"$BBBURNDIR\""; then 
	    
	    echo $bb_multi_burn_15
	    burn_function
	    # Restore old mkisofs command
	    if [ "$BB_ISOCMD" != "$OLD_BB_ISOCMD" ]; then
		BB_ISOCMD="$OLD_BB_ISOCMD"
	    fi
	    # Restore old cdrecord command
	    if [ "$BB_CDBURNCMD" != "$OLD_BB_CDBURNCMD" ]; then
		BB_CDBURNCMD="$OLD_BB_CDBURNCMD"
	    fi
	    wait_for_enter
	else
	    # Something went wrong. CD isn't burnt.
	    echo $bb_multi_burn_16
	    echo "$bb_multi_burn_17 ${BBBURNDIR}"
	    echo $bb_multi_burn_18
	    wait_for_enter
	fi
    fi
}


#####PROGRAM START#####
while true; do
MakeTempFile
# <menu>
        $DIALOG $OPTS --backtitle "${BACKTITLE}" \
        --begin 2 2 --title " $bb_multi_menu_title " \
        --cancel-label "$bb_return" \
        --menu "$bb_menu_input" 0 0 0 \
        "1)" "$bb_multi_menu_1" \
        "2)" "$bb_multi_menu_2" \
        "3)" "$bb_multi_menu_3" 2>${TMPFILE}

STDOUT=$?       # Return status
EventButtons
ReadAction

    case $action in
	1\))				# Starting multisession CD, first burn
	    BBMULTI="-multi"		#We need to add this to cdrecord
	    BBGET_PREV_SESSION=0	# first burn there is no previous session data
	    burn_multi			# Call function above
	    break			#Return to main		
	    ;;
	2\))				# Continuing multisession CD
	    BBMULTI="-multi"		#We need to add this to cdrecord
	    BBGET_PREV_SESSION=1	# anytime after first burn we need previous session -msinfo data
	    burn_multi		        #Call function above
	    break			#Return to main		
	    ;;
	3\))				#Finishing multisession
	    BBMULTI=""		        #-multi cannot be added			
	    BBGET_PREV_SESSION=1	# anytime after first burn we need previous session -msinfo data
	    burn_multi		        #Call function above
	    break			#Return to main
	    ;;
    esac
done

# vim: set ft=sh nowrap nu:
