#!/bin/bash

init_program() {
	exec 2> /dev/null
	clear
	echo "Enter the user login:"
	read -a usr
	username=${usr}
	clear
	echo -e "--- Choose the information you need ---\n1. Get phone number.\n2. Get full name.\n\nSelect:"
	read -a var
	chosen_info=${var}

	check_if_user_exists
	
	if [ $chosen_info -eq 1 ]; then
		get_user_phone
	elif [ $chosen_info -eq 2 ]; then
		get_user_full_name
	else
		echo "Wrong input."
	fi

	promt_menu
}

check_if_user_exists() {
	if [ldapsearch uid=$username | grep givenName | wc -l   ]; then
		echo "User does not exist."
		exit 1
	fi
}

get_user_phone(){
	clear
	echo "--- The phone number of $username ---"
	ldapsearch uid=$username | grep mobile: | awk '{print $2}'
}
cccc
get_user_full_name(){
	clear
	echo "--- The full name of $username ---"
	ldapsearch uid=$username | grep cn: | awk '{print $2 " " $3 " " $4}'
}

promt_menu(){
	echo -e "\n\nWhat do you want to do?\n1. Go back to the main menu.\n2. Exit.\n\nSelect:"

	read -a reset_option
	if [ $reset_option -eq 1 ]; then
		init_program
	else
		exit
	fi
}

init_program