%define	spname		toybox
%define	instdir		/opt/%{spname}
%define	profiled	%{_sysconfdir}/profile.d

Name:		%{spname}-musl-static
Version:	0.8.5
Release:	13%{?dist}
Summary:	%{spname} compiled with musl-static

Group:		System Environment/Shells
License:	BSD
URL:		http://landley.net/%{spname}
#Source0:	http://landley.net/%{spname}/downloads/%{spname}-%{version}.tar.gz
Source0:	https://github.com/landley/%{spname}/archive/%{version}.tar.gz
Source1:	https://raw.githubusercontent.com/ryanwoodsmall/%{spname}-misc/master/scripts/%{spname}_config_script.sh

BuildRequires:	musl-static >= 1.2.2-1
BuildRequires:	gcc
BuildRequires:	make
BuildRequires:	kernel-headers

Obsoletes:	%{spname}

Provides:	%{spname}
Provides:	%{spname}-big
Provides:	%{name}

%description

Toybox combines common Linux command line utilities together into a single BSD-licensed executable that's simple, small, fast, reasonably standards-compliant, and powerful enough to turn Android into a development environment.


%prep
%setup -q -n %{spname}-%{version}
sed -i.ORIG 's/__has_include.*/0/g' lib/portability.h


%build
bash %{SOURCE1} -$(rpm --eval '%{rhel}') -m
make %{?_smp_mflags} V=1 HOSTCC=musl-gcc CC=musl-gcc LDFLAGS=-static


%install
#make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}%{instdir}
install -p -m 0755 %{spname} %{buildroot}%{instdir}/%{name}
ln -sf %{name} %{buildroot}%{instdir}/%{spname}
ln -sf %{name} %{buildroot}%{instdir}/%{spname}-big
mkdir -p %{buildroot}%{profiled}
echo 'export PATH="${PATH}:%{instdir}"' > %{buildroot}%{profiled}/%{name}.sh


%posttrans
test -e %{instdir}/%{name} || exit 0
for applet in `%{instdir}/%{name}` ; do ln -sf %{instdir}/%{name} %{instdir}/${applet} ; done
exit 0


%preun
test -e %{instdir}/%{name} || exit 0
for applet in `%{instdir}/%{name}` ; do test -e %{instdir}/${applet} && rm -f %{instdir}/${applet} ; done
exit 0


%files
%{instdir}/%{spname}*
%{profiled}/%{name}.sh


%changelog
* Wed May 19 2021 ryan woodsmall
- toybox 0.8.5

* Fri Jan 15 2021 ryan woodsmall <rwoodsmall@gmail.com>
- release bump for musl 1.2.2

* Wed Dec 30 2020 ryan woodsmall <rwoodsmall@gmail.com>
- release bump for musl CVE-2020-28928

* Sun Oct 25 2020 ryan woodsmall <rwoodsmall@gmail.com>
- toybox 0.8.4

* Tue Oct 20 2020 ryan woodsmall <rwoodsmall@gmail.com>
- release bump for config script change
- release bump for musl 1.2.1

* Tue May 12 2020 ryan woodsmall <rwoodsmall@gmail.com>
- toybox 0.8.3

* Sat Oct 26 2019 ryan woodsmall <rwoodsmall@gmail.com>
- release bump for musl 1.1.24

* Sat Oct 19 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.8.2-7
- toybox 0.8.2

* Wed Jul 17 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.8.1-7
- release bump for musl 1.1.23

* Sat Jun  1 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.8.1-6
- toybox 0.8.1

* Thu Apr 11 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.8.0-6
- release bump for musl 1.1.22

* Sun Feb 10 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.8.0-5
- move source url to github
- spec bump

* Sun Feb 10 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.8.0-4
- toybox 0.8.0

* Tue Jan 22 2019 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.8-4
- release bump for musl 1.1.21

* Wed Nov 28 2018 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.8-3
- use github raw url for config script

* Fri Nov  2 2018 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.8-2
- toybox 0.7.8

* Tue Sep 11 2018 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.7-2
- release bump for musl 1.1.20

* Sat Jun 23 2018 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.7-1
- toybox 0.7.7

* Mon Feb 26 2018 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.6-1
- toybox 0.7.6

* Thu Feb 22 2018 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.5-1
- bump release for musl-libc 1.1.19

* Wed Nov  1 2017 ryan woodsmall <rwoodsmall@gmail.com> - 0.7.5-0
- initial spec for static toybox compiled with musl
