Name: hello1-rpm 
Version: 1.0.0 
Release: 1 
Summary: un simple test RPM  
License: GPL    # Ce champ doit être rempli

%description 
Un simple RPM qui affichera le message "Hello World!" au moment de l'installation 

%files 


%pre 

%post
echo "Hello World!" # Affiche le message 

%clean 

%prep 

%build 

%install   


%changelog
# On verra dans le prochain