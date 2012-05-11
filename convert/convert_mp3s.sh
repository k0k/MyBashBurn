#!/usr/bin/env bash
#
# convert_mp3s.sh        - Convert mp3 files to wav.
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
# $Id: convert_mp3s.sh 18 2006-12-20 17:24:06Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/convert_mp3s.lang

cd ${BBBURNDIR}
while read BBMPTHREE; do
	echo
	if ${BB_MP3DEC} -r 44100 -w "${BBMPTHREE%%.mp3}.wav" "${BBMPTHREE}"; then
		echo "${BBMPTHREE}: $bb_conv_mp3_1 (${BBMPTHREE%%.mp3}.wav) $bb_conv_mp3_2"
	else
		echo "${BBMPTHREE}: $bb_conv_mp3_3"
	fi
	echo
done < <(find ${BBBURNDIR} -iname "*[Mm][Pp]3")

sleep 2s
