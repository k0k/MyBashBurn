Summary: Burn data and create songs with interactive dialogs
Name: mybashburn
Version: 1.0.2
Release: 1%{?dist}
Group: Applications/Multimedia
License: GPL
URL: http://mybashburn.sf.net
Source0: http://ufpr.dl.sourceforge.net/sourceforge/mybashburn/%{name}-%{version}.tar.bz2
Requires: /bin/sh
Requires: cdrdao 
Requires: cdrecord
Requires: mkisofs
Requires: dvd+rw-tools
Requires: cdda2wav
Requires: vorbis-tools
Requires: flac
Requires: coreutils
Requires: eject
Requires: dialog >= 1.0
BuildArch: noarch
Buildroot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
MyBashBurn is a fork based on ncurses of the CD burning shell script
called BashBurn for Linux. It can burn bin/cue files, create ogg and
flac files, data, music and multisession CDs, as well as burn and create
ISO files, DVD-images, data DVDs and some other funny options.
MyBashBurn makes use of cdrecord and other back-end applications, so basically
if your writing device works with them, MyBashBurn will work flawlessly.

%prep
%setup -q
%{__sed} -i 's/\r//' {lang/Polish/burning.lang,lang/Polish/multi.lang}

%build 

%install
rm -rf "%{buildroot}"
install -d %{buildroot}%{_bindir}
install -d %{buildroot}%{_datadir}/%{name}
install -d %{buildroot}%{_datadir}/%{name}/config
install -d %{buildroot}%{_datadir}/%{name}/burning
install -d %{buildroot}%{_datadir}/%{name}/lang
install -d %{buildroot}%{_datadir}/%{name}/lang/English
install -d %{buildroot}%{_datadir}/%{name}/lang/Polish
install -d %{buildroot}%{_datadir}/%{name}/lang/Swedish
install -d %{buildroot}%{_datadir}/%{name}/lang/German
install -d %{buildroot}%{_datadir}/%{name}/lang/Czech
install -d %{buildroot}%{_datadir}/%{name}/lang/Spanish
install -d %{buildroot}%{_datadir}/%{name}/lang/Norwegian
install -d %{buildroot}%{_datadir}/%{name}/convert
install -d %{buildroot}%{_datadir}/%{name}/misc
install -d %{buildroot}%{_datadir}/%{name}/menus
install -d %{buildroot}%{_mandir}/man1
install -d %{buildroot}%{_sysconfdir}

# and now, install everything
install -pc -m755 MyBashBurn.sh %{buildroot}%{_datadir}/%{name}/MyBashBurn.sh
install -p man/mybashburn.1.gz %{buildroot}%{_mandir}/man1

cp -pR {etc/,CREDITS,HOWTO} %{buildroot}%{_datadir}/%{name}
cp -pR {lang/,config/,burning/,convert/,misc/,menus/} %{buildroot}%{_datadir}/%{name}
ln -sf ../../usr/share/mybashburn/MyBashBurn.sh %{buildroot}%{_bindir}/mybashburn

%clean
rm -rf "%{buildroot}"

%files
%defattr(-,root,root,-)
%{_datadir}/%{name}/
%{_bindir}/mybashburn
%doc COPYING CREDITS ChangeLog FAQ FILES HOWTO README TODO
%attr(0644,root,root) %{_mandir}/man1/mybashburn.1.gz
%changelog
* Sun Apr 22 2007 Wilmer Jaramillo <wilmer@fedoraproject.org> - 1.0.2-1
- Updated man file.

* Mon Jan 29 2007 Wilmer Jaramillo <wilmer@fedoraproject.org> - 1.0.1-2
- Fixed incoherent version in changelog.
- The following tags went used %%{__install} and %%{__rm}.

* Sun Jan 07 2007 Wilmer Jaramillo <wilmer@fedoraproject.org> - 1.0.1-1
- Better auto detection of devices cdreader.
- Removed Install.sh file by more easy and flexible Makefile.
- Added function against race conditions on temp files.
- Added statusbar feature.
- Changed the old location /usr/local/BashBurn by /usr/share/mybashburn. 
- Now MyBashBurn look for the /etc/mybashburnrc, ~/.mybashburnrc in that order.
- Updated man file.
- Support translate of cancel, exit, and help button on some dialog.
- Added more english and spanish translate.
- Option of change the 'root directory' have been deprecated for some time and will be removed.
- Cleanup functions.

* Sun Dec 10 2006 Wilmer Jaramillo <wilmer@fedoraproject.org> - 1.0-3
- Fixed DOS/Windows-like (CRLF) end-of-line encoding with %%{__sed} tag (#217197).
- Replaced %%{_bindir}/* tag of %%files section by %%{_bindir}/files.
- Cleanup in %%install section.
- Replaced %%config(noreplace) instead %%config.
- A lot de fix in man file.
- Added a new task into TODO file.
- Fixed config file place.

* Sun Dec 10 2006 Wilmer Jaramillo <wilmer@fedoraproject.org> - 1.0-2
- Added %%build section.
- Removed INSTALL in %%doc section.
- Added option for preserve timestamps in install command.
- The directory trailing use is fixed.

* Tue Nov 14 2006 Wilmer Jaramillo <wilmer@fedoraproject.org> - 1.0-1
- Initial release of MyBashBurn
- This use MyBashBurn.sh instead of BashBurn.sh
- Probe of concept for dialog box in some options
- Auto detection of devices CD/DVD RW, driver options, languages and mount point
- Added a 'lock dir' that warning about multiple instances
- Include manual file mybashburn.1.gz (man mybashburn)
- Added mybashburn.spec file
