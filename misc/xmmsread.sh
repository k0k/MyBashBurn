#!/usr/bin/env bash
#
# xmmsread.sh        - Playlist burn.
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
# $Id: xmmsread.sh 28 2007-01-06 17:05:14Z k0k $

# Read in common functions
source ${BBROOTDIR}/misc/commonfunctions.sh

# Read in the language file
source ${BBROOTDIR}/lang/${BBLANG}/xmmsread.lang

####PROGRAM START####
MakeTempFile
StatusBar "$bb_xmms_text1"
$DIALOG --backtitle "${BACKTITLE}" \
  --title " $bb_xmms_text2 " \
  --fselect ${HOME}/ 14 48 0 2>${TMPFILE}
FILE=$(cat ${TMPFILE})

while read files; do
if ${BB_MP3DEC} -w "${files}.wav" "${files}"; then
	echo "'${files}.wav' $bb_xmms_text3"
	mv "$files.wav" "${BBBURNDIR}"
	echo "'${files}.wav' $bb_xmms_text4 '${BBBURNDIR}', $bb_xmms_text5"
else
	echo "'${files}.wav' $bb_xmms_text6" 1>&2
	echo "$bb_xmms_text7" 1>&2
	wait_for_enter
fi
echo
existing="yes"
done < <(grep -s [Mm][Pp]3 "${FILE}" | grep -v EXTINF)

if [[ "$existing" != "yes" ]]; then
  $DIALOG --backtitle "${BACKTITLE}" \
    --title " $bb_information "  \
    --msgbox "$bb_xmms_text8 ('${FILE}') \n$bb_xmms_text9" 0 0
fi

# vim: set ft=sh nowrap nu:
