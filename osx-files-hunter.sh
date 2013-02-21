#!/bin/zsh
#########################################
# Written by: Robin PARISI
# Contact at: parisi.robin@gmail.com
# Release 0.1
# Web Page: http://elliptips.info
#########################################


# Functions
#-----------------------------------------------------------------------------

display_ban() {
 echo 
 echo "################################################################################"
 echo "#                             OSX Files Hunter                                 #"
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

delete_report() {
EXIT_V="$?"
 case $EXIT_V in
  0) echo "Suppression $* : \033[32mOK\033[00m";;
  1) echo "Suppression $* : KO";;
  *) echo 'plop';;
 esac
}

test_root() {
 if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root" 1>&2
  exit 1
 fi
}

# Start script
#-----------------------------------------------------------------------------

test_root
display_ban

echo -n "Le script sera lancé à partir du répertoire suivant : "
echo -n "\033[31;01m"
pwd
echo -n "\033[00m"
echo

ask_for_action "Voulez-vous continuer ?"

# DS_Store
echo
echo -n ".DS_STORE : \033[33;01m"
find . -name ".DS_Store" | wc -l
echo -en "\033[00m"

# .fseventsd
echo -n ".fseventsd : \033[33;01m"
find . -type d -name ".fseventsd" | wc -l
echo -en "\033[00m"

# .Trashes
echo -n ".Trashes : \033[33;01m"
find . -type d -name ".Trashes" | wc -l
echo -en "\033[00m"

# .Spotlight-V100
echo -n ".Spotlight-V100 : \033[33;01m"
find . -type d -name ".Spotlight-V100" | wc -l
echo -en "\033[00m"

echo 
ask_for_action "Des fichiers indésirables ont été trouvé. Les supprimer ? "
echo

# Delete hidden files
find . -name .DS_Store -delete
delete_report ".DS_Store"

find . -name .fseventsd -delete
delete_report ".fseventsd"

find . -type d -name .Trashes -delete
delete_report ".Trashes"

find . -type d -name .Spotlight-V100 -delete
delete_report ".Spotlight-V100"

echo
echo "\033[32mSupression terminée\033[00m"