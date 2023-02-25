#!/bin/bash

# colors
RED='\033[0;31m'
NO_COLOR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BGREEN='\033[1;32m'
YELLOW='\033[1;33m'

# variables
IS_FIRST_TIME=true
USAGE_COUNT=""
USER_EXISTS=false
USER_NAME="Ilyasse Salama"
USER_FIRST_NAME="Ilyasse"
USER_LOGIN="isalama"

USEFUL_LINKS=(
    "https://iscsi-tools.1337.ma/"
    "https://github-portal.42.fr/login"
    "https://find-peers.codam.nl/"
    "https://42evaluators.com/calculator"
    "https://42evaluators.com/leaderboard/"
)


# get current usage
get_usage(){
	USAGE_COUNT=$(curl -s "https://visitor-badge.glitch.me/badge?page_id=1337-Finder" | sed -n 's/.*<text[^>]*>\([^<]*\)<.*/\1/p')
	if [ -z "$USAGE_COUNT" ]; then
		echo -e "${NO_COLOR}\n════════════════════════════════════════════════════════════\n"
	else
        echo -e "${NO_COLOR}\n═════════════ Total calls of the script: $USAGE_COUNT ═════════════════\n"
    fi
}

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
        echo -e "${NO_COLOR} \n\n     Created mainly to help students get the info they\n    need about a missing student who will evaluate them."
        echo -e "${PURPLE}               --- Maintained by isalama ---${NO_COLOR}"
        get_usage
    else
        echo -e "${NO_COLOR}\n════════════════════════════════════════════════════════════\n"
    fi

	sleep 0.1
}

init_program() {
	exec 2> /dev/null
	clear
	init_banner
	IS_FIRST_TIME=false
	echo -en "${GREEN}> Enter the user login: ${NO_COLOR}"
	read -a usr
	USER_LOGIN=${usr}
	USER_FIRST_NAME=$(ldapsearch uid=$USER_LOGIN | grep givenName | awk '{print $2}')
	USER_NAME=$(ldapsearch uid=$USER_LOGIN | grep cn: | sed 's/cn:/ /' | xargs)

	check_if_user_exists
}

check_if_user_exists() {
	USER_INFO=$(ldapsearch uid=$USER_LOGIN | grep givenName)
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

	PHONE_NUMBER=$(ldapsearch uid=$USER_LOGIN | grep mobile: | awk '{print $2}')

	if [[ -z "$PHONE_NUMBER" ]]; then
		echo -e "${RED}\n❌ We couldn't get the phone number of ${BGREEN}$USER_FIRST_NAME${RED} because they
either didn't add it to their profile or an error has ocurred."
	else
		echo -en "The phone number of $USER_LOGIN: "
		echo -e $PHONE_NUMBER
	fi

	prompt_menu
}

get_user_full_name(){
	clear
	init_banner
	echo -en "The full name of $USER_LOGIN: "
	echo -e $USER_NAME
	prompt_menu
}

get_user_freeze_status(){
	clear
	init_banner
	echo -e "The freeze status of $USER_LOGIN:"

	USER_INFO=$(ldapsearch uid=$USER_LOGIN | grep freezed)

	if [[ "${USER_INFO}" == *"freezed"* ]] ;then
		echo -e "╔═ ✅ ${GREEN}$USER_FIRST_NAME${NO_COLOR} has frezeed his curcus."
		echo -e "║"
		echo -en "╚═ Reason of the freeze: "
		FREEZE_REASON=$(ldapsearch uid=$USER_LOGIN | grep freezed | sed 's/close:/ /' | grep 'reason:' | sed 's/^.*: //')
		echo -e $FREEZE_REASON
	else
		echo -e "❌ ${RED}$USER_FIRST_NAME${NO_COLOR} has not frezeed his curcus."
	fi
	prompt_menu
}

get_suspension_status(){
	clear
	init_banner
	echo -e "${YELLOW}The suspension status of $USER_LOGIN:${NO_COLOR}"

	USER_INFO=$(ldapsearch uid=$USER_LOGIN | grep "close:")

	if [[ "${USER_INFO}" == *"close:"* ]]; then
		echo -e "╔═ ✅ ${GREEN}$USER_FIRST_NAME${NO_COLOR} was or is currently suspended."
		echo -e "║"
		echo -en "╚═ Reason(s):\n"

		SUSPENSION_REASON=$(ldapsearch uid=$USER_LOGIN | grep "close:" | grep -v "freezed" | sed 's/close: //' | sed 's/^/ - /')
echo -e "$SUSPENSION_REASON"


	else
		echo -e "❌ ${RED}$USER_FIRST_NAME${NO_COLOR} is not suspended."
	fi
	prompt_menu
}


prompt_user_menu(){
	clear
	init_banner
	echo -e "${GREEN}Choose the information you need:${NO_COLOR}"
	echo -e "
${YELLOW}User info:${NO_COLOR}
1. Phone number
2. Full name
3. Check if the student is freezed
4. Open student's intra profile
5. Check if the student is currently suspended

${YELLOW}Other:${NO_COLOR}
6. Search for another student
7. Useful links for you as a student
8. About the script"

	echo -en "${GREEN}\n> Select: ${NO_COLOR}"
	read -a var
	chosen_info=${var}

	end_menu_options=(
    	"get_user_phone"
    	"get_user_full_name"
    	"get_user_freeze_status"
    	"open_intra_profile"
    	"get_suspension_status"
    	"init_program"
    	"get_useful_links"
    	"prompt_about_screen"
	)

  chosen_option=${end_menu_options[$((chosen_info-1))]}
    if [[ $chosen_option =~ ^(get|open|prompt)_.*$ && $(type -t "$chosen_option") = "function" ]]; then
        "$chosen_option"
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
	echo -e "${YELLOW}About:${NO_COLOR}\n"
	echo -e "The purpose of this script is to help students get the\ninformation they need about a missing student who will evaluate them."
	echo -e "This script is open source and can be found on GitHub:\nhttps://github.com/ilyassesalama/1337-Finder"
	prompt_end_menu
}

get_useful_links(){
	clear
	init_banner
	echo -e "${GREEN}All available useful links:${NO_COLOR}"
	echo -e "
1. ISCSI Tools
2. Github student pack
3. Peers Finder
4. Projects XP Calculator
5. Students Leaderboard

${YELLOW}What's next:${NO_COLOR}
6. Go back
7. Exit"

	echo -en "${GREEN}\n> Select: ${NO_COLOR}"
	read -r chosen_info

	if [[ $chosen_info =~ ^[0-9]+$ ]]; then
        chosen_info=$((chosen_info-1))
        if [ $chosen_info -lt ${#USEFUL_LINKS[@]} ]; then
            open "${USEFUL_LINKS[$chosen_info]}"
        fi
    fi

	chosen_info=$((chosen_info+1))

	if [ $chosen_info -eq 6 ]; then
		if [ "$USER_EXISTS" = true ]; then
			prompt_user_menu
		else
			init_program
		fi

	elif [ $chosen_info -eq 7 ]; then 
		clear
		exit
	else
		get_useful_links
	fi
}

prompt_end_menu(){
	echo -e "${YELLOW}\nWhat's next?${NO_COLOR}"
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

open_intra_profile(){
	clear
	init_banner
	echo -en "Opening intra profile of ${PURPLE}$USER_NAME${NO_COLOR}... "
	sleep 0.3
	open "https://profile.intra.42.fr/users/$USER_LOGIN"
	echo -e "${GREEN}✓ Done${NO_COLOR}"
	prompt_menu
}

init_program