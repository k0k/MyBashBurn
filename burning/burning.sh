#!/usr/bin/env bash
#
# burning.sh        - burn baby, burn.
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
# $Id: burning.sh 28 2007-01-06 17:05:14Z k0k $

# Read in the language file
source ${BBROOTDIR}/lang/${BBLANG}/burning.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

########################## SMALL FUNCTIONS ##############################################

# A function to check if overburn is enabled
check_overburn()
{
    if [[ "${BBOVERBURN}" = "yes" ]]; then	# Is overburn enabled?
	BBOBURN="-overburn"		# yes it was
    else
	# No it wasnt
	StatusBar "$bb_no_ob"
	unset BBOBURN			
    fi
}

# A function to see if files in temp dir should be deleted after burning is done
check_tempdel()
{
    if [[ "${BBDELTEMPBURN}" = "yes" ]]; then
	rm -rf "${BBBURNDIR}"/*
	StatusBar "$bb_burning_tmp_1 ${BBBURNDIR} $bb_burning_tmp_1b" 2
    else
	StatusBar "$bb_burning_tmp_1 ${BBBURNDIR} $bb_burning_tmp_2" 2
    fi
}

# A function to see if audio files should be copy protected or not
# NOTE: The files will not be copy protected, but cdrecord will write
# into TOC that files are permitted to be copied or not.
check_copy()
{
    if [[ "${BBCOPY_PROTECT}" = "yes" ]]; then
	BBCOPYING="-nocopy"
    else
	BBCOPYING="-copy"
    fi
}

check_for_wavs()
{
    cd ${BBBURNDIR}
    while read WAVS; do
	existing="affirmative"
    done < <(find ${BBBURNDIR} -iname "*.[Ww][Aa][Vv]" | sort)
}

check_for_mp3s()
{
    cd ${BBBURNDIR}
    while read MP3S; do
	existing="positive"
    done < <(find ${BBBURNDIR} -iname "*.[Mm][Pp]3" | sort)
}

set_session_type()
{
    echo $bb_burning_dvd_1
    echo $bb_burning_dvd_2
    echo $bb_burning_dvd_3
    echo $bb_burning_dvd_4; echo
    echo -n $bb_burning_dvd_5
    read BB_SESSION_ANSWER    
}

################################ AUDIO ###################################################

# a function to burn audio cds.
# it looks for wav-files in the BBBURNDIR (/tmp/burn/)..

audio_burning()
{
    check_for_wavs

    if [[ "$existing" != "affirmative" ]]; then
      $DIALOG --backtitle " ${BACKTITLE} " --title " $bb_information " \
        --msgbox " $bb_burning_audio_2 ${BBBURNDIR}" 0 0
    else
	if [[ "${BBNORMALIZE}" = "yes" ]]; then
	    cd "${BBBURNDIR}"
	    ${BB_NORMCMD} -m *.[Ww][Aa][Vv]
	else
	StatusBar "$bb_burning_audio_3" 1.5
	fi
	
	check_overburn		# Overburn enabled?
	check_copy		# Copy protected?


	check_cd_status		# Check if CD is already written to
	ask_for_blanking
	
	if eval "${BB_CDBURNCMD} dev=${BBCDWRITER} speed=${BBSPEED} ${BBDTAO} ${BBOPT_ONE:+\"driveropts=$BBOPT_ONE\"} \
	    -audio -pad -eject -v ${BBOBURN} ${BBCOPYING} ${BBBURNDIR}/*.[Ww][Aa][Vv]"; then		#Burn audio cd
	    StatusBar "$bb_burning_finish_1"
	    check_tempdel
	    ShowWarn && wait_for_enter
	else
	    StatusBar "$bb_burning_finish_2"
	    ShowWarn && wait_for_enter
	fi
    fi
}

################################# ISO #############################################################

# to burn a .iso-file in the BURNDIR.
iso_burning()
{
    if [ "$(ls -A ${BBBURNDIR})" ]; then
	check_overburn

	# Check for type of image, iso or img supported
	if [[ "$(find ${BBBURNDIR} -iname '*[Ii][Ss][Oo]')" != "" ]]; then
	    IMAGETYPE="[Ii][Ss][Oo]"
	elif [[ "$(find ${BBBURNDIR} -iname '*[Ii][Mm][Gg]')" != "" ]]; then
	    IMAGETYPE="[Ii][Mm][Gg]"
	fi
	
	check_cd_status		# Check if CD is already written to
	ask_for_blanking	# Check if CD blanking should be done

	if eval "${BB_CDBURNCMD} dev=${BBCDWRITER} speed=${BBSPEED} ${BBDTAO} ${BBOPT_ONE:+\"driveropts=$BBOPT_ONE\"} \
	    -eject -v ${BBOBURN} ${BBBURNDIR}/*.$IMAGETYPE"; then
	    StatusBar "$bb_burning_finish_1"
	    check_tempdel
	    wait_for_enter
	else
	    StatusBar "$bb_burning_finish_2 \n$bb_burning_finish_3 ${BBBURNDIR} ?"
	    ShowWarn && wait_for_enter
	fi
    else
	StatusBar "$bb_burning_error $BBBURNDIR"
	ShowWarn && wait_for_enter
    fi
}

############################## DVD Image #########################################################

# Preliminary DVD support. Not very well tested, use at your own risk.
# (However I do believe it should work as planned.)
# Better support will come in time.

dvd_image_burn()
{
 if [ "$(ls -A ${BBBURNDIR})" ]; then
	check_overburn
	
	# Check for type of image, iso or img supported
	if [[ "$(find ${BBBURNDIR} -iname '*[Ii][Ss][Oo]')" != "" ]]; then
	    IMAGETYPE="[Ii][Ss][Oo]"
	elif [[ "$(find ${BBBURNDIR} -iname '*[Ii][Mm][Gg]')" != "" ]]; then
	    IMAGETYPE="[Ii][Mm][Gg]"
	fi

	check_cd_status		# Check if CD is already written to
	
	if eval "${BB_DVDBURNCMD} -dvd-compat -Z ${BBCDWRITER}=${BBBURNDIR}/`ls ${BBBURNDIR} | grep $IMAGETYPE`"; then
	    echo $bb_burning_finish_1
	    check_tempdel
	    wait_for_enter
	else
	    echo $bb_burning_finish_2
	    echo "$bb_burning_finish_3 ${BBBURNDIR} ?"
	    wait_for_enter
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
	wait_for_enter
    fi
}
	

################################### DATA ##########################################################

# This is a function to burn all files in /tmp/burn/ as a data-CD.
# It checks whether folder is empty, and if not creates an ISO from its
# contents and burns it. It does NOT check if the folder contains an ISO
# anymore. If it does, it creates an ISO containing an ISO and burns it.
# This is due to lots of people wanting this functionality. 

data_burning()
{
    if [ "$(ls -A ${BBBURNDIR})" ]; then
        #### i want a question regarding the BBLABEL ####
	if [ "$BBLABEL" = "<ask-me>" ]; then
	    read -p "$bb_burning_data_label" BBLABEL
	fi
	if eval "${BB_ISOCMD} -r -f -v -J -hide-joliet-trans-tbl -copyright \"$BBCOPYRIGHT\" \
		-A \"$BBDESCRIPTION\" -p \"$BBAUTHOR\" -publisher \"$BBPUBLISHER\" \
		-volset \"$BBNAMEOFPACKAGE\" -V \"$BBLABEL\" \
		-o ${BBBURNDIR}/BashBurn.iso ${BBBURNDIR}"; then
	    iso_burning			# call function - declared above
	else
	    echo $bb_burning_data_2
	    echo $bb_burning_data_3
	    wait_for_enter
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
	wait_for_enter
    fi
}

################################### DVD Data #######################################################

# Preliminary DVD support. Not very well tested, use at your own risk.
# (However I do believe it should work as planned.)
# Better support will come in time.

dvd_data_burning()
{
    if [ "$(ls -A ${BBBURNDIR})" ]; then
	if [[ "$BBLABEL" = "<ask-me>" ]]; then
	    read -p "$bb_burning_data_label" BBLABEL
	fi
	
	set_session_type

	if [ "$BB_SESSION_ANSWER" = "yes" ]; then
	    BB_DVDSESSION="-Z"
	elif [ "$BB_SESSION_ANSWER" = "no" ]; then
	    BB_DVDSESSION="-M"
	else
	    exit
	fi

	check_cd_status		# Check if CD is already written to

	if eval "${BB_DVDBURNCMD} ${BB_DVDSESSION} ${BBCDWRITER} -r -f -v -J -hide-joliet-trans-tbl -copyright \"$BBCOPYRIGHT\" \
		-A \"$BBDESCRIPTION\" -p \"$BBAUTHOR\" -publisher \"$BBPUBLISHER\" \
		-volset \"$BBNAMEOFPACKAGE\" -V \"$BBLABEL\" ${BBBURNDIR}"; then
	    echo $bb_burning_finish_1
	    wait_for_enter
	else
	    echo $bb_burning_finish_2
	    wait_for_enter
	fi
    else
	echo "$bb_burning_error $BBBURNDIR"
	wait_for_enter
    fi
}
	    
################################## PIPELINE ########################################################

#A function to do direct audio burning without creating wavs.
pipeline_burning()
{
    check_for_mp3s
    
    if [[ "$existing" != "positive" ]]; then
      $DIALOG --backtitle " ${BACKTITLE} " --title " $bb_information " \
        --msgbox " $bb_burning_audio_2 ${BBBURNDIR}" 0 0
    else
	
#fifo counter set to 0
	COUNTER=0;
	FIFOLST="";
	COMMANDLST="";
	while read FILE; do
	#AAARG...suffixe determination is too ugly !
	    if [[ "$( echo ${FILE} | sed -e 's/.*\.\(...\)$/\1/' | tr '[:lower:]' '[:upper:]'  )"x = "MP3x" ]]; then
		COUNTER=$[ ${COUNTER} + 1 ];
		FIFO="${BBFIFODIR}/FIFO$$-${COUNTER}";
		FIFOLST="${FIFOLST} ${FIFO}";
		COMMANDLST="${COMMANDLST} -audio ${FIFO}";
		mknod ${FIFO} p; #equivalent to mkfifo $FIFO
		
		#Why not to choose between L3dec and mpg123 ?
		#Oh, it's pretty simple, nobody uses the first.
		# l3dec "$FILE" "$FIFO" -sa -ign 2>/dev/null &
		
		exec ${BB_MP3DEC} -qs "${FILE}" 1> "${FIFO}" &
		echo ${COUNTER-MP3} $( echo $(basename "${FILE}") | head -c35 )  flushed into ${FIFO} \(pipe\).
	    elif [[ "$( echo ${FILE} | sed -e 's/.*\.\(...\)$/\1/' | tr '[:lower:]' '[:upper:]'  )"x = "WAVx" ]]; then
		COUNTER=$[ ${COUNTER} + 1 ];
		IFOF="${BBFIFODIR}/FILE$$-${COUNTER}.wav";
		FIFOLST="${FIFOLST} ${IFOF}";
		ln -s "${FILE}" ${IFOF}
		COMMANDLST="${COMMANDLST} -audio ${IFOF}";
		echo ${COUNTER-WAV} $( echo $(basename "${FILE}") | head -c35 ).
	    fi
	done < <(find ${BBBURNDIR} -iname \*[Mm][Pp]3 -o -iname \*]Ww][Aa][Vv])
	
	if [[ "${COUNTER}" = "0" ]]; then
	    StatusBar "$bb_burning_fifo_1 ${BBBURNDIR}"
	    wait_for_enter
	fi
	
	echo "$bb_burning_fifo_2 ${COUNTER} $bb_burning_fifo_2b"

	check_copy		# Check copy protection

	check_cd_status		# Check if CD is already written to
	ask_for_blanking

	${BB_CDBURNCMD} dev=${BBCDWRITER} speed=${BBSPEED} ${BBDTAO} ${BBOPT_DRIVER:+"driver=$BBOPT_DRIVER"} \
	    fs=16m -swab -audio -pad -eject -v ${BBOBURN} ${BBCOPYING} ${COMMANDLST}
	echo $bb_burning_fifo_3
	rm ${FIFOLST}
	check_tempdel
    fi
}
    
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
case "$1" in
    "--audio")
	audio_burning
	;;
    "--data")
	data_burning
	;;
    "--dvddata")
	dvd_data_burning
	;;
    "--dvdimage")
	dvd_image_burn
	;;
    "--iso")
	iso_burning
	;;
    "--pipeline")
	pipeline_burning
	;;
esac

# vim: set ft=sh nowrap nu:
