#!/usr/bin/env bash
#
# configure.sh        - Main script for config mybashburn
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
# $Id: configure.sh 39 2008-12-24 02:37:20Z k0k $

# Read in variables
source ${BBROOTDIR}/misc/variables.idx

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

# Filter the secuencie '\t' horizontal tab 
MakeTempFile
sed -e 's/\\t//g' ${BBROOTDIR}/lang/${BBLANG}/configure.lang > ${TMPFILE}
# Read in language
source ${TMPFILE} 


#####PROGRAM START#####
MakeTempFile
while true; do
	# <colors>
        #source "$BBROOTDIR"/misc/colors.idx
	# </colors>
	# <menu>
	$DIALOG $OPTS --backtitle "${BACKTITLE}" \
	--title " $bb_conf_menu_toptext1 " \
	--cancel-label "$bb_conf_menu0" --extra-button \
	--extra-button --extra-label "$bb_conf_save" \
	--menu "$bb_conf_menu_toptext1 / $bb_conf_menu_toptext2 " 0 80 18 \
	"1) $bb_conf_menu1" "$BBCDWRITER" \
	"2) $bb_conf_menu2" "$BBCDROM" \
	"3) $bb_conf_menu3" "$BBCDMNT" \
	"4) $bb_conf_menu4" "$BBSPEED" \
	"5) $bb_conf_menu5" "$BBBLANKING" \
	"6) $bb_conf_menu6" "$BBNUMDEV" \
	"7) $bb_conf_menu7" "$BBROOTDIR" \
	"8) $bb_conf_menu8" "$BBBURNDIR" \
	"9) $bb_conf_menu9" "$BBLABEL" \
	"10) $bb_conf_menu10" "$BBCOPYRIGHT" \
	"11) $bb_conf_menu11" "$BBAUTHOR" \
	"12) $bb_conf_menu12" "$BBPUBLISHER" \
	"13) $bb_conf_menu13" "$BBDESCRIPTION" \
	"14) $bb_conf_menu14" "$BBNAMEOFPACKAGE" \
	"15) $bb_conf_menu15" "$BBNORMALIZE" \
	"16) $bb_conf_menu16" "$BBOPT_ONE" \
	"17) $bb_conf_menu17" "$BBFIFODIR" \
	"18) $bb_conf_menu18" "$BBDELTEMPBURN" \
	"19) $bb_conf_menu19" "$BBOVERBURN" \
	"20) $bb_conf_menu20" "$BBCOPY_PROTECT" \
	"21) $bb_conf_menu21" "$BBBITRATE" \
	"22) $bb_conf_menu22" "$BBLANG" \
	"23) $bb_conf_menu23" "$BBDTAO" \
	"24) $bb_conf_menu25" "" 2>"${TMPFILE}"
STDOUT=$?	# Return status
EventButtons
ReadAction
	# </table>

	case $action in

		"1) $bb_conf_menu1") #Change writer device
		StatusBar "$bb_conf_wait"
		MakeTempFile 4
		
		# Detecting the CDRW-DEVICES with cdrecord.
		$(cdrecord dev=ATA -scanbus >${TMPFILE_1} 2>&1)
		$(cdrecord -scanbus >>${TMPFILE_1} 2>&1) &
		
		# Show output of cdrecord in a textbox.
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu1 " --help-button --help-label "$bb_conf_more" \
		  --tailbox "${TMPFILE_1}" 25 77
		
		# Detecting the CDRW/DVDRW-DEVICES.
		StatusBar "$bb_conf_wait"
                $(awk '/CD|RW|DVD(^[0-9])/' ${TMPFILE_1} | cut -d ")" -f 1- | awk '{print $1}' | sed "s/'//g" | \
                sed "s/^[ ^t]*//" &>"${TMPFILE_2}")
		
		# Fill the variables for devices on menu.
		CDWRITER="${TMPFILE_2}"
		NUM=$(wc -l ${CDWRITER} | awk '{ print $1 }')
		while read line
		do 
		  for i in $(seq 1 ${NUM})
	            do
		      # Dinamically creating variables, simulating array.
		      eval CD_$i=$(sed -ne "${i}p" ${TMPFILE_2})
		    done
		done < "${CDWRITER}"
		
		# Description of DVD/CDR-DEVICES according cdrecord 
		$(awk '/CD|RW|DVD(^[0-9])/' ${TMPFILE_1} | cut -d ")" -f 2- | sed "s/'//g"| \
	  	sed "s/^[ ^t]*//">${TMPFILE_3})

		# Fill the variables for description on menu
		# Next release try this with dinamic variable
		DES1=$(sed -ne '1p' ${TMPFILE_3})
		DES2=$(sed -ne '2p' ${TMPFILE_3})
		DES3=$(sed -ne '3p' ${TMPFILE_3})
		DES4=$(sed -ne '4p' ${TMPFILE_3})
		DES5=$(sed -ne '5p' ${TMPFILE_3})
		DES6=$(sed -ne '6p' ${TMPFILE_3})
		DES7=$(sed -ne '7p' ${TMPFILE_3})
		
		# Show possible cdwriter detect.
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu1 " --help-button --help-label "$bb_conf_more" \
		  --menu "$bb_conf_ch1_1 \n$bb_conf_ch1_2 \n$bb_conf_ch1_3 \n$bb_conf_ch1_4 $bb_conf_ch1_5 /etc/default/cdrecord $bb_conf_ch1_6 \n\nPossible DEVICES: SCSI/IDE" 0 0 0 \
		  "$CD_1" "$DES1" \
		  "$CD_2" "$DES2" \
		  "$CD_3" "$DES3" \
		  "$CD_4" "$DES4" \
		  "$CD_5" "$DES5" \
		  "$CD_6" "$DES6" \
		  "$CD_7" "$DES7" \
		  "$CD_8" "$DES8" 2>"${TMPFILE_4}"
		STDOUT=$?
		
		# Enter manually device if More button is selected.
		if [[ ${STDOUT} -eq 102 ]]; then
	 	  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu2 " \
		    --inputbox "$bb_conf_ch1_7 \n$bb_conf_ch1_8" 0 0 "${BBCDWRITER}" 2>"${TMPFILE_4}"
		  BBCDWRITER=$(cat ${TMPFILE_4})
		else
		  BBCDWRITER=$(cat ${TMPFILE_4})
		fi

		continue 
		;;	

		"2) $bb_conf_menu2") 	#Change reader device file
		  device=$(grep 'cdrom' -l /proc/ide/hd?/driver | cut -d'/' -f4)
		  MakeTempFile
		  cdreader="/dev/${device}"
		  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu2 " --help-button --help-label "$bb_conf_more" \
		    --menu "$bb_conf_ch2_1:" 0 0 0 \
		    "$cdreader" "" 2>${TMPFILE}
		  STDOUT=$?
		
		  # Enter manually cd-reader device file if More is selected.
		   if [[ ${STDOUT} -eq 102 ]]; then
	 	     ${DIALOG} --backtitle "${BACKTITLE}" \
		       --title " $bb_conf_menu2 " \
		       --inputbox "$bb_conf_ch2_3" 0 0 "${BBCDROM}" 2>${TMPFILE}
		     BBCDROM=$(cat ${TMPFILE})
		   else
		     BBCDROM=$(cat ${TMPFILE})
		   fi
		
		continue
		;;

		"3) $bb_conf_menu3") 
		if cat /etc/fstab | grep -E 'cdrom|dvd|cdrw' &> /dev/null; then
		  MakeTempFile 2
		  awk '/cdrom|dvd|cdrw/{ print $2 }' /etc/fstab >${TMPFILE_1}
		  
		  # Creating no more of 3 menues entry obviously.
		  CD1=$(sed -ne '1p' ${TMPFILE_1})
	  	  CD2=$(sed -ne '2p' ${TMPFILE_1})
	  	  CD3=$(sed -ne '3p' ${TMPFILE_1})
		  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu3 " --help-button --help-label $bb_conf_more \
		    --menu "$bb_conf_ch3_1 \n\n$bb_conf_ch3_2" 0 0 0 \
		    "$CD1" "" \
		    "$CD2" "" \
		    "$CD3" "" 2>${TMPFILE_2}
		   STDOUT=$?
		   BBCDMNT=$(cat ${TMPFILE_2})
		   
		   # Enter manually mount point if More is selected.
		   if [[ ${STDOUT} -eq 102 ]]; then
	 	     ${DIALOG} --backtitle "${BACKTITLE}" \
		       --title " $bb_conf_menu3 " \
		       --inputbox "$bb_conf_ch3_1 \n\n$bb_conf_ch3_3" 0 0 "" 2>${TMPFILE_2}
		     BBCDMNT=$(cat ${TMPFILE_2})
		   fi

		else
		  ${DIALOG} --backtitle "${BACKTITLE}" \
                    --title " $bb_conf_menu3 " \
                    --inputbox "$bb_conf_mount $bb_conf_ch3_1 \n\n$bb_conf_ch3_3" 0 0 "${BBCDMNT}" 2>"${TMPFILE_2}"
                  BBCDMNT=$(cat ${TMPFILE_2})
                fi
		
		continue
		;;
		
		"4) $bb_conf_menu4") 	#Change writer speed
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu4 " --trim \
		  --inputbox "$bb_conf_ch4_1 \n$bb_conf_ch4_2 \n$bb_conf_ch4_3 \n$bb_conf_ch4_4 \n$bb_conf_ch4_5 \n$bb_conf_ch4_6 \n\n$bb_conf_ch4_7" 0 0 "${BBSPEED}" 2>"${TMPFILE}"
		BBSPEED=$(cat ${TMPFILE})
		continue
		;;
		
		"5) $bb_conf_menu5") 	#Change type of blanking
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu5 " \
		  --menu "$bb_conf_ch5_1 \n$bb_conf_ch5_2${BBBLANKING}" 0 0 0 \
		  "all"	"$bb_conf_blanking_1" \
		  "disc"	"$bb_conf_blanking_2" \
		  "disk"	"$bb_conf_blanking_3" \
		  "fast"	"$bb_conf_blanking_4" \
		  "minimal"	"$bb_conf_blanking_5" \
		  "track"	"$bb_conf_blanking_6" \
		  "unreserve"	"$bb_conf_blanking_7" \
		  "trtail"	"$bb_conf_blanking_8" \
		  "unclose"	"$bb_conf_blanking_9" \
		  "session"	"$bb_conf_blanking_10" 2>"${TMPFILE}"
		BBBLANKING=$(cat ${TMPFILE})
		continue
		;;

		"6) $bb_conf_menu6") 	#Number of devices
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
  		  --title " $bb_conf_menu6 " \
		  --menu "$bb_conf_ch6_1 \n$bb_conf_ch6_2" 0 0 0 \
		  "1"	"$bb_conf_ch6_device" \
		  "2"	"$bb_conf_ch6_device" 2>"${TMPFILE}"
		BBNUMDEV=$(cat ${TMPFILE})
		continue
		;;
		
		"7) $bb_conf_menu7")	#Change of ROOTDIR. Be careful!
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
 		  --title " $bb_conf_menu7 " --defaultno \
		  --yesno "$bb_conf_ch7_1 \n$bb_conf_ch7_2 \n$bb_conf_ch7_3${BBROOTDIR}$bb_conf_ch7_4 \n$bb_conf_ch5_2${BBROOTDIR} \n\nYou want to continue?" 0 0
		if [[ $? -eq 0 ]]; then
		  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu7 " \
		    --fselect ${BBROOTDIR}/ 14 48 0 2>${TMPFILE}
		  BBROOTDIR=$(cat ${TMPFILE})
		fi
		continue
		;;

		"8) $bb_conf_menu8")	#Change of BBBURNDIR. Default usually ok.
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu8 " --defaultno \
		  --yesno "$bb_conf_ch8_1 \n$bb_conf_ch8_2 \n$bb_conf_ch7_3${BBBURNDIR}$bb_conf_ch7_4 \n$bb_conf_ch5_2${BBBURNDIR} \n\nYou want to continue?" 0 0
		if [[ $? -eq 0 ]]; then
		  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu8 " \
		    --fselect ${BBBURNDIR}/ 14 48 0 2>${TMPFILE}
		  BBBURNDIR=$(cat ${TMPFILE})
		fi
		continue
		;;			

		"9) $bb_conf_menu9") 	#Label of the cd
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu9 " \
		  --inputbox "$bb_conf_ch9_1 \n$bb_conf_ch9_2 \n$bb_conf_ch9_3 \n\n$bb_conf_ch9_5" \
		  0 0 "${BBLABEL}" 2>${TMPFILE}
		BBLABEL=$(cat ${TMPFILE})
		;;					

		"10) $bb_conf_menu10")	#Copyright notice (If any)
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu10 " \
		  --inputbox "$bb_conf_ch10_1" 0 0 \
		  "${BBCOPYRIGHT}" 2>${TMPFILE}
		BBCOPYRIGHT=$(cat ${TMPFILE})
		;;

		"11) $bb_conf_menu11") 	#Author
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu11 " \
		  --inputbox "$bb_conf_ch11_1 \n$bb_conf_ch11_2 \n$bb_conf_ch11_3 \n\n$bb_conf_ch11_5" 0 0 \
		  "${BBAUTHOR}" 2>${TMPFILE}
		BBAUTHOR=$(cat ${TMPFILE})
		;;

		"12) $bb_conf_menu12") 	#Publisher
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
  		  --title " $bb_conf_menu12 " \
		  --inputbox "$bb_conf_ch12_1 \n$bb_conf_ch12_3 \n\n$bb_conf_ch12_5" 0 0 \
		  "${BBPUBLISHER}" 2>${TMPFILE}
		BBPUBLISHER=$(cat ${TMPFILE})
		;;

		"13) $bb_conf_menu13")	#Content description
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu13 " \
		  --inputbox "$bb_conf_ch13_1 \n$bb_conf_ch13_2 \n\n$bb_conf_ch13_4" 0 0 \
		  "${BBDESCRIPTION}" 2>${TMPFILE}
		BBDESCRIPTION=$(cat ${TMPFILE})
		;;

		"14) $bb_conf_menu14")	#Name of package
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu14 " \
		  --inputbox "$bb_conf_ch14_1 \n$bb_conf_ch14_2 \n$bb_conf_ch14_3 \n$bb_conf_ch14_4 \n\n$bb_conf_ch14_6" 0 0 \
		  "${BBNAMEOFPACKAGE}" 2>${TMPFILE}
		BBNAMEOFPACKAGE=$(cat ${TMPFILE})
		;;

		"15) $bb_conf_menu15")	#Use normalize
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu16 " --defaultno \
		  --yesno "$bb_conf_ch15_1 \n$bb_conf_ch15_2 \n$bb_conf_ch15_3 \n$bb_conf_ch15_4${BBNORMALIZE} \n\n$bb_conf_ch15_5" 0 0 
		if [[ $? -ne 0 ]]; then
   		  BBNORMALIZE="no"
		else
   		  BBNORMALIZE="yes"
		fi
		;;
		
		"16) $bb_conf_menu16")	#Driver options
		MakeTempFile 3
		StatusBar "$bb_conf_wait"
		if [ cdrecord dev=${BBCDWRITER} -checkdrive driveropts=help >${TMPFILE_1} 2>&1 ]; then
		  ## if somebody have problem with this ER or want more
		  # verbose please notice and comment until END tag.
		  # Make sure of have BBCDWRITER correctly configured. 
		  # This work at least for my burning devices 
		  ## BEGIN
		  grep -A100 "Driver options:" ${TMPFILE_1} | sed -e '1d' > ${TMPFILE_2}
		  # Number record.
		  NR=$(awk '/Cdrecord-Clone/{print NR}' ${TMPFILE_2})
		  # Eliminate from NR until EOF
		  sed "$NR,/eof/d" ${TMPFILE_2} > ${TMPFILE_1} 2>&1
		  ## END
			
		  # Enter options manually
		  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu16 " --keep-window \
		    --begin 2 2 --tailbox "${TMPFILE_1}" 25 77 \
		    --and-widget --begin 10 30 --title "$bb_conf_menu16" \
		    --inputbox "$bb_conf_ch16_1 \n$bb_conf_ch16_2" 0 0 "${BBOPT_ONE}" 2>${TMPFILE_3}
   		  BBOPT_ONE=$(cat ${TMPFILE_3})
		
		else
		  ${DIALOG} ${OPTS} --backtitle "${BACKTITLE}" --title " $bb_information " \
        	    --msgbox "$bb_conf_ch16_driver" 0 0
		fi
		continue

		;;
		
		"17) $bb_conf_menu17") 	#FIFO dir for direct audio burning
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu17 " --defaultno \
		  --yesno "$bb_conf_ch17_1 \n$bb_conf_ch17_2 \n(${BBFIFODIR}$bb_conf_ch17_5 \
		   \n\n$bb_conf_ch17_continue" 0 0
		if [[ $? -eq 0 ]]; then
		  ${DIALOG} --backtitle "${BACKTITLE}" \
		    --title " $bb_conf_menu17 " \
		    --fselect ${BBFIFODIR} 14 48 0 2>${TMPFILE}
		  BBFIFODIR=$(cat ${TMPFILE})
		fi
		continue

		;;
		
		"18) $bb_conf_menu18") 
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu18 " --defaultno \
		  --yesno "$bb_conf_ch18_1${BBBURNDIR}$bb_conf_ch18_2 \n$bb_conf_ch18_3 $bb_conf_ch18_4 \n\n$bb_conf_ch5_2 $bb_conf_ch18_5${BBDELTEMPBURN}" 0 0
		if [[ $? -ne 0 ]]; then
   		  BBDELTEMPBURN="no"
		else
   		  BBDELTEMPBURN="yes"
		fi
		;;
		
		"19) $bb_conf_menu19") 	# Overburn
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu19 " --defaultno \
		  --yesno "$bb_conf_ch19_1 $bb_conf_ch19_2 $bb_conf_ch19_3 \
		  $bb_conf_ch19_4 $bb_conf_ch5_2${BBOVERBURN}" 0 0 
		if [[ $? -ne 0 ]]; then
   		  BBOVERBURN="no"
		else
   		  BBOVERBURN="yes"
		fi
		;;
		
		"20) $bb_conf_menu20") 	# Audio set Copy Protection 
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu20 " --defaultno \
		  --yesno "$bb_conf_ch20_1 \n$bb_conf_ch20_2 $bb_conf_ch5_2${BBCOPY_PROTECT} \
		   \n\n$bb_conf_ch20_3$bb_conf_ch20_4$bb_conf_ch20_5$bb_conf_ch20_6 $bb_conf_ch20_7" 0 0 
		if [[ $? -ne 0 ]]; then
   		  BBCOPY_PROTECT="no"
		else
   		  BBCOPY_PROTECT="yes"
		fi
		;;
		
		"21) $bb_conf_menu21") 	#BITRATE OPTION
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu21 " \
		  --inputbox "$bb_conf_ch21_1 \n$bb_conf_ch21_2 \n$bb_conf_ch21_3 \n$bb_conf_ch21_4 \
		  \n$bb_conf_ch16_5 \nie. 64, 128, 160, 192, 256. \
		  \n\n$bb_conf_ch21_5$bb_conf_ch5_2${BBBITRATE}" 0 0 \
		  "${BBBITRATE}" 2>${TMPFILE}
		BBBITRATE=$(cat ${TMPFILE})
		;;

		"22) $bb_conf_menu22") # Language Option
		MakeTempFile 3
		OPTION=0
		BBLANGBLANK=${BBLANG}
		ls ${BBROOTDIR}/lang > "${TMPFILE_2}"
# Make a dynamic radiolist option script.
# If in ${BBROOTDIR}/lang there is more folder of language it be will detected.
# Please not reformatted.
cat << EOF >"${TMPFILE_1}"
#!/bin/sh
BBLANG=\$(dialog --backtitle "${BACKTITLE}" --title " $bb_conf_menu22 " \\
--stdout --default-item "${BBLANG}" \\
--radiolist "$bb_conf_ch22_1 \n\n$bb_conf_ch22_2" 0 0 0 \\
EOF
	# For each language/folder in ${BBROOTDIR}/lang do.
	while [[ ${OPTION} != "" ]]; do
  	  OPTION=`sed -ne '1p' ${TMPFILE_2}`
	  # Avoid the last option/RE(sed) in blank.
 	  if [[ ${OPTION} != "" ]]; then
	  # Check lang previously select as default item.
	    if [[ ${OPTION} == ${BBLANG} ]]; then
		LANG=("\"${OPTION}\" \"\" on \\")
		echo ${LANG} >>${TMPFILE_1}
	    else
		LANG=("\"${OPTION}\" \"\" off \\")
		echo ${LANG} >>${TMPFILE_1}
	    fi
		
	  else
		continue
	  fi
	# Remove and next language.
	sed -e '1d' ${TMPFILE_2} >> ${TMPFILE_3}
	mv ${TMPFILE_3} ${TMPFILE_2}
done
cat << EOF2 >>${TMPFILE_1}
)
echo \${BBLANG}
EOF2
		chmod +x ${TMPFILE_1}
		BBLANG=`${TMPFILE_1}`
		
		# If Cancel Button is select restore lang previously select.
		if [[ ${BBLANG} == "" ]]; then
			BBLANG=${BBLANGBLANK}
		fi
		;;

		"23) $bb_conf_menu23") # DAO/TAO
		MakeTempFile
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu23 " \
		  --menu "$bb_conf_ch23_1 \n$bb_conf_ch23_2$bb_conf_ch23_2b$bb_conf_ch23_2c $bb_conf_ch23_3 $bb_conf_ch23_4$bb_conf_ch23_5 \n$bb_conf_ch23_6 \n\n$bb_conf_ch23_7" 0 0 0 \
		  "-tao"	"$bb_conf_ch23_4" \
		  "-sao"	"$bb_conf_ch23_2" 2>${TMPFILE}
		BBDTAO=$(cat ${TMPFILE})
		;;

		"24) $bb_conf_menu25") 	#Apply default values
		${DIALOG} --backtitle "${BACKTITLE}" \
		  --title " $bb_conf_menu25 " --defaultno \
		  --yesno "$bb_conf_ch24_confirm" 0 0 
		DEFAULT="$?"
		[[ "$DEFAULT" -eq 0 ]] && ${BBROOTDIR}/config/reset_options.sh && break
		  if [ $? -eq 0 ]; then
		    ${DIALOG} --backtitle " $bb_conf_menu_toptext1 " \
		      --title " $bb_information " --msgbox "$bb_conf_def_1 \n$bb_conf_def_2" 0 0
		  fi
		;;
 	esac
done

# vim: set ft=sh nowrap nu foldmethod=marker:
