#!/usr/bin/env bash
#
# audio_menu.sh		- Ripping/encode script.
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
# $Id: audio_menu.sh 28 2007-01-06 17:05:14Z k0k $

# Read in language file
source ${BBROOTDIR}/lang/${BBLANG}/audio_menu.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

# Function: This function lets you swap cds if you only have one device. {{{1
#-----------------------------------------------------------------------------
#(CDwriter and CDreader is same device.)
function insert_new_CD()
{
        while true; do
                echo $bb_am_enter_2
                read temp
                if [[ "$temp" = "" ]]; then
                        break
                else
                        continue
                fi
        done
}

# Function: Looks for mp3. {{{1
#-----------------------------------------------------------------------------
function check_for_mp3s()
{
	cd ${BBBURNDIR}
	while read MPTHREE; do
        	existing="yes"
	done < <(find ${BBBURNDIR} -iname "*.[Mm][Pp]3" | sort)

	if [[ "$existing" != "yes" ]]; then
        	StatusBar "$bb_am_nomp3s${BBBURNDIR}"
	else
		${BBROOTDIR}/convert/convert_mp3s.sh
	fi
}

# Function: Checks for ogg files. {{{1
#-----------------------------------------------------------------------------
function check_for_oggs()
{
	cd ${BBBURNDIR}
	while read OGGS; do
		existing="yup"
	done < <(find ${BBBURNDIR} -iname "*.[Oo][Gg][Gg]" | sort)

	if [[ "$existing" != "yup" ]]; then
        	StatusBar "$bb_am_nooggs${BBBURNDIR}" 
	else
		${BBROOTDIR}/convert/convert_oggs.sh	
	fi
}

# Function: Checks for flac files. {{{1
#-----------------------------------------------------------------------------
function check_for_flacs()
{
	cd ${BBBURNDIR}
	while read FLACS; do
		existing="aight"
	done < <(find ${BBBURNDIR} -iname "*.[Ff][Ll][Aa][Cc]" | sort)

	if [[ "$existing" != "aight" ]]; then
		StatusBar "$bb_am_noflacs${BBBURNDIR}"
	else
		${BBROOTDIR}/convert/convert_flacs.sh
	fi
}

# Function: Adjust the volume of wav audio files to a standard volume level. {{{1
#-----------------------------------------------------------------------------
function normalization()
{
        if [[ "$BBNORMALIZE" = "yes" ]]; then
                cd ${BBBURNDIR}
                for i in *.wav; do
		   echo;echo -e "${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_norm_1$i...${BBCOLOROFF}";
                   ${BB_NORMCMD} -v -m $i;
                done
        fi
}

# Function: Valide the input of "y" or "n". {{{1
#-----------------------------------------------------------------------------
function conf_yes_no()
{
	unset ANSWER
	while [ "${ANSWER}" != 'y' ] && [ "${ANSWER}" != 'n' ]
	do 
		echo -n $bb_am_conf_2
		read ANSWER
	done

}

# Function: Control errors. {{{1
#-----------------------------------------------------------------------------
function conf_error()
{
	STDERROR=$?
	# If there is any error return to main menu.
	if [[ ${STDERROR} -ne 0 ]]; then
		echo -e "${BBTABLECOLOR}$bb_am_err_1${BBCOLOROFF}"
		sleep 3
		exit
	fi
}	

# Function: Valide confirmation of song names. {{{1
#-----------------------------------------------------------------------------
function confirmation()
{
	echo
	if [[ ! -f "${BBBURNDIR}/song_name.txt" ]]; then
		exit
	else
		echo -e "${BBTABLECOLOR}|>${BBMAINCOLOR}$bb_am_conf_1${BBCOLOROFF}"
		cat -n ${BBBURNDIR}/song_name.txt
		echo -e "${BBSUBCOLOR}"
		conf_yes_no		# Valid input.
		echo -e "${BBCOLOROFF}"
		
		if [[ ${ANSWER} = 'n' ]];
		then
			rm -f ${BBBURNDIR}/song_name.txt
			rm -f ${BBBURNDIR}/tracks.txt
			exit
		fi
	fi
}

# Function: Interactive naming of files. {{{1
#-----------------------------------------------------------------------------
function named()
{
	# Delete old lists of songs rip.
	rm -f ${BBBURNDIR}/*.txt

	# cdda2wav show information of tracks to rip.
	# it's great for see which track would to be 
	# rip and the time of duration of the tracks.
	echo -e "${BBSUBCOLOR}$bb_am_named_1${BBCOLOROFF}"
	sleep 1s
	${BB_CDAUDIORIP} -D ${BBCDROM} -H -J -v toc

	# If there is any error return to main menu.
	conf_error
	
	TRACK=0
	while [ "${TRACK}" != "" ]; do
		echo;echo -en "${BBMAINCOLOR}$bb_am_named_2"
		echo;echo -en "${BBMAINCOLOR}$bb_am_named_3${BBTABLECOLOR}|>${BBCOLOROFF} "
		read TRACK
	
			if [ "${TRACK}" != "" ];
			then
				# Only permit integer numbers standing the format in the numbers of back prompt.
				number_track=`printf '%02d' ${TRACK}`			
	
				# This line puts track numbers of the input standard into tracks.txt.	
				echo "${number_track}" >> ${BBBURNDIR}/tracks.txt
			else
			# If nothing is entered at the prompt then exit loop.
				continue
			fi

		echo
		echo -e "${BBMAINCOLOR}$bb_am_named_4"
		echo -e "${BBMAINCOLOR}$bb_am_named_5"
		echo -en "${BBMAINCOLOR}$bb_am_named_6${number_track} ${BBTABLECOLOR}|>${BBCOLOROFF} "
		read song_name

		# If the song_name variable = space blank then, change  
		# fill that with the number of the track to ripped.
		if [[ "${song_name}" = "" ]]; then 
			song_name=`echo "${number_track}.-Track"` 
		else
		
		# If the song_name variable contained some signs and caracters specials, 
		# that difficulty the naming in bash shell, to be equal to nothing.
		# Read sed man page to see how it work.
		song_name=`echo "$song_name" | sed -e 's/(//g'		\
					-e 's/)//g' -e 's/*//g' 	\
					-e 's/?//g' -e 's/¿//g' 	\
					-e 's/\///g' -e 's/&//g'`
		fi
		# This line puts song name of the input standard into song_name.txt.	
	     	echo ${song_name} >> ${BBBURNDIR}/song_name.txt
done
}     
	
# Function: Rip the tracks or songs selects. {{{1
#-----------------------------------------------------------------------------
function rip()
{
	confirmation
	cd ${BBBURNDIR}
	track=0	
	while [ "${track}" != "" ]; do
	
		# Read the track to rip of the files in temp directory.
		track=`sed -ne '1p' ${BBBURNDIR}/tracks.txt`
		if [[ "${track}" = "" ]]; then
			continue
		else
                   	echo -e "${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_rip_1${track}...${BBCOLOROFF}"
		
			# Begin Rip.	
			 ${BB_CDAUDIORIP} -D ${BBCDROM} -x -t ${track} -O wav ${track} #Changed from cdparanoia to cdda2wav
			sleep 2s
			
			# This two lines add '.wav' to finished of the tracks/song_name variable for rename.
			track=`sed -ne '1p' ${BBBURNDIR}/tracks.txt | sed -e 's/$/.wav/g'`
			song_name=`sed -ne '1p' ${BBBURNDIR}/song_name.txt | sed -e 's/$/.wav/g'`
	
			# Rename the tracks that has been ripped, by the name 
			# get back by users in prompt.
			mv "${track}" "${song_name}"
			
			# Remove the song that has been ripped. 
			sed -e '1d' ${BBBURNDIR}/song_name.txt >> ${BBBURNDIR}/temp_song.txt
			mv ${BBBURNDIR}/temp_song.txt ${BBBURNDIR}/song_name.txt
			sed -e '1d' ${BBBURNDIR}/tracks.txt >> ${BBBURNDIR}/temp_tracks.txt
			mv ${BBBURNDIR}/temp_tracks.txt ${BBBURNDIR}/tracks.txt
		fi
	 done
        # Remove temp files.
	rm -f ${BBBURNDIR}/tracks.txt
	rm -f ${BBBURNDIR}/song_name.txt
	rm -f ${BBBURNDIR}/*.inf
	
	eject ${BBCDROM}
	echo -e "${BBSUBCOLOR}$bb_am_rip_2${BBCOLOROFF}"
	sleep 2s
}     

# Function: Encode Filter Command. {{{1
#-----------------------------------------------------------------------------
function encode_filter()
{
	if [[ "$ENCODEFILTER" != "" ]]; then
                echo -e "${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_encfilt(${ENCODEFILTER})${BBCOLOROFF}"
		`${ENCODEFILTER} ${BBBURNDIR}/*.${format}`
	fi			
}

# Function: Copy an audio cd. {{{1
#-----------------------------------------------------------------------------
function copy_audio_cd()
{
    cd ${BBBURNDIR}
    if ${BB_CDAUDIORIP} -D ${BBCDROM} -v all -B -Owav; then      #Changed from cdparanoia to cdda2wav

	eject ${BBCDROM}
	StatusBar "$bb_am_rip_2"
	# Normalize WAV's.
	normalization 
	
	if [[ ${BBNUMDEV} == 1 ]]; then                     #Check number of devices
	    insert_new_CD
	fi
	
	if eval "${BB_CDBURNCMD} -v dev=${BBCDWRITER} speed=${BBSPEED} \
	    ${BBOPT_ONE:+\"driveropts=$BBOPT_ONE\"} ${BBDTAO} \
	    -useinfo ${BBBURNDIR}/*.[Ww][Aa][Vv]"; then
	    StatusBar "$bb_am_ch3_1"
	    ShowWarn && wait_for_enter
	else
	    StatusBar "$bb_am_ch3_2"
	    ShowWarn && wait_for_enter
	fi
    else
	StatusBar "$bb_am_ch3_3${BBCDROM}"
	ShowWarn && wait_for_enter
    fi
}

# Function: Copy an audio to HD. {{{1
#-----------------------------------------------------------------------------
function copy_cd_to_hd()
{
 MakeTempFile
 cd ${BBBURNDIR}
 ${BB_CDAUDIORIP} -D ${BBCDROM} -v all -B -Owav > ${TMPFILE} 2>&1 &
 $DIALOG --backtitle " ${BACKTITLE} " --title " INFORMATION " \
 --tailbox ${TMPFILE} 24 70

 StatusBar "Eject ${BBCDROM}" 1.5
 eject ${BBCDROM}

 # Normalize WAV's.
 normalization

$DIALOG --backtitle " ${BACKTITLE} " --title " INFORMATION " \
--msgbox "$bb_am_ch4_1${BBBURNDIR}.$bb_am_ch4_2 $bb_am_ch4_3" 0 0
}

# Function: Create Mp3s from Wavs in BURNDIR. {{{1
#-----------------------------------------------------------------------------
function create_mp3s_from_wavs()
{
 cd ${BBBURNDIR}

 while read WAV; do
   if ${BB_MP3ENC} --preset cd "${WAV}" "${WAV%%.wav}.mp3"; then
     StatusBar "${WAV%%.wav}.mp3$bb_am_ch6_1"
   else
     StatusBar "${WAV}:$bb_am_ch6_2"
   fi
     existing="yes"
   done < <(find "${BBBURNDIR}" -iname "*.[Ww][Aa][Vv]" | sort)
    
   if [[ "$existing" != "yes" ]]; then
     StatusBar "$bb_am_ch6_3${BBBURNDIR}"	
   else
     # Encode Filter Command. 
     format=mp3
     encode_filter
   fi
   sleep 2s
   continue
}

# Function: Create Oggs from Wavs in BURNDIR. {{{1
#-----------------------------------------------------------------------------
function create_oggs_from_wavs()
{
    cd ${BBBURNDIR}
    
    while read WAV; do
	echo
	if ${BB_OGGENC} -b ${BBBITRATE} "${WAV}"; then
	    StatusBar "$bb_am_ch7_1"
	else
	    StatusBar "${WAV}:$bb_am_ch6_2"
	fi
	echo
	existing="yes"
    done < <(find "${BBBURNDIR}" -iname "*.[Ww][Aa][Vv]" | sort)
    
    if [ "$existing" != "yes" ]; then
	StatusBar "$bb_am_ch6_3${BBBURNDIR}"
    else
	# Encode Filter Command. 
	format=ogg
	encode_filter
    fi
    sleep 2s
    continue
}

# Function: Create flacs from Wavs in BURNDIR {{{1
#-----------------------------------------------------------------------------
function create_flacs_from_wavs()
{

    cd ${BBBURNDIR}
    
    while read WAV; do
	echo
	if ${BB_FLACCMD} "${WAV}"; then
	    echo $bb_am_ch7_1
	else
	    echo "${WAV}:$bb_am_ch6_2"
	fi
	echo
	existing="yes"
    done < <(find "${BBBURNDIR}" -iname "*.[Ww][Aa][Vv]" | sort)
    
    if [[ "$existing" != "yes" ]]; then
	StatusBar "$bb_am_ch6_3${BBBURNDIR}"
    else
	#Encode Filter command
	format=flac
	encode_filter
    fi
    sleep 2s
    continue
}

# Function: Create Mp3s from an audio cd. {{{1
#-----------------------------------------------------------------------------
function create_mp3s_from_cd()
{
#First, name and rip the tracks
# Give name to the tracks.
    named
    # Rip the tracks in wav audio file.
    rip
    # Normalize WAV's.
    normalization
    #Now create the Mp3s
			
    while read WAV; do
	echo;echo -e "${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_ch9_1${BBCOLOROFF}"
	
	if ${BB_MP3ENC} --preset cd ${WAV} ${WAV%%.wav}.mp3; then
	    StatusBar "${WAV%%.wav}.mp3$bb_am_ch6_1"
	else
	    StatusBar "${WAV}:$bb_am_ch6_2"
	fi
	existing="yes"
    done < <(find "$BURNDIR" -iname "*.[Ww][Aa][Vv]" | sort)
    
    if [[ "$existing" != "yes" ]]; then
	StatusBar "$bb_am_ch6_3${BBBURNDIR}" 2
	continue
    else
	# Encode Filter Command. 
	format=mp3
	encode_filter
    fi
    
    StatusBar "$bb_am_ch9_2${BBBURNDIR}"
    ShowWarn && rm ${BBBURNDIR}/*.[Ww][Aa][Vv]
    wait_for_enter
}

# Function: Create Oggs from an audio cd. {{{1
#-----------------------------------------------------------------------------
function create_oggs_from_cd()
{
#First, name and rip the tracks
# Give name to the tracks.
    named
# Rip the tracks in wav audio file.
    rip
# Normalize WAV's.
    normalization
    
#Now create the Oggs.
    
    while read WAV; do
	echo;echo -e "${BBTABLECOLOR}|>${BBSUBCOLOR}$bb_am_ch10_1${BBCOLOROFF}"
	if ${BB_OGGENC} -b ${BBBITRATE} "${WAV}"; then
	    echo $bb_am_ch7_1
	else
	    echo "${WAV}:$bb_am_ch6_2"
	fi
	echo
	existing="yes"
    done < <(find "${BBBURNDIR}" -iname "*.[Ww][Aa][Vv]" | sort)
    
    if [[ "$existing" != "yes" ]]; then
	StatusBar "$bb_am_ch6_3${BBBURNDIR}" 2
	continue
    else
	# Encode Filter Command. 
	format=ogg
	encode_filter	
    fi
    
    echo "$bb_am_ch10_2${BBBURNDIR}"
    rm ${BBBURNDIR}/*.[Ww][Aa][Vv]
    wait_for_enter
}

# Function: Create flacs from cd. {{{1
#-----------------------------------------------------------------------------
function create_flacs_from_cd()
{

# Give name to the tracks.
    named
# Rip the tracks in wav audio file.
    rip
# Normalize WAV's.
    normalization
                        
# Now create Flacs
			
    while read WAV; do
	echo
	if ${BB_FLACCMD} "${WAV}"; then
	    echo $bb_am_ch7_1
	else
	    echo "${WAV}:$bb_am_ch6_2"
	fi
	echo
	existing="yes"
    done < <(find "${BBBURNDIR}" -iname "*.[Ww][Aa][Vv]" | sort)
    
    if [[ "$existing" != "yes" ]]; then
	StatusBar "$bb_am_ch6_3${BBBURNDIR}" 2
	continue
    else
	# Function Filter Command. 
	format=flac
	encode_filter	
    fi
    
    echo "$bb_am_ch11_1${BBBURNDIR}"
    rm ${BBBURNDIR}/*.[Ww][Aa][Vv]
    wait_for_enter			
}

# Run: Main part. {{{1
#-----------------------------------------------------------------------------
####PROGRAM START#####
MakeTempFile
while true; do
# <menu>
        $DIALOG $OPTS --help-label "$bb_help_button" \
	  --backtitle "${BACKTITLE}" --begin 2 2 \
	  --title " $bb_am_menu_title " \
          --cancel-label $bb_return \
          --menu "$bb_menu_input" 0 0 0 \
        "1)" "$bb_am_menu_1" \
        "2)" "$bb_am_menu_2" \
        "3)" "$bb_am_menu_3" \
        "4)" "$bb_am_menu_4" \
        "5)" "$bb_am_menu_5" \
        "6)" "$bb_am_menu_6" \
        "7)" "$bb_am_menu_7" \
        "8)" "$bb_am_menu_8" \
        "9)" "$bb_am_menu_9" \
        "10)" "$bb_am_menu_10" \
        "11)" "$bb_am_menu_11" 2> ${TMPFILE}

STDOUT=$?       # Return status
EventButtons
ReadAction
 case $action in
     1\))  # Burn Audio from Mp3s
	 check_for_mp3s                  
	 check_for_oggs			
	 check_for_flacs			
	 ${BBROOTDIR}/burning/burning.sh --audio
	 ;;
     2\)) # Burn Audio Directly
	 ${BBROOTDIR}/burning/burning.sh --pipeline
	 ;;
     3\))	
	 copy_audio_cd
	 ;;
     4\))      
	 copy_cd_to_hd
	 ;;
     5\))	# Burn a xmms playlist
	 if eval ${BBROOTDIR}/misc/xmmsread.sh; then
	     ${BBROOTDIR}/burning/burning.sh --audio
	 else
	     echo $bb_am_ch5
	     wait_for_enter
	 fi
	 ;;
     6\))
	 create_mp3s_from_wavs
	 ;;
     7\))
	 create_oggs_from_wavs
	 ;;
     8\))
	 create_flacs_from_wavs
	 ;;
     9\))
	 create_mp3s_from_cd
	 ;;
     10\))
	 create_oggs_from_cd
	 ;;
     11\))
	 create_flacs_from_cd
	 ;;
 esac
done

# vim: set ft=sh nowrap nu foldmethod=marker:
