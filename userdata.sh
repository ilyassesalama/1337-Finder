#!/bin/bash

# colors
RED='\033[0;31m'
NO_COLOR='\033[0m'
GREEN='\033[0;32m'

# variables
IS_FIRST_TIME=true
USER_EXISTS=false
USER_NAME="Ilyasse Salama"
USER_FIRST_NAME="Ilyasse"

# show banner
init_banner() {
	echo -e "${RED}
	
                    ▄█─ █▀▀█ █▀▀█ ▀▀▀█ 
                    ─█─ ──▀▄ ──▀▄ ──█─ 
                    ▄█▄ █▄▄█ █▄▄█ ─▐▌─ 

            ░█▀▀▀ ▀█▀ ░█▄─░█ ░█▀▀▄ ░█▀▀▀ ░█▀▀█ 
            ░█▀▀▀ ░█─ ░█░█░█ ░█─░█ ░█▀▀▀ ░█▄▄▀ 
            ░█─── ▄█▄ ░█──▀█ ░█▄▄▀ ░█▄▄▄ ░█─░█"
	
	sleep 0.1

	if [ "$IS_FIRST_TIME" = true ]; then
		echo -e	"${NO_COLOR} \n\n     Created mainly to help students get the info they\n    need about a missing student who will evaluate them." 
	fi
	echo -e	"\n"
	sleep 0.1
}

init_program() {
	exec 2> /dev/null
	clear
	init_banner
	IS_FIRST_TIME=false
	echo -en "${GREEN}> Enter the user login: ${NO_COLOR}"
	read -a usr
	USER_NAME=${usr}
	USER_FIRST_NAME=$(ldapsearch uid=$USER_NAME | grep givenName | awk '{print $2}')

	check_if_user_exists
}

check_if_user_exists() {
	USER_INFO=$(ldapsearch uid=$USER_NAME | grep givenName)
	USER_INFO=$(awk '{print $1}' <<< $USER_INFO | tr -d '[:]')

	if [ "$USER_INFO" = "givenName" ]; then
		USER_EXISTS=true
		prompt_user_menu
	else
		USER_EXISTS=false
		prompt_user_not_found
	fi
}

get_user_phone(){
	clear
	init_banner
	echo -en "${GREEN}The phone number of $USER_NAME: ${NO_COLOR}"
	ldapsearch uid=$USER_NAME | grep mobile: | awk '{print $2}'

	prompt_menu
}

get_user_full_name(){
	clear
	init_banner
	echo -en "${GREEN}The full name of $USER_NAME: ${NO_COLOR}"
	FREEZE_REASON=$(ldapsearch uid=$USER_NAME | grep cn: | sed 's/cn:/ /')
	echo -e $FREEZE_REASON
	prompt_menu
}

get_user_freeze_status(){
	clear
	init_banner
	echo -e "${GREEN}The freeze status of $USER_NAME:${NO_COLOR}"

	USER_INFO=$(ldapsearch uid=$USER_NAME | grep freezed)

	if [[ "${USER_INFO}" == *"freezed"* ]] ;then
		echo -e "╔═ ✅ $USER_FIRST_NAME has frezeed his curcus."
		echo -e "║"
		echo -en "╚═ Reason of the freeze: "
		FREEZE_REASON=$(ldapsearch uid=$USER_NAME | grep freezed | sed 's/close:/ /' | grep 'reason:' | sed 's/^.*: //')
		echo -e $FREEZE_REASON
	else
		echo -e "❌ $USER_FIRST_NAME has not frezeed his curcus."
	fi
	prompt_menu
}


prompt_user_menu(){
	clear
	init_banner
	echo -e "${GREEN}Choose the information you need:${NO_COLOR}"
	echo -e "
1. Phone number.
2. Full name.
3. Check if the student is freezed.
4. Search for another student.
5. About the script."

	echo -en "${GREEN}\n> Select: ${NO_COLOR}"
	read -a var
	chosen_info=${var}

	if [ $chosen_info -eq 1 ]; then
		get_user_phone
	elif [ $chosen_info -eq 2 ]; then
		get_user_full_name
	elif [ $chosen_info -eq 3 ]; then
		get_user_freeze_status
	elif [ $chosen_info -eq 4 ]; then
		init_program
	elif [ $chosen_info -eq 5 ]; then
		prompt_about_screen
	else
		prompt_user_menu
	fi

	prompt_end_menu
}

prompt_user_not_found(){
	clear
	init_banner
	echo -e "${RED}❌ Student not found."
	prompt_end_menu
}

prompt_about_screen(){
	clear
	init_banner
	echo -e "${GREEN}About:${NO_COLOR}\n"
	echo -e "The purpose of this program is to help students get the\ninformation they need about a missing student who will evaluate them."
	echo -e "This program is open source and can be found on GitHub:\nhttps://github.com/ilyassessalama/1337-Finder"
	prompt_end_menu
}

prompt_end_menu(){
	echo -e "${GREEN}\nWhat do you want to do?${NO_COLOR}\n"
	echo -e "1. Go back.\n2. Exit.\n"
	echo -en "${GREEN}> Select: ${NO_COLOR}"

	read -a reset_option
	if [ $reset_option -eq 2 ]; then
		clear
		exit
	else
		if [ "$USER_EXISTS" = true ]; then
			prompt_user_menu
		else
			init_program
		fi
	fi
}

init_program