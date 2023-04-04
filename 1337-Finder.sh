#!/bin/bash -i

# colors
RED='\033[0;31m'
NO_COLOR='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BGREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'

# variables
LDAPER="ldapsearch"
IS_FIRST_TIME=true
USAGE_COUNT=""
USER_EXISTS=false
USER_NAME="Ilyasse Salama"
USER_FIRST_NAME="Ilyasse"
USER_LOGIN="isalama"

USEFUL_LINKS=(
    "https://iscsi-tools.1337.ma/"
    "https://github-portal.42.fr/login"
	"https://overseer.1337.ma/"
	"https://mail-students.1337.ma/SOGo/"
    "https://find-peers.codam.nl/"
    "https://42evaluators.com/calculator"
    "https://42evaluators.com/leaderboard/"
)

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

    echo -e "${NO_COLOR} \n\n     Created mainly to help students get the info they\n    need about a missing student who will evaluate them."
    echo -e "${PURPLE}               --- Maintained by isalama ---${NO_COLOR}"
	echo -e "${NO_COLOR}\n════════════════════════════════════════════════════════════\n"
    get_usage

	sleep 0.1
}

init_program() {
    exec 2> /dev/null
    clear
    set_new_alias

	if is_ldap_available; then
		init_banner
		printf '\033[8;40;100t'
		if [ -z "$1" ]; then
        	echo -en "${GREEN}> Enter the user login: ${NO_COLOR}"
        	read -a usr
        	USER_LOGIN=${usr}
    	else
        	USER_LOGIN=$1
    	fi

    USER_FIRST_NAME=$(eval $LDAPER uid=$USER_LOGIN | grep givenName | awk '{print $2}')
    USER_NAME=$(eval $LDAPER uid=$USER_LOGIN | grep cn: | sed 's/cn:/ /' | xargs)

    check_if_user_exists
	else
		echo -e "${RED}
+----------------------------------------------------------+
|   	   It seems like LDAP is broken in the  	   |
|        school currently, please try again later          |
+----------------------------------------------------------+${NO_COLOR}"
		exit 1
	fi 
}

is_ldap_available() {
	local ldapsearch_output
    ldapsearch_output=$(ldapsearch -LLL -b "dc=1337,dc=ma" -s base "(objectclass=*)")
    if [[ $? -eq 0 && "$ldapsearch_output" =~ "1337" ]]; then
        return 0  # LDAP is working
    else
        # Try again with simple bind
        ldapsearch_output=$(ldapsearch -x -LLL -b "dc=1337,dc=ma" -s base "(objectclass=*)")
        if [[ $? -eq 0 && "$ldapsearch_output" =~ "1337" ]]; then
			LDAPER="ldapsearch -x"
            return 0  # LDAP is working
        else
            return 1  # LDAP is not working
        fi
    fi
}

set_new_alias(){
	# Set the shell configuration file path based on the current shell
	shell_f=$(echo -n "$SHELL" | awk -F / '{print $3}')
	shell_f="${HOME}/.${shell_f}rc"

	# Add the alias to the shell configuration file if it doesn't exist
	if ! grep -q "alias finder='bash <(curl -s https://raw.githubusercontent.com/ilyassesalama/1337-Finder/main/1337-Finder.sh)'" "$shell_f"; then
    	echo -e "\n\nalias finder='bash <(curl -s https://raw.githubusercontent.com/ilyassesalama/1337-Finder/main/1337-Finder.sh)'" >> "$shell_f"
		echo -e "
+------------------------------------------------------------------------+
|  Run this command \"${RED}source $shell_f${NO_COLOR}\" to be able to run     |
|   the script directly by typing \"${CYAN}finder${YELLOW} LOGIN${NO_COLOR}\" in your terminal.       |
+------------------------------------------------------------------------+"
		sleep 2
	fi
}

check_if_user_exists() {
	USER_INFO=$(eval $LDAPER uid=$USER_LOGIN | grep givenName)
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

	PHONE_NUMBER=$(eval $LDAPER uid=$USER_LOGIN | grep mobile: | awk '{print $2}')

	if [[ -z "$PHONE_NUMBER" ]]; then
		echo -e "${RED}\n❌ We couldn't get the phone number of ${BGREEN}$USER_FIRST_NAME${RED} because they
either didn't add it to their profile or an error has ocurred."
	else
		echo -en "The phone number of $USER_LOGIN: "
		echo -e ${CYAN}$PHONE_NUMBER ${NO_COLOR}
	fi

	prompt_menu
}

get_user_full_name(){
	clear
	init_banner
	echo -en "The full name of $USER_LOGIN: "
	echo -e ${CYAN}$USER_NAME ${NO_COLOR}
	prompt_menu
}

get_user_freeze_status(){
	clear
	init_banner
	echo -e "The freeze status of $USER_LOGIN:"

	USER_INFO=$(eval $LDAPER uid=$USER_LOGIN | grep freezed)

	if [[ "${USER_INFO}" == *"freezed"* ]] ;then
		echo -e "╔═ ✅ ${GREEN}$USER_FIRST_NAME${NO_COLOR} has frezeed his curcus."
		echo -e "║"
		echo -en "╚═ Reason of the freeze: "
		FREEZE_REASON=$(eval $LDAPER uid=$USER_LOGIN | grep freezed | sed 's/close:/ /' | grep 'reason:' | sed 's/^.*: //')
		echo -e $FREEZE_REASON
	else
		echo -e "❌ ${RED}$USER_FIRST_NAME${NO_COLOR} has not frezeed his curcus."
	fi
	prompt_menu
}

get_suspension_status(){
	clear
	init_banner
	echo -e "The suspension status of $USER_LOGIN:"

	USER_INFO=$(eval $LDAPER uid=$USER_LOGIN | grep "close:")

	if [[ "${USER_INFO}" == *"close:"* ]]; then
		SUSPENSION_REASON=$(eval $LDAPER uid=$USER_LOGIN | grep "close:" | sed 's/close: //' | sed 's/^/ - /')
		echo -e "╔═ ✅ ${GREEN}$USER_FIRST_NAME${NO_COLOR} was or is currently suspended."
		echo -e "║"
		echo -en "╚═ Reason(s):\n"
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
3. Freeze status
4. Suspension status
5. 1337 email
6. Open student's intra profile

${YELLOW}Other:${NO_COLOR}
7. Search for another student
8. Useful links for you as a student
9. About the script"

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
		get_suspension_status
	elif [ $chosen_info -eq 5 ]; then
		get_user_mail
	elif [ $chosen_info -eq 6 ]; then
		open_intra_profile
	elif [ $chosen_info -eq 7 ]; then
		init_program
	elif [ $chosen_info -eq 8 ]; then
		get_useful_links
	elif [ $chosen_info -eq 9 ]; then
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

get_user_mail(){
	clear
	init_banner
	echo -en "The 1337 Mail of $USER_LOGIN: "

	USER_MAIL=$(eval $LDAPER uid=$USER_LOGIN | grep "alias:" | awk '{print $2}')

	if [[ -z "$USER_MAIL" ]]; then
		echo -e "${RED}\n❌ We couldn't get the 1337 Mail of ${BGREEN}$USER_FIRST_NAME${RED} because they 
either didn't add it to their profile or an error has ocurred."
	else
		echo -e ${CYAN}$USER_MAIL${NO_COLOR}
	fi

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
3. Overseer
4. 1337 Mailbox
5. Peers Finder
6. Projects XP Calculator
7. Students Leaderboard

${YELLOW}What's next:${NO_COLOR}
8. Go back
9. Exit"

	echo -en "${GREEN}\n> Select: ${NO_COLOR}"
	read -r chosen_info

	if [[ $chosen_info =~ ^[0-9]+$ ]]; then
        chosen_info=$((chosen_info-1))
        if [ $chosen_info -lt ${#USEFUL_LINKS[@]} ]; then
            open "${USEFUL_LINKS[$chosen_info]}"
        fi
    fi

	chosen_info=$((chosen_info+1))

	if [ $chosen_info -eq 8 ]; then
		if [ "$USER_EXISTS" = true ]; then
			prompt_user_menu
		else
			init_program
		fi

	elif [ $chosen_info -eq 9 ]; then 
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

init_program "$@"