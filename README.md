# Blog-Bash
## Par Simon TALBI et [Matteo CARAVATI], S1A
[Matteo CARAVATI]: https://github.com/mcaravati
### Le script est un simple utilitaire de gestion de blogue par ligne de commande.
#### Il permet :
 - de créer et d'éditer des pages en format markdown, en utilisant divers éditeurs
 - de lister les pages rédigées
 - de supprimer des pages rédigées
 - de générer un ensemble de pages HTML ainsi qu'un fichier PDF à partir des pages rédigées

### Syntaxe d'appel du script :
 ```bash
Usage ./blogue.sh COMMANDE [PARAMETRE]
La liste des commandes est editer, supprimer, lister, construire
  - Éditer un document : ./blogue editer [PAGE]
  - Supprimer un document : ./blogue supprimer [PAGE]
  - Lister les documents : ./blogue lister
  - Générer les fichiers PDF/HTML : ./blogue construire
  - Visualiser le site : ./blogue visualiser [pdf]
```

### Traces d'exécution :
#### Pour l'édition :
```
~/systeme/blog-systeme > ./blogue.sh editer
Fichier à éditer : 
lama
```
```
~/systeme/blog-systeme > ./blogue.sh editer lama
```
#### Pour lister les pages :
```
~/systeme/blog-systeme > ./blogue.sh lister
index.md  lama.md  pommes.md  soleil.md
```
#### Pour supprimer des pages :
```
~/systeme/blog-systeme > ./blogue.sh supprimer
Fichier à supprimer : 
lama
Voulez-vous supprimer la page markdown/lama.md ? (yes/no)?
yes
```
```
~/systeme/blog-systeme > ./blogue.sh supprimer lama
Voulez-vous supprimer la page markdown/lama.md ? (yes/no)?
yes
```
#### Pour construire le blogue : 
```
~/systeme/blog-systeme > ./blogue.sh construire
```
#### Pour visualiser le blogue :
```
~/systeme/blog-systeme > ./blogue.sh visualiser pdf
```
```
~/systeme/blog-systeme > ./blogue.sh visualiser
```
