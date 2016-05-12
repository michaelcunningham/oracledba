#!/bin/bash
#set -x
show_menu(){
    YELLBACK=`echo  -e "\033[33;7m"`
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"` #Blue
    NUMBER=`echo "\033[33m"` #yellow
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`
    echo -e "${MENU}***********************************************************${NORMAL}"
    echo -e "${MENU}${YELLBACK}Greetings Oracle legal team. Please ask us any questions!!${NORMAL}"
    echo -e "${MENU}**********************************************************${NORMAL}"
    echo -e "${MENU}**********************************************************${NORMAL}"
    echo -e "${MENU}**${NUMBER} 1)${MENU} See violation for ALL database last week ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 2)${MENU} See violation for a database last week ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 3)${MENU} Run a violation report on a database ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 4)${MENU} See feature changes report on ALL database ${NORMAL}"
    echo -e "${MENU}**${NUMBER} 5)${MENU} See feature changes report on a database ${NORMAL}"
    echo -e "${MENU}***********************************************************${NORMAL}"
    echo -e "${ENTER_LINE}Please enter a menu option and enter or ${RED_TEXT}enter to exit. ${NORMAL}"
    read opt
}
function option_picked() {
COLOR='\033[01;31m' # bold red
RESET='\033[00;00m' # normal white
MESSAGE=${@:-"${RESET}Error: No message passed"}
echo -e "${COLOR}${MESSAGE}${RESET}"
}
clear
show_menu
while [ opt != '' ]
do
    if [[ $opt = "" ]]; then
        exit;
    else
        case $opt in
            1) clear;
                option_picked "See violation for ALL database last week";
                /mnt/dba/admin/license_violation_last_week.sh ALL
                show_menu;
                ;;
            2) clear;
            	option_picked "See violation for a database last week";
                echo "Please enter SID"
                read tns
                /mnt/dba/admin/license_violation_last_week.sh $tns
                show_menu;
                ;;
            3) clear;

                option_picked "Run a violation report on a database";
                echo "Please enter SID"
                read tns
                /mnt/dba/admin/license_violation_report.sh $tns
                show_menu;
                ;;
            4) clear;
                option_picked "Run a violation report on a database";
                /mnt/dba/admin/license_violation_changes.sh ALL 
                show_menu;
                ;;
	    5) clear;
                option_picked "Run a violation report on a database";
                echo "Please enter SID"
                read tns
                /mnt/dba/admin/license_violation_changes.sh $tns 
                show_menu;
                ;;
	    6) clear;
                option_picked "Brought to you by Faisal Al Ramahi";
		echo "Brought to you by Faisal Al Ramahi"
                show_menu;
                ;;

            x)exit;
                ;;
            \n)exit;
                ;;
            *)clear;
                option_picked "Pick an option from the menu";
                show_menu;
                ;;
        esac
    fi
done

