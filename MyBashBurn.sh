#!/usr/bin/env bash
#
# MyBashBurn.sh - This is the main shell scripts.
#		  Show the main menu and doing some check.
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
# $Id: MyBashBurn.sh 36 2007-05-29 00:59:12Z k0k $

export BBDECOLINE="+------------------+"
export BBVERSION=" MyBashBurn 1.0.2 "  # Version number
export BBCONFFILE="/etc/mybashburnrc"        # Config global file
export BBCONFHOMEFILE="${HOME}/.mybashburnrc"   # Config user file
export BBROOTDIR="/usr/share/mybashburn" # Where MyBashBurn is installed

BBPROGNAME="mybashburn"
PID="/tmp/mybashburn.lock"
COLS=$(tput cols) # number of columns
ROWS=$(tput lines) # number of rows

# Detect signals as 'CTRL+C', INIT, KILL, call to function force_quit, 
# Show MyBashBurn info and quit.
trap 'force_quit' 1 2 3 15 

# Set shell option
shopt -s nocasematch

# Function: Check dialog program {{{1
#-----------------------------------------------------------------------------
function DialogCheck()
{
 if [[ $(type -t "dialog") ]]; then
   export DIALOG=$(which dialog)
 else
   echo
   echo -n "[ERROR] Dialog program no detect, please "
   echo "install them before of use MyBashBurn."
   echo
   exit 1
 fi
}

# Function: Check rootdir {{{1
#-----------------------------------------------------------------------------
function RootDirCheck()
{
if [[ ! -d "$BBROOTDIR" ]]; then 
  echo -e "Please read the INSTALL file for instrutions."
  exit 1
fi
}

# Function: Check for MyBashBurn settings {{{1
#-----------------------------------------------------------------------------
function SetupCheck()
{
 StatusBar "$bb_setup_check"
 if [[ ${BBISCONF} = 0 ]]; then
   ${DIALOG} --backtitle " $BACKTITLE " --title " $bb_information " \
   --msgbox "$bb_conf_check1 $bb_conf_check2" 0 0
   # Loading setup menu
   StatusBar "$bb_loading $bb_menu_7 ..."
   ${BBROOTDIR}/config/configure.sh
   # And in case we changed any options, read in vars again
   source ${BBROOTDIR}/misc/variables.idx
 fi
}

# Function: Check for burndir (temporary directory) {{{1
#-----------------------------------------------------------------------------
function BurnDirCheck()
{
StatusBar "$bb_checking ${BBBURNDIR} ..."
 if [[ ! -e "${BBBURNDIR}" ]]; then
   StatusBar "$bb_no_temp_dir"
   if mkdir "${BBBURNDIR}"; then
     StatusBar "'${BBBURNDIR}' ${bb_text_1}"
     StatusBar "$bb_text_2"
   else
     StatusBar "${bb_text_3} '${BBBURNDIR}'" 
     StatusBar " $bb_text_4"
     wait_for_enter
   fi
 fi
}

# Function: Template config file {{{1
#-----------------------------------------------------------------------------
ApplyDefault()
{
cat << EOF >"${BBCONFHOMEFILE}"
##############################
## CONFIGFILE OF MYBASHBURN ##
##############################
#
# Top level configuration for the MyBashBurn program
# License: GPL v2 (http://www.gnu.org/licenses/gpl.html)

# Is it configured?
BBISCONF: 0

#########################################
# General:				#
#########################################

# location of cd writer:
BBCDWRITER: <Change me>

# location of cdrom device file:
BBCDROM: <Change me>

# location of cdrom mount point:
BBCDMNT: <Change me>

# the speed of your burner:
BBSPEED: -1

# type of blanking
BBBLANKING: fast

# number of devices
BBNUMDEV: 1

# where MyBashBurn is installed
BBROOTDIR: /usr/share/mybashburn

# where files to be burnt are located
BBBURNDIR: /tmp/burn

# fifo dir for piped burning of audio cds
BBFIFODIR: /tmp

#########################################
# Information of the CD:		#
#########################################
# the following informations are also   
# burnt on every CD. If you want, fill	
# them, but it's not necessary.		

# you copyright:
BBCOPYRIGHT: GPL

# a short description of the content of the CD:
BBDESCRIPTION: Burn with MyBashBurn

# the author - hey, that's you, isn't it?
BBAUTHOR: <Change me>

# the publisher:
BBPUBLISHER: <Change me>

# the name of a package 
# (a package are several CDs belonging to one package -
#  that's important e.g. for distributions)
BBNAMEOFPACKAGE: <Change me>

# label of the cd
BBLABEL: MyBashBurn CD

#################################
# Misc Options 			#
#################################

# use normalize or not. Default is no.
BBNORMALIZE: no

# driver options. For example burnsafe or swabaudio. 
# leave this blank if unsure. default is nothing.
BBOPT_ONE: 

# whether to delete temp files after burn.
# default is no
BBDELTEMPBURN: no

# whether MyBashBurn should support overburn.
# default is no
BBOVERBURN: no

# whether MyBashBurn should indicate that audio data should be copy protected
# default is no
BBCOPY_PROTECT: no

# Set bitrate for encoding
# default 128
BBBITRATE: 128

# The language for MyBashBurn
# default is English
BBLANG: English

# DAO or TAO mode
BBDTAO: -tao

EOF
}

# Function: Read global variables {{{1
#-----------------------------------------------------------------------------
function ReadVar()
{
# export BBROOTDIR="$( cat $BBCONFFILE | grep -v '^#' | grep BBROOTDIR:  | cut -d ":" -f 2- | sed -e "s/^[[:blank:]]//g")"
 source ${BBROOTDIR}/misc/commands.idx
 source ${BBROOTDIR}/misc/variables.idx
 export BBTEMPMOUNTDIR="${BBBURNDIR}/mnt"
 # Read in the language file
 source ${BBROOTDIR}/lang/${BBLANG}/MyBashBurn.lang
 # Read in common functions
 source ${BBROOTDIR}/misc/commonfunctions.sh
 # colors
 source $BBROOTDIR/misc/colors.idx
}

# Function: PID make/check and show warnings if there is anothers instance {{{1
#-----------------------------------------------------------------------------
function PidMake()
{
 StatusBar "$bb_pid_make"
 if ! mkdir ${PID}
   then    # directory exist, but was created successfully
   ${DIALOG} --backtitle "$BBVERSION" \
   --title " $bb_information " --defaultno \
   --yesno "$bb_pid_make_message1 ${PID}, $bb_pid_make_message2\n\n $bb_pid_make_message3" 0 0
   if [[ $? -ne '0'  ]]; then	# if found lockdir exit
     exit 1 # force_quit delete PID, instead to using exit.
   fi
 fi
} 

# Function: PID remove {{{1
#-----------------------------------------------------------------------------
function PidRemove()
{
 StatusBar "$bb_pid_remove"
 rm -fr $PID     # remove lock dir when finishes
}

# Function: Terminal size check {{{1
#-----------------------------------------------------------------------------
function TermCheck()
{
 StatusBar "$bb_term_check_message1" 
 if [ "${COLS}" -lt 80 ] || [ "${ROWS}" -lt 25 ]; then
   StatusBar "$bb_term_check_message2 ${COLS}x${ROWS} $bb_failed"
   exit 1
 fi
}

# Function: Terminal reset {{{1
#-----------------------------------------------------------------------------
function SetTerm() # Thanks Costin Stroie
{
 # Move the cursor on upper-left corner and clear the entire screen
 tput clear
 # Make cursor normal visible
 tput cnorm
 # Exit special mode
 tput rmcup
}

# Function: Load the settings {{{1
#-----------------------------------------------------------------------------
function LoadSettings()
{
 echo -n "Loading ..."
 if [[ -r "${BBCONFFILE}" ]]; then  # search for config admin /etc/mybashburnrc
   ReadVar
 elif [[ -r "${BBCONFHOMEFILE}" ]]; then  # search for config user ~/.mybashburnrc
   BBCONFFILE="${BBCONFHOMEFILE}"
   ReadVar
 else
   ApplyDefault
   BBCONFFILE="${BBCONFHOMEFILE}"
   ReadVar
 fi
}

# Run: The init load function part {{{1
#-----------------------------------------------------------------------------
tput clear # clear term
RootDirCheck
LoadSettings
DialogCheck
TermCheck
PidMake
BurnDirCheck
SetupCheck

# Run: The main menu part {{{1
#-----------------------------------------------------------------------------
MakeTempFile
while true; do
StatusBar "$bb_loading $bb_main_menu ..."
# <menu>
 $DIALOG $OPTS --help-label "$bb_help_button" \
   --backtitle "$BACKTITLE" \
   --begin 2 2 --title " $bb_main_menu " \
   --cancel-label $bb_menu_0 \
   --menu "$bb_menu_input" 0 0 0 \
  "1)" "$bb_menu_1" \
  "2)" "$bb_menu_2" \
  "3)" "$bb_menu_3" \
  "4)" "$bb_menu_4" \
  "5)" "$bb_menu_5" \
  "6)" "$bb_menu_6" \
  "7)" "$bb_menu_7" \
  "8)" "$bb_menu_8 ${BBBURNDIR}" \
  "9)" "$bb_menu_9" \
  "10)" "$bb_menu_10" \
  "11)" "$bb_menu_11" 2>${TMPFILE}
STDOUT=$?	# Return status
EventButtons 0
ReadAction	# Return value $action
# </menu>
case $action in
	1\))	# If you chose audio, do:
		StatusBar "$bb_loading $bb_menu_1 ..."
		${BBROOTDIR}/menus/audio_menu.sh
		continue
		;;
	2\)) 	# If you chose data, do:
		StatusBar "$bb_loading $bb_menu_2 ..."
		${BBROOTDIR}/menus/data_menu.sh
		continue
		;;
	3\))	#If you chose ISO, do:
		StatusBar "$bb_loading $bb_menu_3 ..."
		${BBROOTDIR}/menus/iso_menu.sh 
		continue
		;;
	4\))	#Burn an bin/cue file:
		StatusBar "$bb_loading $bb_menu_4 ..."
		${BBROOTDIR}/burning/bincue.sh
		;;
	5\))	#Multisession - Alrighty then...
		StatusBar "$bb_loading $bb_menu_5 ..."
		${BBROOTDIR}/burning/multi.sh	
		continue
		;;
	6\))	#If you chose to blank a CDRW
		StatusBar "$bb_loading $bb_menu_6 ..."
		check_cd_status

		if [ ${BB_CDSTATUS} == "BLANK" ]; then
		  StatusBar "$bb_cdrw_blank6"
		  ShowWarn && wait_for_enter
		else
		  blank_cd	   
		fi
  		  continue 
		;;
	7\))	# If you choose to configure MyBashBurn:
		StatusBar "$bb_loading $bb_menu_7 ..."
		${BBROOTDIR}/config/configure.sh
		# And in case we changed any options, read in vars again
		source ${BBROOTDIR}/misc/variables.idx
		continue
		;;
	8\))	# Mount/unmount a cd
		StatusBar "$bb_loading $bb_menu_8 ..."
		${BBROOTDIR}/misc/mount.sh
		continue
		;;
	9\))	# Check program's paths of burning, ripped, codecs, etc.
		StatusBar "$bb_loading $bb_menu_9 ..."
		${BBROOTDIR}/misc/check_path.sh
		continue
		;;
	10\))	# Copy/link data to the temporary burn dir
		StatusBar "$bb_loading $bb_menu_10 ..."
		${BBROOTDIR}/misc/datadefine.sh
		continue
		;;
	11\))	# Credits.
		$DIALOG $OPTS --fixed-font --exit-label $bb_return \
		--backtitle " $BACKTITLE " --title " $bb_menu_11 " \
		--textbox "${BBROOTDIR}/CREDITS" 25 77
		;;
	esac
done

# vim: set ft=sh nowrap nu foldmethod=marker:
