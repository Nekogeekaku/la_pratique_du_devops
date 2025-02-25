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


