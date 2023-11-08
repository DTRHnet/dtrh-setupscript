#!/usr/bin/env bash

set -o posix
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

# Color functions

function ERROR() { echo -e "\n\033[0;38;2;255;255;127m$(date +"%H:%M:%S")\033[0m \033[1;31m[ERROR]\033[0m - \033[1;31m$1\n\033[0m\n"; } #\033[0;48;2;10m
function WARN() { echo -e "\n\033[0;38;2;255;255;127m$(date +"%H:%M:%S")\033[0m \033[1;33m[WARNING]\033[0m - \033[1;33m$1\n\033[0m"; }
function OK() { echo -e "\n\033[0;38;2;255;255;127m$(date +"%H:%M:%S")\033[0m \033[1;32m[OK]\033[0m - \033[1;32m$1\n\033[0m\n"; }
function DEBUG() { echo -e "\n\033[0;38;2;255;255;127m$(date +"%H:%M:%S")\033[0m \033[1;32m[OK]\033[0m - \033[1;36m$1\n\033[0m\n"; }
function printr() { printf "$(tput setaf 1)${1}"; tput setaf 7; } ;  function boldr() { printf "\033[1;31m$1\n\033[0m" ; }    
function printg() { printf "$(tput setaf 2)${1}"; tput setaf 7; } ;  function boldg() { printf "\033[1;32m$1\n\033[0m" ; } 
function printy() { printf "$(tput setaf 3)${1}"; tput setaf 7; } ;  function boldy() { printf "\033[1;33m$1\n\033[0m" ; }
function printb() { printf "$(tput setaf 4)${1}"; tput setaf 7; } ;  function boldb() { printf "\033[1;34m$1\n\033[0m" ; }
function printm() { printf "$(tput setaf 5)${1}"; tput setaf 7; } ;  function boldm() { printf "\033[1;35m$1\n\033[0m" ; }
function printc() { printf "$(tput setaf 6)${1}"; tput setaf 7; } ;  function boldc() { printf "\033[1;36m$1\n\033[0m" ; }
function printw() { printf "$(tput setaf 7)${1}"; tput setaf 7; } ;  function boldw() { printf "\033[1;37m$1\n\033[0m" ; }

# Globals
_log="0"
_LOGFILE="dtrh-env.log"
_USER=""  # Handles non-administrative user account name


# Logging

_log() {
  
  touch "$(pwd)/${_LOGFILE}"
  exec 3>&1 1>"${_LOGFILE}" 2>&1
  trap "echo 'ERROR: An error occured during execution. Check $(pwd)/${_LOGFILE} for details.' >&3" ERR
  trap '{ set +x; } 2>/dev/null; echo -n "[$(date -Is)]  "; set -x' DEBUG
}

_countdown() {

  # Halt script for x amount of time 
  local x=5
  (
    while [[ ! $x -eq 0 ]]; do
      printf '\rScript will continue in %02d seconds. CTRL+C to exit ' "$x" >&2
      sleep 1 && x=$(( x - 1 ))
    done
  )
  printf  "\n"
  OK "Resuming Script!"
}


_pkgCheck() {

  sleep 0.5
  
  printf "Checking basic dependencies\n\n"
  
  local pkgStatus=""
  local pkg=""
  local iFlag="0"
  local sleepCount="10"

  declare -a pkg404=()
  declare -ar baseArray=(net-tools   vim     make  cmake gcc
                         git curl    wget    lrzsz unzip p7zip
                         jq  openssl unhide  dos2unix    tmux   libplist-utils)

  tabs 5,20,40,50
  for pkg in "${baseArray[@]}"; do 
    if [ "$(dpkg -l ${pkg}  | wc -l)"  -ge 1 ]  ; then 
      printf "Checking for package \033[1;37m${pkg}\033[0;37m\t\t" && printg "Found!\n"  
    else
      printf "Checking for package \033[1;37m${pkg}\033[0;37m\t\t" && printr "Not Found.\n" && pkg404+=( ${pkg} ) 
      iFlag="1"
    fi
  done
  if [[ ${iFlag} = 1 ]]; then 
    sleep 2
    WARN "The following dependencies are missing:"
    for pkg in "${pkg404[@]}"; do
      printf "\t${pkg}\n"
      # TODO: Package Description..
    done
    boldw "\nDefault action is to install package(s)." 
    _countdown  
    apt update
    for pkg in "${pkg404[@]}"; do apt install ${pkg}; done 
  fi
  return        
}

_banner() {

    clear
    echo -ne "\033]11;#100002\007" 
    echo -e "                                                      "
    echo -e "     ▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄    "  
    echo -e "    ▐░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌   "  
    echo -e "    ▐░█▀▀▀▀▀▀▀█░▌▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌   "  
    echo -e "    ▐░▌       ▐░▌    ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌   "  
    echo -e "    ▐░▌       ▐░▌    ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌   "  
    echo -e "    ▐░▌       ▐░▌    ▐░▌     ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌   "  
    echo -e "    ▐░▌       ▐░▌    ▐░▌     ▐░█▀▀▀▀█░█▀▀ ▐░█▀▀▀▀▀▀▀█░▌   "  
    echo -e "    ▐░▌       ▐░▌    ▐░▌     ▐░▌     ▐░▌  ▐░▌       ▐░▌   "  
    echo -e "    ▐░█▄▄▄▄▄▄▄█░▌    ▐░▌     ▐░▌      ▐░▌ ▐░▌       ▐░▌   "  
    echo -e "    ▐░░░░░░░░░░▌     ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌   "  
    echo -e "     ▀▀▀▀▀▀▀▀▀▀       ▀       ▀         ▀  ▀         ▀    "  
    echo -e "                                                      "  
    echo -e "                                                      "  
    echo -e "                                                      "  
    echo -ne "      Fresh Installation Script -    " && boldw "Debian 12 Edition "  
    echo -ne "      Nov 2, 2023                    " && boldw "dtrh.net | admin@ "  
    echo -ne "                            " && boldw "https://github.com/DTRHnet "  
    echo -e " "
    sleep 2
}

_main() {

  _banner
  sleep 1
  
  # Rootcheck
  if [ "$(id -u)" != 0 ]; then  
    ERROR "This script requires root privileges. Please re-run with UID=0" && exit 1
  fi 
  
  # Dependency Check
  _pkgCheck 

  # Sub administrative account to work with
  local uInit="n"  
  while [ "${uInit}" != "Y" ]; do 
    printf "\n"
    read -p "Enter primary account to run script with: " _USER
    printb "Confirm account: \033[1;37m${_USER}\033[0;37m" && read -p " (Yy/Nn)?" uInit && uInit=`echo ${uInit} | tr [:lower:] [:upper:]`
  done
  
  exit 1

}

_main
