# La pratique du DevOps : le Shell script

Si l'on suit la [roadmap du DevOps](https://roadmap.sh/devops), on voit rapidement que le Shell Scripting fait partie des premières compétences à acquérir.
C'est d'ailleurs le [premier des projets](https://roadmap.sh/projects/server-stats) qui est proposé par le site.

Je vous propose donc au fil des épisodes suivants de pratiquer le Shell script avec moi. 

# Épisode 1 : Apprenons le Shell script : Devenez un développeur en écrivant votre Hello world en Shell script

Avant de commencer, la première étape est toujours, comme lorsque vous préparez les ingrédients d'une recette de cuisine, de préparer tous les outils que nous allons utiliser.
Je vous propose pour cela d'avoir un environnement commun de travail avec un Ubuntu.
Si vous n'avez pas de Ubuntu installé, je vous propose de le faire via docker aujourd'hui.
Le [site de docker](https://www.docker.com/get-started/) vous expliquera comment le faire selon votre environnement.

Un des autres éléments clé est votre éditeur de code. Actuellement j'ai une préférence pour [Visual Code](https://code.visualstudio.com) mais tout informaticien le sait bien, le meilleur outil est celui que vous utilisez régulièrement.

Finalement nous avons besoin d'avoir une capacité de ligne de commande en Shell, au moins pour cet épisode. Si vous êtes sur Windows je vous propose [git Bash](https://git-scm.com/downloads) si vous n'avez rien d'autre.

Dans votre répertoire de travail créons maintenant notre fichier de travail `server-stats.sh`

Dans une ligne de commande Shell nous allons d'abord rendre ce fichier exécutable :
```bash
chmod +x server-stats.sh
```
Depuis notre éditeur, ouvrons le fichier pour y ajouter le code suivant :
```bash
#!/bin/bash
echo Hello world
```

La première ligne va indiquer que nous allons utiliser un Shell de type Bash. Il est important de savoir qu'il existe différents types de Shell avec différentes fonctionnalités. Personnellement j'aime Bash pour sa complétion.


Maintenant placez-vous dans le répertoire de travail et exécuter la commande docker qui le fera tourner dans un Ubuntu
```bash
docker run  -v ./:/tmp -w /tmp -i -t  ubuntu /bin/bash server-stats.sh
```

Félicitation vous avez fait votre premier hello world de développeur Shell script. Dans le prochain épisode nous allons commencer les choses sérieuses mais toujours avec fun.

# Épisode 2 : Apprenons le Shell script : Affichons des informations utiles sur notre CPU


Nous allons ajouter une commande simple à notre script ; c'est la commande `top`.
Corrigeons donc notre script pour qu'il ressemble à cela :
```bash
#!/bin/bash

top
```
Avant de le lancer assurez de lire l'information ci-dessous.
La commande top est interactive et va donc se bloquer en attendant que vous lui donniez l'ordre de se terminer. Cela se fait en appuyant sur la touche `q`

Maintenant lancez votre commande.

Bon c'est bien mais vous voudriez peut-être que toutes vos commandes ne demandent pas des instructions supplémentaires.

Dans le cas présent on va le faire très simplement en limitant le nombre de fois ou top fait sa requête en fond à 1.
Corriger donc votre script comme suit avant de le relancer : 
```bash
#!/bin/bash

top -n 1
```

C'est mieux n'est-ce pas mais il y a quand même pas mal d'informations inutiles ici. On va limiter tout ça à juste la ligne cpu.
Corrigez et lancez notre script comme suit :
```bash
#!/bin/bash

top -n 1 | grep Cpu
```
Normalement vous récupérez des informations dans le style suivant :
```bash
%Cpu(s):  1.7 us,  0.9 sy,  0.0 ni, 90.5 id,  6.9 wa,  0.0 hi,  0.0 si,  0.0 st 
```
Vous pourrez trouver plus d'informations sur la commande top sur le site [phoenix nap](https://phoenixnap.com/kb/top-command-in-linux).

Finalement il ne nous faut qu'une seule valeur à afficher. Pour me simplifier la vie je vais prendre la valeur idle que je vais soustraire de 100 pour connaitre la consommation de CPU.
Nous allons utiliser une commande un peu plus compliquée qui s'appelle awk et qui va nous permettre non seulement de récupérer la ligne cpu et mais aussi de récupérer la 8ème valeur.
awk est un outil très puissant qui peut faire un peu peur. Je vous propose donc de l'utiliser au fil de quelques exemples. Vous pourrez trouver plus d'exemples sur [geeks for geeks](https://www.geeksforgeeks.org/awk-command-unixlinux-examples/).

Modifions notre script et exécutons le :
```bash
#!/bin/bash
IDLE=$(top -n 1 | awk '/Cpu/{print $8}')
echo ${IDLE}
```

Avec awk nous récupérons donc la ligne cpu et la 8ème colonne affichée.
Vous verrez en l'exécutant plusieurs fois que vous avez parfois comme retour `id,`. Cela est dû à la valeur 100% qui se retrouve écrite  `ni,100.0 id,`. En perdant l'espace nous obtenons un décalage.
Nous allons devoir traiter ce cas et je vous propose une petite boucle pour ce faire.
Le script doit maintenant ressembler à cela : 
```bash
#!/bin/bash
while true; do
    IDLE=$(top -n 1 | awk '/Cpu/{print $8}')
    echo "["${IDLE}"]"
    [[ "$IDLE" = *id* ]] || break
done
```
Notre boucle retente d'obtenir une valeur top jusqu'à ce que la valeur ne contienne pas id.
[buzut](https://buzut.net/maitriser-les-conditions-en-bash/) propose un tutoriel pour vous en apprendre plus sur les conditions

Maintenant que nous avons notre valeur, il reste un dernier petit effort à faire.

Bash ne sait traiter que des entiers. Nous allons donc commencer avec un entier.
Je vous propose donc de continuer notre script avec le code suivant :
```bash
#!/bin/bash
while true; do
    IDLE=$(top -n 1 | awk '/Cpu/{print $8}')
    echo "["${IDLE}"]"
    [[ "$IDLE" = *id* ]] || break
done
echo CPU utilisé : $(( 100 - ${IDLE%.*})) %
```
Le résultat est intéressant mais il y a quand même une solution pour calculer notre pourcentage de manière plus précise.
Encore une fois nous allons faire appel à awk avec le script suivant : 
```bash
#!/bin/bash
while true; do
    IDLE=$(top -n 1 | awk '/Cpu/{print $8}')
    echo "["${IDLE}"]"
    [[ "$IDLE" = *id* ]] || break
done
echo CPU utilisé :$(echo 100 ${IDLE} | awk '{print $1 - $2}') %
```

Et voilà vous avez maintenant un script pour connaitre la charge de votre CPU.

Dans le prochain épisode nous verrons comment récupérer des informations sur la mémoire mais vous pouvez déjà le faire avec ce que nous avons appris dans cet épisode.  

# Épisode 3 : Apprenons le shell script : Affichons des informations utiles sur la mémoire

En suivant l'exercice proposé nous devons maintenant afficher l'usage de la mémoire.  
On devra affichage la mémoire disponible, la mémoire utilisée et un pourcentage
On pourrait partir sur la commande précédente mais pourquoi rester sur nos acquis quand de nouvelles commandes nous tendent les bras.

Nous allons utiliser une commande qui s'appelle `free` et qui est dédié à l'affichage des informations de la mémoire.
Vous pourrez en apprendre plus sur [linuxize](https://linuxize.com/post/free-command-in-linux/)

Commençons simplement par ajouter à notre script une simple ligne
```bash
free
```
Complet mais pas très lisible alors utilisons l'option `-h` pour voir

```bash
free -h
```
Beaucoup mieux n'est-ce pas. Pour nous simplifier la suite je voir propose d'ajouter aussi le total avec `-t`.

```bash
free -h -t
```
Maintenant que nous avons nos informations je vous propose de faire encore une fois appel à awk pour récupérer les informations pertinentes

Ajoutons donc les lignes suivantes :
```bash
MEMORY_USED_READABLE=$(free -h -t | awk '/Total:/{print $3}')
MEMORY_FREE_READABLE=$(free -h -t | awk '/Total:/{print $4}')
TOTAL_MEMORY=$(free -t | awk '/Total:/{print $2}')
MEMORY_USED=$(free -t | awk '/Total:/{print $3}')
MEMORY_FREE=$(free -t | awk '/Total:/{print $4}')
echo "Total Memory : " $TOTAL_MEMORY
echo "Memory Used : " $MEMORY_USED_READABLE $MEMORY_USED
echo "Memory free : " $MEMORY_FREE_READABLE $MEMORY_FREE
```

Comme précédemment, nous avons extrait de la commande la ligne utile, cette fois-ci contenant les totaux, pour en sortir 3 informations pertinentes : la mémoire totale, la mémoire utilisée et la mémoire disponible.

Il ne nous reste plus qu'à calculer les pourcentages. Je vais à nouveau utiliser awk, plus précis que le bash.
Nos deux dernières lignes ressemble donc à cela.
```bash
echo "Memory Used : " $MEMORY_USED_READABLE "("$(echo $MEMORY_USED $TOTAL_MEMORY | awk '{print ($1 / $2)*100}')%")"
echo "Memory free : " $MEMORY_FREE_READABLE "("$(echo $MEMORY_FREE $TOTAL_MEMORY | awk '{print ($1 / $2)*100}')%")"
```

Le problème qui apparait c'est que notre calcul possède un peu trop de résultat après la virgule, ce qui n'est pas très utile et le rend difficilement lisible.  
Je vous propose donc d'utiliser `printf` qui nous permettra de travailler le rendu.  
Remplaçons donc une nouvelle fois notre calcul pour :
```bash
echo "Memory Used : " $MEMORY_USED_READABLE "("$(echo $MEMORY_USED $TOTAL_MEMORY | awk '{printf "%.2f",($1 / $2)*100}')%")"
echo "Memory free : " $MEMORY_FREE_READABLE "("$(echo $MEMORY_FREE $TOTAL_MEMORY | awk '{printf "%.2f",($1 / $2)*100}')%")"
```
Nous voilà donc équipé d'un nouveau module qui vous informe sur la consommation de la mémoire.



# Épisode 4 : Apprenons le shell script : Gestion de l'espace disque

Dans cet épisode, un peu plus long nous allons récupérer des informations sur le disque. La commande, le permettant est assez classique et s'appelle `df`. Pour pouvoir obtenir un résultat plus facile à exploiter, il faudra néanmoins emprunter un chemin tortueux que je vous aiderai à simplifier.

Si vous vouslez plus d'information sur la commande vous pouvez consulter [Phoenix nap](https://phoenixnap.com/kb/linux-check-disk-space) ou [geeks for geeks](https://www.geeksforgeeks.org/df-command-linux-examples/).

Comme pour la mémoire nous allons devoir afficher l'espace disponible et l'espace utilisé avec les pourcentages respectif.

Commençons tout d'abord par regarder la méthode df :
```bash
df
```
L'exécution devrait vous donner les informations suivantes :
```bash
Filesystem            1K-blocks      Used  Available Use% Mounted on
overlay                61202244  19360724   38700196  34% /
tmpfs                     65536         0      65536   0% /dev
shm                       65536         0      65536   0% /dev/shm
/run/host_mark/Users 2071491588 898960368 1172531220  44% /tmp
/dev/vda1              61202244  19360724   38700196  34% /etc/hosts
tmpfs                   3032680         0    3032680   0% /proc/acpi
tmpfs                   3032680         0    3032680   0% /sys/firmware
```

Les informations sont intéressantes mais pas très faciles à lire à cause du format, ce que nous allons commencer par changer avec l'option `-h` :
```bash
df -h
```

Comme pour la mémoire un total sera bien utile et je vous le propose avec l'option `--total` : 
```bash
df -h --total
```

En partant de ces informations, nous pouvons facilement dupliquer le travail réalisé dans l'épisode précédent. Je vous évite les étapes intermédiaires qui vous devriez identifier pour aller directement au résultat : 
```bash
DISK_USED_READABLE=$(df -h --total | awk '/total/{print $3}')
DISK_FREE_READABLE=$(df -h --total | awk '/total/{print $4}')
TOTAL_DISK_READABLE=$(df -h --total | awk '/total/{print $2}')
TOTAL_DISK=$(df --total | awk '/total/{print $2}')
DISK_USED=$(df --total | awk '/total/{print $3}')
DISK_FREE=$(df --total | awk '/total/{print $4}')
echo "Total Disk : " $TOTAL_DISK_READABLE
echo "Disk Used : " $DISK_USED_READABLE "("$(echo $DISK_USED $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
echo "Disk free : " $DISK_FREE_READABLE "("$(echo $DISK_FREE $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
```
Le résultat est intéressant mais contrairement à la mémoire il n'est pas toujours pertinent car il peut y avoir plusieurs sources pour le disque entre les internes, et les externes ou encore entre les espaces systèmes et les espaces de travail.

Je vous propose donc de créer une liste selon vos besoins des espaces que nous voulons suivre. Je vais m'intéresser, personnellement uniquement à l'`overlay` qui contient le système et le `tmp` que j'ai monté comme espace de travail.

Pour cette liste, ou tableau, vous pourrez en apprendre plus sur [linux config](https://linuxconfig.org/how-to-use-arrays-in-bash-script).

Déclarons une variable `DISK_TO_PARSE` avec deux valeurs dans mon cas `/` et `/tmp` ; puis affichons le contenu.  
Cela prend la forme :
```bash
DISK_TO_PARSE=(/ /tmp)

for i in "${DISK_TO_PARSE[@]}"
do 
    echo "$i"
done
```

L'avantage de la commande df c'est qu'elle permet d'interroger spécifique un volume monté comme suit :  `df -h <disque space>`.

Si vous reprenez le travail effectué sur total, vous pouvez facilement compléter notre script courant. Je vous propose de l'essayer avant une alternative :
```bash
DISK_TO_PARSE=(/ /tmp)

for i in "${DISK_TO_PARSE[@]}"
do 
    echo "$i"
# insérez ici votre code. Si si vous pouvez le faire.
done
```

Lorsque l'on prend un peu d'expérience, en tant que développeur, et dans l'IT en général, on essaie d'éviter de dupliquer les choses inutilement.

Pour cela je vais en profiter pour vous introduire aux joies de la réutilisabilité avec les fonctions. [It connect](https://www.it-connect.fr/les-fonctions-en-bash-scripting-linux/) vous en présentera les principes.

Notre code devrait donc ressembler à cela :
```bash
DISK_USED_READABLE=$(df -h --total | awk '/total/{print $3}')
DISK_FREE_READABLE=$(df -h --total | awk '/total/{print $4}')
TOTAL_DISK_READABLE=$(df -h --total | awk '/total/{print $2}')
TOTAL_DISK=$(df --total | awk '/total/{print $2}')
DISK_USED=$(df --total | awk '/total/{print $3}')
DISK_FREE=$(df --total | awk '/total/{print $4}')
echo "Total Disk : " $TOTAL_DISK_READABLE
echo "Disk Used : " $DISK_USED_READABLE "("$(echo $DISK_USED $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
echo "Disk free : " $DISK_FREE_READABLE "("$(echo $DISK_FREE $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"

function DF_on_mount {
        local MOUNT=$1
        local DISK_USED_READABLE=$(df -h --total $MOUNT| awk '/total/{print $3}')
        local DISK_FREE_READABLE=$(df -h --total $MOUNT| awk '/total/{print $4}')
        local TOTAL_DISK_READABLE=$(df -h --total $MOUNT| awk '/total/{print $2}')
        local TOTAL_DISK=$(df --total $MOUNT| awk '/total/{print $2}')
        local DISK_USED=$(df --total $MOUNT| awk '/total/{print $3}')
        local DISK_FREE=$(df --total $MOUNT| awk '/total/{print $4}')
        echo "------" $MOUNT "-------"
        echo "Total Disk : " $TOTAL_DISK_READABLE
        echo "Disk Used : " $DISK_USED_READABLE "("$(echo $DISK_USED $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
        echo "Disk free : " $DISK_FREE_READABLE "("$(echo $DISK_FREE $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
    
}
DISK_TO_PARSE=(/ /tmp)

for i in "${DISK_TO_PARSE[@]}"
do 
    DF_on_mount $i
done
```

Jusque-là j'espère que vous me suivez mais à part réaliser ce que l'on appelle de la refactorisation, je n'ai pas résolu mon souci. Le code précédent de total, qui a dû vous inspirer pour celui-ci, est quasiment identique et toujours là.

En introduisant une petite condition, nous pouvons simplifier tout le script précédent et éviter les duplicatas :
```bash
function DF_on_mount {
        local MOUNT=$1
        local DISK_USED_READABLE=$(df -h --total $MOUNT| awk '/total/{print $3}')
        local DISK_FREE_READABLE=$(df -h --total $MOUNT| awk '/total/{print $4}')
        local TOTAL_DISK_READABLE=$(df -h --total $MOUNT| awk '/total/{print $2}')
        local TOTAL_DISK=$(df --total $MOUNT| awk '/total/{print $2}')
        local DISK_USED=$(df --total $MOUNT| awk '/total/{print $3}')
        local DISK_FREE=$(df --total $MOUNT| awk '/total/{print $4}')
        [ -z "$MOUNT" ] && MOUNT="Global"
        echo "------" $MOUNT "-------"
        echo "Total Disk : " $TOTAL_DISK_READABLE
        echo "Disk Used : " $DISK_USED_READABLE "("$(echo $DISK_USED $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
        echo "Disk free : " $DISK_FREE_READABLE "("$(echo $DISK_FREE $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
    
}
DF_on_mount

DISK_TO_PARSE=(/ /tmp)

for i in "${DISK_TO_PARSE[@]}"
do 
    echo "$i"
    df -h --total $i
    DF_on_mount $i
done

```

Avec cet épisode un peu long, vous connaissez maintenant la commande `df`, les tableaux et les fonctions.

# Épisode 5 : Apprenons le shell script : Gestion des processus 

Dans ce dernier épisode nous allons nous concentrer sur les 5 processus consommateur en termes de mémoire et de CPU.

Nous pourrions de nouveau utiliser la commande TOP mais nous allons plutôt utiliser la commande [ps](https://man7.org/linux/man-pages/man1/ps.1.html)

Si nous ajoutons simplement la commande à notre script :
```bash
ps
```
Nous obtenons quelques informations sur les processus. Il s'agit des processus tournant dans notre fenêtre de commande.  
Changeons et affichons tous les processus :
```bash
ps -e
```
`ps` contient une option pour formatter la sortie en ajoutant des colonnes. Pour savoir toutes les informations faites un `ps -L`
Dans notre cas je vous propose d'ajouter la consommation de cpu et de mémoire : 
```bash
ps -eo pid,tty,time,cmd,%mem,%cpu
```

Il ne nous reste plus qu'à ordonner selon les critères comme suit :
```bash
ps -eo pid,tty,time,cmd,%mem,%cpu --sort=-%mem
ps -eo pid,tty,time,cmd,%mem,%cpu --sort=-%cpu
```

Dernière étape, limitons-nous à 5 processus.   
Pour cela il faut utiliser la commande `head`. Par défaut elle indique 10 lignes. 
Vous remarquez que les entêtes de colonnes comptent pour 1 et donc pour limiter à 5 il faudra donc écrire `head -6`.   
Si comme moi vous le lancez depuis docker vous avez probablement constaté que vous n'avez que 2 processus. Essayez la valeur `head -2` et `head -3` pour voir le comportement : 
```bash
ps -eo pid,tty,time,cmd,%mem,%cpu --sort=-%mem | head -6
ps -eo pid,tty,time,cmd,%mem,%cpu --sort=-%cpu | head -6
```

Comme le formatage correspond à ce que nous avons souhaité rien à rajouter et nous avons donc terminé notre épisode.

Nous avons au fil de ces épisode écrit notre premier script de supervision qui vous rendra, je l'espère, de nombreux services.



