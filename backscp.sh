#!/bin/zsh
#########################################
# A simple scp backup script use for remote servers
# Written by: Robin Parisi
# Contact at: parisi.robin@gmail.com
# Release 0.2
# Web Page: http://elliptips.info
#########################################

###############################################################################
#					    Coloration des echo                                   #
###############################################################################
function cecho {
    while [ "$1" ]; do
        case "$1" in 
            -normal)        color="\033[00m" ;;
            -black)         color="\033[30;01m" ;;
            -red)           color="\033[31;01m" ;;
            -green)         color="\033[32;01m" ;;
            -yellow)        color="\033[33;01m" ;;
            -blue)          color="\033[34;01m" ;;
            -magenta)       color="\033[35;01m" ;;
            -cyan)          color="\033[36;01m" ;;
            -white)         color="\033[37;01m" ;;
            -darkblack)     color="\033[30m" ;;
            -darkred)       color="\033[31m" ;;
            -darkgreen)     color="\033[32m" ;;
            -darkyellow)    color="\033[33m" ;;
            -darkblue)      color="\033[34m" ;;
            -darkmagenta)   color="\033[35m" ;;
            -darkcyan)      color="\033[36m" ;;
            -darkwhite)     color="\033[37m" ;;
            -n)             one_line=1;   shift ; continue ;;
            *)              echo -n "$1"; shift ; continue ;;
        esac

        shift
        echo -en "$color"
        echo -en "$1"
        echo -en "\033[00m"
        shift

    done
    if [ ! $one_line ]; then
        echo
    fi
}

###############################################################################
# 							Partie à éditer									  #
###############################################################################

# Configuration du script

# Chemin vers le repertoire contenant les backups
DIRECTORY_BACKUP="/Users/robinparisi/Backup/"

# Extension pour les fichiers archivéss
FILE_NAME="-backup.$(date +"%y-%m-%d")"

# Liste des répertoire distants à sauvegarder (affichage)
echo "Que voulez-vous sauvegarder ?"
echo "    ------------------"
echo "    1) Site 1"
echo "    2) Site 2"
echo "    3) Site 3"
echo "    ------------------"
echo "    q) Quitter"

# On récupère la touche enfoncée
read -t 15 touche

# Liste des répertoire distants à sauvegarder (traitement)
case $touche in
  1)
  SERVER="site1.fr"
  USER="robin"
  DIRECTORY_TO_BACKUP="/path/to/directory"
  NAME="site1"
  ;;
  2)
  SERVER="site2.fr"
  USER="robin"
  DIRECTORY_TO_BACKUP="/path/to/directory"
  NAME="site2"
  ;;
  3)
  SERVER="site3.fr"
  USER="robin"
  DIRECTORY_TO_BACKUP="/path/to/directory"
  NAME="site3"
  ;;
  q)
  exit
  ;;
  *)
  #Traitement des autres valeurs
  echo "Try again"
  ;;
esac

###############################################################################
# 					Il n'est pas necessaire d'éditer cette partie			  #
###############################################################################

# On spécifie de nouveau le répertoire de backup
DIRECTORY_BACKUP="${DIRECTORY_BACKUP}${NAME}/"

# Début de la procédure
start_time=$(date +%s)

# On vérifie que le dossier de backup existe, s'il n'existe pas, alors on tente de le créé
echo -n "Vérification du répertoire de backup : "
if [ -d $DIRECTORY_BACKUP ]; then
	cecho -green "OK"
else
	cecho -red "FAIL"
	cecho -green "Tentative de création..."
	mkdir $DIRECTORY_BACKUP
	EXIT_V="$?"
	case $EXIT_V in
		0) 
		cecho -green "Repertoire créé avec succès"		
		;;
		1)
		cecho -red "Impossible de créer le repertoire"
		exit		
		;;
	esac	
fi

echo -n "Tentative de connexion SSH : "
# Connexion en ssh
scp -r -q "$USER"@"$SERVER":"$DIRECTORY_TO_BACKUP" "$DIRECTORY_BACKUP""$NAME""$FILE_NAME"

# Résultat de la requête
EXIT_V="$?"
case $EXIT_V in
	0)
	cecho -green "OK"
	;;
	1) 
	cecho -red "FAIL"
	exit
	;;
esac

# On se déplace dans le répertoire de backup
cd "$DIRECTORY_BACKUP"

echo -n "Archivage du fichier : "
# Compression du fichier
tar -czf "$DIRECTORY_BACKUP""$NAME""$FILE_NAME".tar.gz "$NAME""$FILE_NAME"

EXIT_V="$?"
case $EXIT_V in
	0)
	cecho -green "OK"
	# Supression du fichier temporaire
	echo -n "Tentative de suppression du fichier temporaire : "
	rm -rf "$DIRECTORY_BACKUP""$NAME""$FILE_NAME"
	EXIT_V="$?"
	case $EXIT_V in
		0)
		cecho -green "OK"
		;;
		1)
		cecho -red "FAIL"
		;;
	esac
	;;
	*)
	cecho -red "FAIL"
	;;
esac

# Fin de la procédure
finish_time=$(date +%s)

###############################################################################
# 						Affichage du résultat								  #
###############################################################################

echo -n "Temps de traitement : "
cecho -yellow "$((finish_time - start_time)) secondes"




