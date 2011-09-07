# $Revision: 1.21 $, $Date: 2005/12/26 20:22:24 $
#
Summary:	IRC transport module for Jabber
Summary(pl):	Moduł transportowy IRC dla systemu Jabber
Name:		jjigw
Version:	VERSION_STR
Release:	2
Epoch:		1
License:	GPL
Group:		Applications/Communications
Source0:	jjigw-%{version}.tar.gz
URL:		http://github.com/Jajcus/jjigw
#Requires:	python-pyxmpp, dnspython26, python26, libxml2-python26
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot

%description
This module allows Jabber to communicate with IRC server.

%description -l pl.UTF-8
Moduł ten umożliwia użytkownikom Jabbera komunikowanie się z
użytkownikami sieci IRC.


%prep
%setup -q

%build
%{__make} \
	prefix=%{_prefix}

%install
rm -rf $RPM_BUILD_ROOT

%{__make} install \
	prefix=%{_prefix} \
	DESTDIR=$RPM_BUILD_ROOT

install -D jjigw.xml.example $RPM_BUILD_ROOT%{_sysconfdir}/jabber/jjigw.xml
install  -D jjigw.init $RPM_BUILD_ROOT/etc/rc.d/init.d/jjigw
install  -D jjigw.sysconfig $RPM_BUILD_ROOT/etc/sysconfig/jjigw
install  -D startjjigw $RPM_BUILD_ROOT/usr/bin
(cd  $RPM_BUILD_ROOT/usr/bin ; rm -f jjigw; ln -s /usr/share/jjigw/jjigw.py jjigw )
sed -i 'sA/usr/etcA/etc/jabberA'   $RPM_BUILD_ROOT/usr/share/jjigw/jjigw.py

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644,root,root,755)
%doc README TODO ChangeLog
%attr(755,root,root) %{_bindir}/*
%doc /usr/share/doc/jjigw/*
%attr(0600,root,root) %config(noreplace) /etc/jabber/jjigw.xml
%attr(755,root,root) /etc/rc.d/init.d/jjigw
/etc/sysconfig/jjigw
%attr(755,root,root) /usr/share/jjigw/*

%define date	%(echo `LC_ALL="C" date +"%a %b %d %Y"`)
%changelog
