#!/usr/bin/env bash
#
# convert_oggs.sh        - Ogg decode to wav.
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
# $Id: convert_oggs.sh 18 2006-12-20 17:24:06Z k0k $

# Read in language
source ${BBROOTDIR}/lang/${BBLANG}/convert_oggs.lang

cd ${BBBURNDIR}
${BB_OGGDEC} *[Oo][Gg][Gg]
echo $bb_conv_ogg
sleep 2s
