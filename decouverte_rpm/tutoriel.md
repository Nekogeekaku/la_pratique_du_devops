# créer un package rpm avec rpmbuild
## Introduction

rpm est un package manager linux développé initialement par Red Hat et utilisé par de nombreux autres systèmes linux comme indiqué sur [Wikipédia](https://fr.wikipedia.org/wiki/RPM_Package_Manager)

Si généralement il est utilisé par les ingénieurs systèmes et les développeurs pour installer des logiciels additionnels au noyau, il est néanmoins tout à fait possible, justement, de créer ses propres packages.

Je vous propose au travers de cette découverte d'apprendre à construire quelques packages en commençant bien sûr par notre fameux `Hello world`

## setup de base
Les outils[^1] nécessaires pour construire des packages rpm sont évidemment disponibles sous rpm. Dans notre afin d'éviter l'installation d'une machine Red Hat, je vous propose de construire un container docker.

Créons donc un simple Docker file hébergeant les outils nécessaires.
```Dockerfile
FROM fedora:41

RUN dnf install -y gcc rpm-build rpm-devel rpmlint make python bash coreutils diffutils patch rpmdevtools git
```

Il ne vous reste plus qu'à construire ladite image.
```bash
docker build -t my-rpmbuilder:latest .
```
Vous noterez l'existence d'une structure rpmbuild dans notre projet. Cette structure peut être construite avec la commande `rpmdev-setuptree`.

Dans le cas présent elle contient tous les exemples que nous utiliserons au fur et à mesure.


# Construisons le premier exemple : un hello world

## Construction de l'exemple

```bash
docker run -it --rm --name my-rpm-project -v "$(pwd)":/root -w /root my-rpmbuilder:latest /bin/bash

bash-5.2# cd rpmbuild/SPECS
bash-5.2# rpmbuild -bb hello1.spec
bash-5.2# exit
exit
```
Vous devriez trouver un package rpm dans votre répertoire `rpmbuild/RPMS/x86_64`

## exécutons l'exemple

```bash
docker run -it --rm --name my-test-rpm-project -v "$(pwd)"/rpmbuild/RPMS/x86_64:/root -w /root my-rpmbuilder:latest /bin/bash
bash-5.2# rpm -i hello1-rpm-1.0.0-1.x86_64.rpm 
Hello World!
bash-5.2# exit
exit
```

Pour comprendre un peu plus ce que nous avons fait je vous propose d'ouvrir le fichier `hello1.spec`
Il est constitué d’un entête : 
```
Name: hello1-rpm 
Version: 1.0.0 
Release: 1 
Summary: A simple test RPM  
License: GPL    # Modify if necessary, but license is needed
```
Qui servira entre autres au nommage du fichier et au suivi des installations.

On trouvera ensuite tout une série de mots clés commençant par des `%` qui correspondront à différentes étapes de la construction et du déploiement. On appelle ces mots clés des `directives`.
- `%build` servira par exemple à compiler votre application
- `%post` lui sera appelé lorsque l'installation est terminée.

C'est donc pour cela que notre exemple `hello world` ne contient de significatif que la ligne :
```
%post
echo "Hello World!" # Display the message 
``` 

# Un peu de théorie sur la programmation avant de continuer

Avant de poursuivre je vous propose d'aborder un aspect de la programmation.

Il existe différents types de `code` : le code natif et le code interprété.

Dans le cas du `code natif`, il s'agit de code qui au travers d'un compilateur sera transformé en langage directement compréhensible par la machine sur laquelle il s'exécute.   
Si cette manière de construire donne les programmes les plus rapides, elle a pour inconvénient que le code compilé ne peut être exécuté que sur le même type de machine que celui qui a servi à la compilation.   
En termes de type il faudra prendre en compte aussi bien l'architecture du noyau que le système d'exploitation ainsi un Windows 32 bits et un Windows 64 diffèrent, de même qu'un mac Intel ou un mac M1 ou encore tout simplement un Windows et un linux.  
Dans les codes natifs nous trouverons le C et le C++.

Le cas du `code interprété` regroupe les langages les plus récents. Pour simplifier, nous dirons que le développeur écrit son code qui est directement compris par la machine grâce à un interpréteur de manière dynamique.   
Si l'interprétation fait perdre de la vitesse, on gagne en portabilité puisque l'on peut généralement s'affranchir du type de la machine.  
Certains éditeurs de langage ont voulu créer un intermédiaire pour gagner en rapidité tout en conservant la portabilité. Dans ce cas-là, le code est transformé pour ressembler à du langage machine. On appellera ce code transformé du `byte code`.  
Dans les langages interprétés on retrouvera le PowerShell, le Bash et bien d'autres.  
Dans les langages, possédant une étape de compilation, on retrouvera le java, le C# et même le python, ce dernier pouvant se trouver dans les 2 catégories.

# Construisons un package rpm avec un programme à compiler.

Après un peu de théorie je vous proposer de construire notre premier programme C et de le packager.

Commençons par écrire notre programme. En écrivant un simple fichier hello_en_c.c
```c
#include <stdio.h>

int main(void) {
    printf("Hello World\n");
    return 0;
}
```
Nous pourrions le compiler en ligne de commande mais pour rpm nous allons utiliser un makefile que voici
```Makefile
hello_in_c:
        gcc -g -o hello_in_c hello_in_c.c

clean:
        rm hello_in_c

install:
        mkdir -p $(DESTDIR)/usr/bin
        install -m 0755 hello_in_c $(DESTDIR)/usr/bin/hello_in_c

```

Pour préparer l'ensemble pour rpm nous avons besoin de compresser l’ensemble dans un format appelé targz.

```bash
docker run -it --rm --name my-rpm-project -v "$(pwd)":/root -w /root my-rpmbuilder:latest /bin/bash
bash-5.2# mkdir /tmp/hello_in_c-1.0
bash-5.2# cp ~/hello_in_c.c /tmp/hello_in_c-1.0/
bash-5.2# cp ~/Makefile /tmp/hello_in_c-1.0/
bash-5.2# cd /tmp/
bash-5.2# tar -cvzf hello_in_c-1.0.tar.gz hello_in_c-1.0
hello_in_c-1.0/
hello_in_c-1.0/Makefile
hello_in_c-1.0/hello_in_c.c
bash-5.2# ls
hello_in_c-1.0  hello_in_c-1.0.tar.gz
bash-5.2# mv /tmp/hello_in_c-1.0.tar.gz ~/rpmbuild/SOURCES/
```

Nous avons maintenant notre code prêt à être utilisé. Je vous propose donc maintenant de regarder le contenu du fichier spec correspondant `hello_in_c.spec`.  
Commençons par l'entête. Vous remarquerez qu'en dehors d'informations pour le code j'ai indiqué quel est le code qui sera utilisé avec `source0`.  
Regardons ensuite le reste des directives.  
- Dans la directive `%prep` `%setup -q`[^2] décompresse le package que nous avons mis dans les sources.
- Dans `%build` la macro `%make_build`[^3] appellera le makefile pour compiler l'application
- Finalement dans `%install` une dernière macro `%make_install` prendra en charge l'installation. Elle sera l'équivalent du make install.

Créons donc notre package
```bash
bash-5.2# cd rpmbuild/SPECS/
bash-5.2# rpmbuild -bb hello_in_c.spec
setting SOURCE_DATE_EPOCH=1741046400
Executing(%mkbuilddir): /bin/sh -e /var/tmp/rpm-tmp.P03xgq
...
+ exit 0
bash-5.2#
```
Il ne nous reste plus qu’à le tester depuis un autre conteneur
```bash
docker run -it --rm --name my-test-rpm-project -v "$(pwd)":/root -w /root my-rpmbuilder:latest /bin/bash
bash-5.2# cd rpmbuild/
bash-5.2# cd RPMS/x86_64/           
bash-5.2# ls
hello_in_c-1.0-1.fc41.x86_64.rpm  hello_in_c-debuginfo-1.0-1.fc41.x86_64.rpm  hello_in_c-debugsource-1.0-1.fc41.x86_64.rpm
bash-5.2# rpm -i hello_in_c-1.0-1.fc41.x86_64.rpm 
bash-5.2# /usr/bin/hello_in_c 
Hello World
bash-5.2# 
```

Dans ce bref tutoriel, nous avons couvert les essentiels la création d'un package rpm qui vous permettra de compiler une application, la déployer et exécuter des commandes ensuite.  
Avec ces premiers éléments vous pouvez déjà créer vos premiers packages mais il y a encore beaucoup à découvrir. Je vous invite à parcourir les liens suivants pour aller plus loin :
- [un exemple en C avec son package](https://blog.packagecloud.io/building-rpm-packages-with-rpmbuild/)
- [un autre exemple C de Red Hat](https://docs.redhat.com/fr/documentation/red_hat_enterprise_linux/9/html/packaging_and_distributing_software/an-example-spec-file-for-cello_packaging-software)
- [la commande rpmbuild](https://linux.die.net/man/8/rpmbuild)
- [un autre hello world](https://medium.com/@mkhanops/creating-a-test-rpm-package-a-step-by-step-guide-939fb15eb9a1)
- [un article en Français](https://enseignement.alexandre-mesle.com/rpmbuild/rpmbuild.pdf)
- [un autre tutoriel](https://rogerwelin.github.io/rpm/rpmbuild/2015/04/04/rpmbuild-tutorial-part-1.html)
- [encore un autre](https://opensource.com/article/18/9/how-build-rpm-packages)
- [un dernier en Français](https://doc.fedora-fr.org/wiki/La_création_de_RPM_pour_les_nuls_:_Création_du_fichier_SPEC_et_du_Paquetage#Construction_du_paquet)


[^1]:
    En suivant la documentation de [Red Hat](https://www.redhat.com/en/blog/create-rpm-package) il faut installer les packages avec 
    ```bash
    sudo dnf install -y rpmdevtools rpmlint
    ```
    Un [tutoriel en anglais](https://rpm-packaging-guide.github.io) propose lui une installation plus complète
    ```bash
    dnf install gcc rpm-build rpm-devel rpmlint make python bash coreutils diffutils patch rpmdevtools
    ```
[^2]: [macros pour rpm](http://ftp.rpm.org/max-rpm/s1-rpm-inside-macros.html)
[^3]: [make_build recette](https://en.opensuse.org/openSUSE:Build_system_recipes)
    [make_build change](https://fedoraproject.org/wiki/Changes/UseMakeBuildInstallMacro)

