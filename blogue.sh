#!/bin/bash
# A script to edit, build and view a simple blog
#####################
# By Simon TALBI
# And Matteo CARAVATI
# S1A
#####################

set -o errexit # Exit if command failed
set -o pipefail # Exit if pipe failed
set -o nounset # Exit if variable not set
# Remove the initial space and instead use '\n'
IFS=$'\n\t'

######################################
# Initialization of the main variables
######################################
EDITOR_PATH=/usr/bin/editor
NANO_PATH=/usr/bin/nano
VI_PATH=/usr/bin/vi
EMACS_PATH=/usr/bin/emacs
SET_EDITOR=${EDITOR:-}
PANDOC_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' pandoc|grep "install ok installed")
TEXLIVE_INSTALLED=$(dpkg-query -W --showformat='${Status}\n' texlive|grep "install ok installed")

########################################################################
# Edit files
# Takes the file name as an argument,
# If no file is specified, it asks which one you want to edit
# It tests different CLI editors and asks you for one if no one is found
#
# Arguments:
#  All
# Globals:
#  EDITOR_PATH
#  NANO_PATH
#  VI_PATH
#  EMACS_PATH
#  SET_EDITOR
# Returns:
#  None
########################################################################
function edit {
  if [ $# -eq 2 ];  then
    file="$2"
    elif [ $# -eq 1 ];  then
      echo "Fichier à éditer : "
      read -r file
    elif [ $# -gt 2 ];  then # If the number of arguments is greater than 2, make a super long file name
      file="$2"
      shift
      for (( i=1; i=$(($#-1)); i++ )); do
        file="$file"_"$2"
        shift
      done
      file=${file//_/ }
  fi
  if [[ "$file" != "${file##*.}" ]]; then # Check if the file name got an extension
    echo "ERREUR: Le fichier de sortie ne peut pas avoir d'extension" >&2
    exit 1
  fi
  if [ "$file" = 'index' ]; then # Check if the file name is index, if yes, throw an error
    echo "ERREUR: Le fichier de sortie ne peut pas être nommé 'index'" >&2
    exit 1
  fi
  if [ -z "$file" ]; then
    echo "ERREUR: Le fichier de sortie ne peut pas ne pas avoir de nom" >&2
    exit 1
  fi
  if [[ ! -d markdown ]]; then # Check if directory markdown/ exists
    mkdir markdown # If not create it
  fi
  if [ -z "$SET_EDITOR" ];  then # Check if $EDITOR variable is set
    if [ -x $EDITOR_PATH ]; then
      editor=$EDITOR_PATH
      elif [ -x $NANO_PATH ]; then
        editor=$NANO_PATH
      elif [ -x $VI_PATH ]; then
        editor=$VI_PATH
      elif [ -x $EMACS_PATH ]; then
        editor=$EMACS_PATH
      else
        echo "Chemin de l'éditeur : "
        read -r editor # Else, specify the editor
    fi
  else
    editor=$SET_EDITOR
  fi
  file="$file".md
  $editor markdown/"$file"
}

#######################################################
# Deletes a file
# Loops if the response is different than 'yes' or 'no'
# Takes the file to delete as an argument
#
# Arguments:
#  All
# Globals:
#  None
# Returns:
#  None
#######################################################
function delete {
  if [ $# -eq 2 ];  then # Check if file name is given as an argument
    file=markdown/"$2".md
    elif [ $# -eq 1 ]; then # Else, ask for it
      echo "Fichier à supprimer : "
      read -r file
      file=markdown/"$file".md
    elif [ $# -gt 2 ];  then # If the number of arguments is greater than 2, make a super long file name
      file="$2"
      shift
      for (( i=1; i=$(($#-1)); i++ )); do
        file="$file"_"$2"
        shift
      done
      file=markdown/${file//_/ }.md
  fi
  if [ -f "$file" ];  then # Ask a confirmation
    while true; do
      echo "Voulez-vous supprimer la page $file ? (yes/no)?"
      read -r answer
      if [ "$answer" = 'yes' ]; then
        rm "$file"
        break
        elif [ "$answer" = 'no' ];  then
          exit 0
          break
      fi
    done
    else
      echo "ERREUR: ${file} : Ce fichier n'existe pas" >&2 # Throw an error if file does not exist
      exit 1
  fi
  
}

##########################
# Lists files in markdown/
#
# Arguments:
#  None
# Globals:
#  None
# Returns:
#  None
##########################
function list {
  if [[ ! "$(ls -A markdown/ 2>/dev/null)" ]];  then # List markdown/ directory if it exists and is not empty
    echo "Il n'y a pas de fichiers"
    else
      ls -A markdown/
  fi
}

########################################################
# Builds the blog from the .md files stored in markdown/
# Outputs directly to web/
# Requires pandoc and pdflatex engine
#
# Arguments:
#  None
# Globals:
#  PANDOC_INSTALLED
#  TEXLIVE_INSTALLED
# Returns:
#  None
########################################################
function build {
  if [ "$PANDOC_INSTALLED" == "" ]; then
    echo "ERREUR: Le paquet pandoc n'est pas installé" >&2
    exit 1
  fi
  if [ "$TEXLIVE_INSTALLED" == "" ]; then
    echo "ERREUR: Le paquet texlive n'est pas installé" >&2
    exit 1
  fi
  if [[ ! "$(ls -A markdown/ 2>/dev/null)" ||  ! -d markdown/ ]]; then # Check if directory markdown/ exists and is not empty
    echo "ERREUR: Rien à construire" >&2
    exit 1
  fi
  if [[ ! -d web/ ]]; then # Check if directory web/ exists
    mkdir web/ # If not create it
    else
      rm -rf web/* # Clean files
  fi
  echo -e "# INDEX\\nContenu actualisé par $USERNAME sur .\\n" > markdown/index.md
  for i in markdown/*.md; do
    echo -e "<a href=\"$(echo "$i" |sed -e "s/.md/.html/" |sed -e "s/markdown\\///")\">$(echo "$i" |sed -e "s/.md//" |sed -e "s/markdown\\///")</a>\\n" >> markdown/index.md # Build file links in index.md
  done
  pandoc markdown/*.md -o blog_built.pdf
  for i in markdown/*.md; do
    pandoc "$i" -o "$(echo "$i" |sed -e "s/.md/.html/" |sed -e "s/markdown\\//web\\//")"
  done
}

#######################################################################
# Open the file web/index.html or blog_built.pdf in the default browser
#
# Arguments:
#  All
# Globals:
#  None
# Returns:
#  None
#######################################################################
function view {
  if [ $# -eq 2 ]; then
    if [ "$2" == "pdf" ]; then # Open blog_built.pdf only if file exists
      if [ -f blog_built.pdf ]; then
        xdg-open blog_built.pdf 2>/dev/null
        else
          echo "ERREUR: Le fichier blog_built.pdf n'existe pas" >&2
          exit 1
      fi
    else
      echo "ERREUR: Commande $2 inconnue" >&2
      exit 1
    fi
  fi
  if [ $# -eq 1 ]; then
    if [ -f web/index.html ]; then # Open index.html in browser only if it exists
      xdg-open web/index.html
      else
        echo "ERREUR: Le fichier web/index.html n'existe pas" >&2
    fi
  fi
}

###############
# Displays help
#
# Arguments:
#  All
# Globals:
#  None
# Returns:
#  None
###############
function usage {
  echo -e  "[ERREUR] 1 action est attendue
Usage $0 COMMANDE [PARAMETRE]\\n
La liste des commandes est editer, supprimer, lister, construire\\n
  - Éditer un document : $0 editer [PAGE]
  - Supprimer un document : $0 supprimer [PAGE]
  - Lister les documents : $0 lister
  - Générer les fichiers PDF/HTML : $0 construire
  - Visualiser le site : $0 visualiser [pdf]" >&2
}

#####################################################
# Main function of the script
# It contains a menu wrapping all the other functions
#####################################################
function main {
  if [ "$#" -lt 1 ];  then
    usage
    exit 1
  fi
  case "$1" in
    $(echo "$1" |grep -i editer)) # The script isn't case-sensitive
      edit "$@" ;;
    $(echo "$1" |grep -i supprimer))
      delete "$@" ;;
    $(echo "$1" |grep -i lister))
      list  ;;
    $(echo "$1" |grep -i construire))
      build ;;
    $(echo "$1" |grep -i visualiser))
      view "$@"  ;;
    *)
      usage ;
      exit 1  ;;
  esac
}

main "$@"

