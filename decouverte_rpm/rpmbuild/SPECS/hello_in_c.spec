Name:           hello_in_c
Version:        1.0       
Release:        1%{?dist}
Summary:        Un hello world en C

License:        GPL
Source0:        hello_in_c-1.0.tar.gz


%description
Une description. Nous allons construire un hello world en c et livrer l'executable dans /usr/bin

%prep
%setup -q


%build
make %{?_smp_mflags}




%install
%make_install


%clean
rm -rf %{buildroot}

%files
/usr/bin/hello_in_c

%changelog
* Tue Mar 04 2025 Super User
- première version du package C
