#!/usr/bin/env bash
#
# mount.sh        - mount/umount device.
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
# $Id: mount.sh 33 2007-01-17 01:25:45Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/mount.lang

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

function mount_device()
{
    grep cdrom /etc/fstab | sort && grep dvd /etc/fstab | sort
    echo; echo $bb_mnt_ch1_1
    echo $bb_mnt_ch1_2
    echo $bb_mnt_ch1_3
    echo $bb_mnt_ch1_4
    echo -n "|> "
    read BBDEVICE
    if [[ "${BBDEVICE}" == "" ]]; then
	echo $bb_mnt_ch1_5
	wait_for_enter
	continue
    else
	echo "$bb_mnt_ch1_6${BBDEVICE}..."
	if mount ${BBDEVICE} &> /dev/null; then
	    echo "${BBDEVICE}$bb_mnt_ch1_7"
	    sleep 2s
	    continue
	else
	    echo $bb_mnt_ch1_8
	    echo $bb_mnt_ch1_9
	    echo $bb_mnt_ch1_10
	    wait_for_enter
	    continue
	fi
    fi
}

function umount_device()
{
    if [ "$(grep -c '\(cdrom\|dvd\|cdrw\|cdwriter\)' /etc/mtab)" == 0 ]; then
	StatusBar "$bb_mnt_ch2_1"
	ShowWarn && wait_for_enter
    else
	grep cdrom /etc/mtab | sort && grep dvd /etc/mtab | sort
	echo; echo $bb_mnt_ch2_2
	echo -n "|> "
	read BBDEVICE
	if umount ${BBDEVICE} &> /dev/null; then
	    echo "${BBDEVICE}$bb_mnt_ch2_3"
	    wait_for_enter
	    continue
	else
	    echo $bb_mnt_ch2_4
	    echo $bb_mnt_ch2_5
	    wait_for_enter
	    continue
	fi
    fi
}

function eject_device()
{
    grep cdrom /etc/fstab | sort && grep dvd /etc/fstab | sort
    echo $bb_mnt_ch3_1
    echo $bb_mnt_ch3_1b
    echo -n "|> "
    read BBDEVICE
    if [[ $BBDEVICE == "" ]]; then
	echo $bb_mnt_ch3_1c
	wait_for_enter
	continue
    else
	if ${BB_EJECT} ${BBDEVICE} &> /dev/null; then
	    echo "${BBDEVICE}$bb_mnt_ch3_2"
	    wait_for_enter
	    continue
	else
	    echo $bb_mnt_ch3_3
	    echo $bb_mnt_ch3_4
	    wait_for_enter
	    continue
	fi
    fi
}

#####PROGRAM START#####
MakeTempFile
while true; do
# <menu>
        $DIALOG $OPTS --help-label $bb_help_button \
	  --backtitle "${BACKTITLE}" --begin 2 2 \
          --title " $bb_mnt_menu_title " \
          --cancel-label $bb_return \
          --menu "$bb_menu_input" 0 0 0 \
        "1)" "$bb_mnt_menu_1" \
        "2)" "$bb_mnt_menu_2" \
        "3)" "$bb_mnt_menu_3" 2>${TMPFILE} 
   
STDOUT=$?       # Return status
EventButtons
ReadAction 

    case $action in
	1\))      # Mount device
	    mount_device
	    ;;
	2\))	# Unmount device
	    umount_device
	    ;;
	3\))	# Eject device
	    eject_device
	    ;;
    esac
done

# vim: set ft=sh nowrap nu:
