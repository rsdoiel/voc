# RPM spec file for package
#
# Copyright 2014 David Egan Evans, Magna UT 84044 USA
#
# Permission to use, copy, modify, and distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all
# copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
# OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

%define _prefix /opt/%{name}-%{version}
%define _bindir %{_prefix}/bin
%define _datadir %{_prefix}/share
%define _includedir %{_prefix}/include
%define _libdir %{_prefix}/lib
%define packer %(finger -lp `echo "$USER"` | head -n 1 | cut -d: -f 3)

Name: voc
Summary: Oberon-2 compiler
Version: 1.0
Release: 1
License: GPLv3
Vendor: D. E. Evans <sinuhe@gnu.org>
Packager: %{packer}
Group: Development/Languages
Source: http://oberon.vishap.am/voc/voc-1.0.src.tar.bz2
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-build
BuildArch: i686
BuildRequires: glibc-static, libX11-devel

%description
Vishap's Oberon Compiler (voc) uses a C backend to drive compilation
of Oberon programs under Unix. voc includes libraries from the Ulm
and oo2c Oberon compilers as well as from Ofront, as well as default
libraries complying with the Oakwood Guidelines for Oberon-2 compilers.

%prep
echo Building %{name}-%{version}-%{release}
%setup -q -n %{name}

%build
%{__make} -f makefile.linux.gcc.x86

%install
%{__install} -d %{buildroot}/%{_prefix}/bin
%{__install} -d %{buildroot}/%{_datadir}
%{__install} -d %{buildroot}/%{_datadir}/%{name}
%{__install} -d %{buildroot}/%{_libdir}
%{__install} -d %{buildroot}/%{_libdir}/%{name}
%{__install} -d %{buildroot}/%{_libdir}/%{name}/obj
%{__install} -d %{buildroot}/%{_libdir}/%{name}/sym
%{__install} -d %{buildroot}/etc/ld.so.conf.d
%{__install} -d %{buildroot}/etc/profile.d
cp voc %{buildroot}/%{_bindir}
cp showdef %{buildroot}/%{_bindir}
cp ocat %{buildroot}/%{_bindir}
cp *.so %{buildroot}%{_libdir}
cp *.a %{buildroot}%{_libdir}
cp *.c %{buildroot}/%{_libdir}/%{name}/obj
cp *.h %{buildroot}/%{_libdir}/%{name}/obj
cp *.sym %{buildroot}/%{_libdir}/%{name}/sym
cp -Rp src %{buildroot}%{_prefix}
ln -s %{_prefix} %{buildroot}/opt/%{name}
cp FAQ README.md LICENSE hints quick_start %{buildroot}/%{_datadir}/%{name}
cp 05vishap.conf %{buildroot}/etc/ld.so.conf.d/
echo 'PATH=${PATH}:%{_bindir}' >%{buildroot}/etc/profile.d/%{name}.sh

%post
ldconfig

%postun
%{__rm} -f /etc/profile.d/%{name}.sh
ldconfig

%clean
%{__rm} -Rf %{buildroot}

%files
%defattr(-,root,root)
%{_bindir}/*
%{_datadir}/%{name}/*
%{_libdir}/*
%{_prefix}/src/*
/opt/%{name}
/etc/ld.so.conf.d/
/etc/profile.d/

%changelog
* Tue Sep 9 2014 - D. E. Evans <sinuhe@gnu.org>
- Initial 1.0 release.