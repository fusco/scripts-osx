#!/bin/bash
#########################################
# Written by: Robin PARISI
# Contact at: parisi.robin@gmail.com
# Release 0.1
#########################################

###############################################################################
#					    Coloration des echo                                   #
###############################################################################
function cecho {
    while [ "$1" ]; do
        case "$1" in 
            -red)           color="\033[31;01m" ;;
            -green)         color="\033[32;01m" ;;
            -yellow)        color="\033[33;01m" ;;
            -blue)          color="\033[34;01m" ;;
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

# Define
#-----------------------------------------------------------------------------

# edit user here
USER="robin"

# configuration files
CONF_FILE="/Users/"$USER"/Sites/httpd-vhosts.conf"
HOST_FILE="/etc/hosts" 


# Functions
#-----------------------------------------------------------------------------

last_command() {
	EXIT_V="$?"
	case $EXIT_V in
		0) 
		cecho -green "réussi"		
		;;
		1)
		cecho -red "échoué"
		exit		
		;;
	esac	
}

display_ban() {
 echo 
 cecho -green "################################################################################"
 cecho -green "#                             vhosts generator                                 #"
 cecho -green "################################################################################"
 echo 
}

display_separator() {
 echo	
 echo "################################################################################"
 echo
}

ask_for_action() {
 echo "$*"
 echo -n "(o) pour continuer, (n) pour annuler : "
 read key
 if [ $key != "o" ]
  then
 echo "exit..."
 exit 1
 fi
}

test_root() {
 if [ $EUID -ne 0 ]; then
  cecho -red "Le script doit être lancé en root" 1>&2
  exit 1
 fi
}

# Start script
#-----------------------------------------------------------------------------

test_root
display_ban

echo -n "Choisir un nom de domaine (ex: site.local) : "
read domain_name
echo -n "Choisir un nom pour le repertoire du site  : "
read site_name

echo
cecho -blue "Le site sera configuré tel quel : "
echo "Domaine    : " $domain_name
echo "Repertoire : " /Users/$USER/Sites/$site_names
echo

ask_for_action "Voulez-vous continuer ?"

display_separator

# edit hosts file
echo -n "Edition du fichier hosts         : "
echo "127.0.0.1    "$domain_name >> $HOST_FILE
last_command

# create directory

if [ -d /Users/$USER/Sites/$site_name ]; then
	echo -n "Création du répertoire           : "
	cecho -yellow "Le repertoire $site_name existe déjà"
else
    mkdir /Users/$USER/Sites/$site_name
    chown $USER /Users/$USER/Sites/$site_name
    echo -n "Création du répertoire           : "
    last_command
fi

# add conf to http-vhosts.conf
echo "<VirtualHost *:80>
  	ServerName $domain_name
  	DocumentRoot "/Users/$USER/Sites/$site_name"
</VirtualHost>

" >> $CONF_FILE
echo -n "Edition du fichier httpd-vhosts  : "
last_command

# restart apache
echo -n "Apache restart                   : "
apachectl graceful
last_command

display_separator
