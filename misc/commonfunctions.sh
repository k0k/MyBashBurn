#!/usr/bin/env bash
#
# commonfunctions.sh	- Some common functions used in several files.
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
# $Id: commonfunctions.sh 36 2007-05-29 00:59:12Z k0k $

source ${BBROOTDIR}/lang/${BBLANG}/MyBashBurn.lang
source ${BBROOTDIR}/lang/${BBLANG}/commonfunctions.lang
source ${BBROOTDIR}/misc/variables.idx

# Function: Wait for enter to be pressed {{{1
#-----------------------------------------------------------------------------
function wait_for_enter()
{
 echo ${bb_press_enter}
 read -s
}

# Function: Force quit {{{1
#-----------------------------------------------------------------------------

function force_quit()
{
 $DIALOG --backtitle "$BACKTITLE" --title " $bb_information " \
   --defaultno --yesno "$bb_cf_exit" 0 0
 if [[ ! $? -ne 0 ]]; then
   PidRemove
   CleanTempFile
   StatusBar "$bb_cf_bye"
   echo -e "${BBMAINCOLOR}${bb_quit1}${BBHEADCOLOR}${BBVERSION}"
   echo -e "${BBMAINCOLOR}${bb_quit2}${BBSUBCOLOR}${bb_quit3}${BBMAINCOLOR}${bb_quit4}${BBCOLOROFF}"
   exit 0
 fi
}

# Function: Check cd status (To check wheter CD is blank or not) {{{1
#-----------------------------------------------------------------------------
function check_cd_status()
{
 if eval 'dd if=${BBCDWRITER} of=/dev/null bs=1 count=1 &> /dev/null' ; then
   BB_CDSTATUS="USED"
 else
   BB_CDSTATUS="BLANK"
 fi
}

# Function: To blank CD
#-----------------------------------------------------------------------------
function blank_cd()
{
 echo $bb_cdrw_blank1
 if eval "${BB_CDBURNCMD} -v dev=${BBCDWRITER} blank=${BBBLANKING} speed=${BBSPEED}" ;then
   ${DIALOG} ${OPTS} --backtitle "${BACKTITLE}" \
   --title " Blank CDRW " --msgbox "$bb_cdrw_blank2" 8 20
 else
   ${DIALOG} ${OPTS} --backtitle "${BACKTITLE}" --title " Blank CDRW " \
   --sleep 5 --infobox "$bb_cdrw_blank3" 0 0

 if eval "${BB_CDBURNCMD} -v dev=${BBCDWRITER} blank=${BBBLANKING} speed=${BBSPEED} -force"; then  #Forced blanking
   ${DIALOG} ${OPTS} --backtitle "${BACKTITLE}" --title " Blank CDRW " \
   --msgbox "$bb_cdrw_blank4" 10 30
 else
   ${DIALOG} ${OPTS} --backtitle "${BACKTITLE}" --title " Blank CDRW " \
   --msgbox "$bb_cdrw_blank5" 10 30
 fi
 fi
 # continue                                # Back to menu
}

# Function: Ask for blanking
#-----------------------------------------------------------------------------
function ask_for_blanking()
{
 if [ ${BB_CDSTATUS} == "USED" ]; then
   echo $bb_cf_text1
   echo $bb_cf_text2
   echo $bb_cf_text3
   echo -n "(yes/no/abort) |> "
   read choice
   if [ ${choice} == "yes" ]; then
     blank_cd
   elif [ ${choice} == "abort" ]; then
     echo $bb_cf_text4
     wait_for_enter
     exit
   else
     echo $bb_cf_text5
     sleep 3s
   fi
   if [ ${blank_failed} == "TRUE" ]; then
     echo $bb_cf_text6
     wait_for_enter
     exit
   fi
 fi
}

# Function: Events Buttons {{{1
#-----------------------------------------------------------------------------
function EventButtons() # Param: integer
{
 # When Help Button is selected that will show HOWTO file.
 if [[ ${STDOUT} -eq 102 ]]; then
   ${DIALOG} --backtitle " $bb_cf_help " --exit-label $bb_return \
   --title " $bb_cf_howto " --textbox "${BBROOTDIR}/HOWTO" 25 77
   continue
 fi      
 
 # When Exit Button or ESC key is selected that exit and clear screen.
 if [[ ${STDOUT} -eq 1 ]] || [[ ${STDOUT} -eq 255 ]]; then
   if [ "$1" ]; then  # signal become of main menu
     force_quit
   else	# signal become secondary menu
     break
   fi
 fi
 
 # When Save button is selected that apply changes.
 if [[ ${STDOUT} -eq 103 ]]; then
   # Apply changes
   ${BBROOTDIR}/config/apply_options.sh
   source ${BBROOTDIR}/misc/variables.idx
   StatusBar "$bb_conf_apply_1" 2
   break
 fi
}

# Function: Display the status bar {{{1
#-----------------------------------------------------------------------------
function StatusBar() # Param: string integer (message timing) | thanks guys #bash
{
 local message LINE COLS ROWS SIZE BGBAR BBBAR
 message=$1     # display message
 COLS=$(tput cols) # number of columns
 ROWS=$(tput lines) # number of rows
 SIZE=$(( $COLS - 27 )) # compute the field size
 RSTBAR="$(tput setab 9)" # default background
 BBBAR="$(tput setaf 8)" # white
 BGBAR="$(tput setab 2)" # blue background
 BBBOLD="$(tput bold)" # bold text

 # Format the status line
 tput cup $ROWS 0 # Move the cursor on lower-left corner
 echo -n "${BGBAR}${BBBAR}${BBBOLD}${LINE}"
 printf " %-${SIZE}s  %-23s " "${message:0:$SIZE}" "${BBVERSION}" 
 echo -n "${RSTBAR}"
 if [ ! "$2" ]; then  # check for timing
   sleep 0.2s
 else
   sleep $2
 fi  
}

# Function: Configure the status warning cursor {{{1
#-----------------------------------------------------------------------------
function ShowWarn() # Param: string integer integer (message rows columns)
{
 local message ROWS SIZE BGBAR FGBAR
 message="$1"
 ROWS="22" # below to menu
 FGBAR="$(tput setaf 8)" # white
 BGBAR="$(tput setab 2)" # blue background
 if [ "$2" ] || [ "$3" ]; then
   tput cup $2 $3
 else
   tput cup $ROWS 0
 fi
   echo -ne "${BGBAR}${FGBAR}$message"
}

# Function: Make temporary filename {{{1
#-----------------------------------------------------------------------------
function MakeTempFile() # Param: integer
{
 local i
 # Multiples temp files
 if [ "$1" ]; then
   for i in $(seq 1 $1)
   do
     eval TMPFILE_$i=$(mktemp -q /tmp/mybashburn.XXXXXXXXXX || tempfile -s .mbb 2> /dev/null)
       if [ $? -ne 0 ]; then 
         StatusBar "$bb_cf_make_temp $bb_cf_text4" 
         exit 1 
       fi
   done 
 else 
   TMPFILE=$(mktemp -q /tmp/mybashburn.XXXXXXXXXX)
   if [ $? -ne 0 ]; then 
     StatusBar "$bb_cf_make_temp $bb_cf_text4" 
     exit 1 
   fi
 fi
}

# Function: Clean temporary files {{{1
#-----------------------------------------------------------------------------
function CleanTempFile()
{
 StatusBar "$bb_cf_clean_temp"
 rm -f /tmp/mybashburn.* >/dev/null 2>&1
}

# Function: Read action of menu {{{1
#-----------------------------------------------------------------------------
function ReadAction()
{
 action=$(cat ${TMPFILE}) 
 if [ $? -ne 0 ]; then 
    StatusBar "$bb_cf_read_temp $bb_cf_text4" 
    exit 1 
 fi 
}

# vim: set ft=sh nowrap nu foldmethod=marker:
