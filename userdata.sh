#!/bin/bash

# colors
RED='\033[0;31m'
NO_COLOR='\033[0m'

# variables
IS_FIRST_TIME=true
USER_EXISTS=false
USER_NAME="Ilyasse Salama"

# show banner
init_banner() {
	echo -e	"${RED}
             ░░███╗░░██████╗░██████╗░███████╗
             ░████║░░╚════██╗╚════██╗╚════██║
             ██╔██║░░░█████╔╝░█████╔╝░░░░██╔╝
             ╚═╝██║░░░╚═══██╗░╚═══██╗░░░██╔╝░
             ███████╗██████╔╝██████╔╝░░██╔╝░░
             ╚══════╝╚═════╝░╚═════╝░░░╚═╝░░░

      ${NO_COLOR} ███████╗██╗███╗░░██╗██████╗░███████╗██████╗░
       ██╔════╝██║████╗░██║██╔══██╗██╔════╝██╔══██╗
       █████╗░░██║██╔██╗██║██║░░██║█████╗░░██████╔╝
       ██╔══╝░░██║██║╚████║██║░░██║██╔══╝░░██╔══██╗
       ██║░░░░░██║██║░╚███║██████╔╝███████╗██║░░██║
       ╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚═╝"

	   if [ "$IS_FIRST_TIME" = true ]; then
		   echo -e	"\n  Created as a fun project to find information about students"
	   fi
	   echo -e	"\n\n"
}

init_program() {
	exec 2> /dev/null
	clear
	init_banner
	IS_FIRST_TIME=false
	echo "Enter the user login:"
	read -a usr
	USER_NAME=${usr}

	check_if_user_exists
}

check_if_user_exists() {
	USER_INFO=$(ldapsearch uid=$USER_NAME | grep givenName)
	USER_INFO=$(awk '{print $1}' <<< $USER_INFO | tr -d '[:]')

	if [ "$USER_INFO" = "givenName" ]; then
		prompt_user_menu
	else
		prompt_user_not_found
	fi
}

get_user_phone(){
	clear
	init_banner
	echo "--- The phone number of $USER_NAME ---"
	ldapsearch uid=$USER_NAME | grep mobile: | awk '{print $2}'

	prompt_menu
}

get_user_full_name(){
	clear
	init_banner
	echo "--- The full name of $USER_NAME ---"
	ldapsearch uid=$USER_NAME | grep cn: | awk '{print $2 " " $3 " " $4}'

	prompt_menu
}

prompt_user_menu(){
	clear
	init_banner
	echo -e "Choose the information you need:\n1. Get phone number.\n2. Get full name.\n\nSelect:"
	read -a var
	chosen_info=${var}

	if [ $chosen_info -eq 1 ]; then
		get_user_phone
	elif [ $chosen_info -eq 2 ]; then
		get_user_full_name
	else
		echo "Wrong input."
	fi

	prompt_end_menu
}

prompt_user_not_found(){
	clear
	init_banner
	echo -e "\n"
	echo "Student not found."
	prompt_end_menu
}

prompt_end_menu(){
	echo -e "\n\nWhat do you want to do?\n1. Go back to the main menu.\n2. Exit.\n\nSelect:"

	read -a reset_option
	if [ $reset_option -eq 1 ]; then
		init_program
	else
		exit
	fi
}

init_program