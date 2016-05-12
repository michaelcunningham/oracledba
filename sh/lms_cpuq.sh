#!/bin/sh

SCRIPT_VERSION="1.05"
SCRIPT_NAME=${0}

##########################################################################################
#	
# THE SCRIPT TOOL IS PROVIDED "AS IS" AND WITHOUT WARRANTY. CUSTOMER'S USE OF THE
# SCRIPT TOOL IS AT CUSTOMER'S OWN RISK. BEA EXPRESSLY DISCLAIMS ANY AND ALL
# WARRANTIES, EXPRESS OR IMPLIED, INCLUDING ANY IMPLIED WARRANTIES OF MERCHANTABILITY,
# NON INFRINGEMENT OR FITNESS FOR A PARTICULAR PURPOSE, WHETHER ARISING IN LAW, CUSTOM,
# CONDUCT, OR OTHERWISE.
#
##########################################################################################



################################################################################
#
# this script is used to gather Operating System information for use by the
# Oracle LMS team
#
################################################################################



################################################################################
#
#********************Hardware Identification and Detection**********************
#
################################################################################


################################################################################
#
# time stamp
#

setTime() {

	# set time
	NOW="`date '+%m/%d/%Y %H:%M %Z'`"

}


##############################################################
# make echo more portable
#

echo_print() {
  #IFS=" " command 
  eval 'printf "%b\n" "$*"'
} 


################################################################################
#
# expand debug output
#

echo_debug() {
 
	if [ "$DEBUG" = "true" ] ; then
		$ECHO "$*" 
		$ECHO "$*" >> $ORA_DEBUG_FILE	 
	fi
	
} 

setOutputFiles() {



	FILE_EXT=${$}

	# set tmp directory and files we will use in the script
	TMPDIR="${TMPDIR:-/tmp}"
	ORA_IPADDR_FILE=$TMPDIR/oraipaddrs.$FILE_EXT

	# this wil allow us to pass the ORA_MACHINE_INFO file name 
	# from a calling shell script
	ORA_MACHINFO_FILE=${1:-${TMPDIR}/${MACHINE_NAME}-lms_cpuq.txt} 

	ORA_PROCESSOR_FILE=$TMPDIR/$MACHINE_NAME-proc.txt

	# debug and error files
	ORA_DEBUG_FILE=$TMPDIR/oradebugfile.$FILE_EXT
	UNIXCMDERR=${TMPDIR}/unixcmderrs.$FILE_EXT

	
	$ECHO_DEBUG "\ndebug.function.setOutputFiles"
}

################################################################################
#
# set parameters based on user and hardware
#

setOSSystemInfo() {

	# debug
	$ECHO_DEBUG "\ndebug.function.setOSSystemInfo"

	USR_ID=$LOGNAME
	
	if [ "$USR_ID" = "root" ] ; then
		SCRIPT_USER="ROOT"
	else
		SCRIPT_USER=$LOGNAME
	fi
	
	SCRIPT_SHELL=$SHELL
	TAIL="tail -200"
	
	if [ "$OS_NAME" = "Linux" ] ; then
		set -xv	
		cat /proc/cpuinfo 
		set +xv
		if [ "$SCRIPT_USER" = "ROOT" ] ; then
			set -xv
			dmidecode --type processor
			dmidecode --type system | egrep -i 'system information|manufacturer|product'
			set +xv
		else
			$ECHO "dmidecode command not executed - $SCRIPT_USER insufficient privileges"
		fi
		RELEASE=`uname -r`
		IPADDR=`/sbin/ifconfig | grep inet | awk '{print $2}' | sed 's/addr://'`
		TAIL="tail -n 200"
	elif [ "$OS_NAME" = "SunOS" ] ; then
		set -xv
		/usr/sbin/prtconf 
		/usr/sbin/prtdiag
		set +xv
		/usr/sbin/psrinfo -p > /dev/null 2>&1
		isPoptionSupported=${?}

		if [ ${isPoptionSupported} -eq  0 ]
		then
			set -xv
			/usr/sbin/psrinfo -vp
			set +xv
		else
			set -xv
			/usr/sbin/psrinfo -v 
			set +xv
		fi
		RELEASE=`uname -r`
		IPADDR=`grep $MACHINE_NAME /etc/hosts | awk '{print $1}'`
		TAIL="tail -200"
	elif [ "$OS_NAME" = "HP-UX" ] ; then
		set -xv
		/usr/sbin/ioscan -fkC processor 
		set +xv
		RELEASE=`uname -r`
		IPADDR=`grep $MACHINE_NAME /etc/hosts | awk '{print $1}'`
		TAIL="tail -200"
		if [ -x /usr/contrib/bin/machinfo ] ; then
			set -xv
			/usr/contrib/bin/machinfo 
			set +xv
		fi
	elif [ "$OS_NAME" = "AIX" ] ; then
		set -xv
		uname -Mm
		lsdev -Cc processor 
		/usr/sbin/prtconf 
		set +xv
		if [ -x /usr/bin/lparstat ] ; then
			set -xv
			/usr/bin/lparstat -i
			set +xv
		fi
		if [ -x /usr/sbin/lsattr ] ; then
			for PROC in `lsdev -Cc processor | cut -d' ' -f1`
			do
				set -xv
				/usr/sbin/lsattr -El ${PROC}
				set +xv
			done
		fi
		RELEASE="`uname -v`.`uname -r`"
		RELEASE="`uname -v`.`uname -r`"
		IPADDR=`grep $MACHINE_NAME /etc/hosts | awk '{print $1}'` 
		TAIL="tail -200"
	elif [ "$OS_NAME" = "OSF1" ] ; then
		set -xv
		/usr/sbin/psrinfo -v
		set +xv
		IPADDR=`grep $MACHINE_NAME /etc/hosts | awk '{print $1}'` 
		TAIL="tail -200"
	fi
	
	# populate IP adresses to file
	$ECHO "$IPADDR" > $ORA_IPADDR_FILE
	
}


################################################################################
#
# output welcome message.
#

beginMsg()
{
$ECHO "\n*******************************************************************************" >&2
	$ECHO   "Oracle License Management Services License Terms (press enter to scroll through message)

Export Controls on the Programs 

Inputting \"y\" at the \"Accept License Agreement\" prompt is a confirmation
of your agreement that you comply, now and during the trial term, with each of
the following statements: 

-You are not a citizen, national, or resident of, and are not under control of,
the government of Cuba, Iran, Sudan, Libya, North Korea, Syria, nor any country
to which the United States has prohibited export. 

-You will not download or otherwise export or re-export the Programs, directly
or indirectly, to the above mentioned countries nor to citizens, nationals or
residents of those countries. 

-You are not listed on the United States Department of Treasury lists of
Specially Designated Nationals, Specially Designated Terrorists, and
Specially Designated Narcotic Traffickers, nor are you listed on the
United States Department of Commerce Table of Denial Orders 

You will not download or otherwise export or re-export the Programs, directly
or indirectly, to persons on the above mentioned lists. 

You will not use the Programs for, and will not allow the Programs to be used
for, any purposes prohibited by United States law, including, without
limitation, for the development, design, manufacture or production of nuclear,
chemical or biological weapons of mass destruction. 

   EXPORT RESTRICTIONS 
You agree that U.S. export control laws and other applicable export and import
laws govern your use of the programs, including technical data; additional
information can be found on Oracle's Global Trade Compliance web
site (http://www.oracle.com/products/export). 

   You agree that neither the programs nor any direct product thereof will be
exported, directly, or indirectly, in violation of these laws, or will be used
for any purpose prohibited by these laws including, without limitation,
nuclear, chemical, or biological weapons proliferation. 
   The LMS License Agreement terms below supersede any other license terms.

   Oracle License Management Services Development License Agreement 

\"We,\" \"us,\" and \"our\" refers to Oracle USA, Inc., for and on behalf of itself
and its subsidiaries and affiliates under common control. \"You\" and \"your\"
refers to the individual or entity that wishes to use the programs from Oracle.
\"Programs\" refers to the Oracle software product you wish to access via CD/DVD
and use and program documentation. \"License\" refers to your right to use the
programs under the terms of this agreement. This agreement is governed by the
substantive and procedural laws of California. You and Oracle agree to submit
to the exclusive jurisdiction of, and venue in, the courts of San Francisco,
San Mateo, or Santa Clara counties in California in any dispute arising out of
or relating to this agreement. 

   We are willing to license the programs to you only upon the condition that
you accept all of the terms contained in this agreement. Read the terms
carefully and select the \"Accept License Agreement\" button to confirm your
acceptance. If you are not willing to be bound by these terms, select the
\"Decline License Agreement\" button and the registration process will not
continue. 

   LICENSE RIGHTS 
We grant you a nonexclusive, nontransferable limited license to use the
programs only for the purpose of measuring and monitoring your usage of Oracle
Programs, and not for any other purpose. We may audit your use of the programs.
Program documentation will be provided with the tool. 
   Ownership and Restrictions 
We retain all ownership and intellectual property rights in the programs.
The programs may be installed on one or more servers; provided, however, you
may make one copy of the programs for backup or archival purposes. 
   You may not: - use the programs for your own internal data processing or
for any commercial or production purposes, or use the programs for any purpose
except the purpose stated herein; 

- use the application for any commercial or production purposes;   
- remove or modify any program markings or any notice of our proprietary rights; 

- make the programs available in any manner to any third party, without the
prior written approval of Oracle; 

- use the programs to provide third party training; 

- assign this agreement or give or transfer the programs or an interest in
them to another individual or entity; - cause or permit reverse engineering
(unless required by law for interoperability), disassembly or decompilation
of the programs; 

- disclose results of any program benchmark tests without our prior consent;
or, - use any Oracle name, trademark or logo. 
   Export 
You agree that U.S. export control laws and other applicable export and import
laws govern your use of the programs, including technical data; additional
information can be found on Oracle's Global Trade Compliance web site located
at http://www.oracle.com/products/export/index.html?content.html. You agree
that neither the programs nor any direct product thereof will be exported,
directly, or indirectly, in violation of these laws, or will be used for any
purpose prohibited by these laws including, without limitation, nuclear,
chemical, or biological weapons proliferation. 

   Disclaimer of Warranty and Exclusive Remedies 
   THE PROGRAMS ARE PROVIDED \"AS IS\" WITHOUT WARRANTY OF ANY KIND. WE FURTHER
DISCLAIM ALL WARRANTIES, EXPRESS AND IMPLIED, INCLUDING WITHOUT LIMITATION,
ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
NON INFRINGEMENT. 
   IN NO EVENT SHALL WE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL,
PUNITIVE OR CONSEQUENTIAL DAMAGES, OR DAMAGES FOR LOSS OF PROFITS, REVENUE,
DATA OR DATA USE, INCURRED BY YOU OR ANY THIRD PARTY, WHETHER IN AN ACTION IN
CONTRACT OR TORT, EVEN IF WE HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES. OUR ENTIRE LIABILITY FOR DAMAGES HEREUNDER SHALL IN NO EVENT EXCEED
ONE THOUSAND DOLLARS (U.S. $1,000). 
   No Technical Support 
Our technical support organization will not provide technical support, phone
support, or updates to you for the programs licensed under this agreement. 
   End of Agreement 
You may terminate this agreement by destroying all copies of the programs. We
have the right to terminate your right to use the programs if you fail to
comply with any of the terms of this agreement, in which case you shall
destroy all copies of the programs. 
   Relationship Between the Parties 
The relationship between you and us is that of licensee/licensor. Neither party
will represent that it has any authority to assume or create any obligation,
express or implied, on behalf of the other party, nor to represent the other
party as agent, employee, franchisee, or in any other capacity. Nothing in
this agreement shall be construed to limit either party's right to
independently develop or distribute software that is functionally similar to
the other party's products, so long as proprietary information of the other
party is not included in such software. 
   Open Source 
\"Open Source\" software - software available without charge for use,
modification and distribution - is often licensed under terms that require the
user to make the user's modifications to the Open Source software or any
software that the user 'combines' with the Open Source software freely
available in source code form. If you use Open Source software in conjunction
with the programs, you must ensure that your use does not: (i) create, or
purport to create, obligations of us with respect to the Oracle programs;
or (ii) grant, or purport to grant, to any third party any rights to or
immunities under our intellectual property or proprietary rights in the Oracle
programs. For example, you may not develop a software program using an Oracle
program and an Open Source program where such use results in a program file(s)
that contains code from both the Oracle program and the Open Source program
(including without limitation libraries) if the Open Source program is licensed
under a license that requires any \"modifications\" be made freely available.
You also may not combine the Oracle program with programs licensed under the
GNU General Public License (\"GPL\") in any manner that could cause, or could be
interpreted or asserted to cause, the Oracle program or any modifications
thereto to become subject to the terms of the GPL. 
   Entire Agreement 
You agree that this agreement is the complete agreement for the programs and
licenses, and this agreement supersedes all prior or contemporaneous agreements
or representations. If any term of this agreement is found to be invalid or
unenforceable, the remaining provisions will remain effective. 
   Last updated: 11/05/07 
   Should you have any questions concerning this License Agreement, or if you
desire to contact Oracle for any reason, please write: 

Oracle USA, Inc. 
500 Oracle Parkway 
Redwood City, CA 94065 
\n" | more


ANSWER=

$ECHO "Accept License Agreement? "
	while [ -z "${ANSWER}" ]
	do
		$ECHO "$1 [y/n/q]: \c" >&2
  	read ANSWER
		#
		# Act according to the user's response.
		#
		case "${ANSWER}" in
			Y|y)
				return 0     # TRUE
				;;
			N|n|Q|q)
				exit 1     # FALSE
				;;
			#
			# An invalid choice was entered, reprompt.
			#
			*) ANSWER=
				;;
		esac
	done
}


################################################################################
#
# print out the search header
#

printMachineInfo() {
	
	NUMIPADDR=0
	
	# print script information
	$ECHO "[BEGIN SCRIPT INFO]"
	$ECHO "Script Name=$SCRIPT_NAME"
	$ECHO "Script Version=$SCRIPT_VERSION"
	$ECHO "Script Command options=$SCRIPT_OPTIONS"
	$ECHO "Script Command shell=$SCRIPT_SHELL"
	$ECHO "Script Command user=$SCRIPT_USER"
	$ECHO "[END SCRIPT INFO]"

	# print system information
	$ECHO "[BEGIN SYSTEM INFO]"
	$ECHO "Machine Name=$MACHINE_NAME"
	$ECHO "Operating System Name=$OS_NAME"
	$ECHO "Operating System Release=$RELEASE"

	for IP in `cat $ORA_IPADDR_FILE`
	do
		NUMIPADDR=`expr ${NUMIPADDR} + 1`
		$ECHO "System IP Address $NUMIPADDR=$IP"
	done
	
	cat ${ORA_PROCESSOR_FILE}

	$ECHO "[END SYSTEM INFO]"



}


################################################################################
#
#*********************************** MAIN **************************************
#
################################################################################

umask 022

# command line defaults
SCRIPT_OPTIONS=${*}
OUTPUT_DIR="."
LOG_FILE="true"
DEBUG="false"

# initialize script values
# set up default os non-specific machine values
OS_NAME=`uname -s`
MACHINE_NAME=`uname -n`

# set up $ECHO
ECHO="echo_print"

# set up $ECHO for debug
ECHO_DEBUG="echo_debug"

# if ${1} is set then we probably got called from checkBEAinst.sh and we  
# don't need to print the license agreement
if [ "${1}" = "" ]; then
	# print welcome message
	beginMsg 
fi

# set output files
setOutputFiles ${1}

# set current system info
setOSSystemInfo> $ORA_PROCESSOR_FILE 2>&1

# search start time
setTime
SEARCH_START=$NOW
$ECHO "\nScript started at $SEARCH_START"

if [ -s $ORA_MACHINFO_FILE ]; then
	# files exists so append
	printMachineInfo >> $ORA_MACHINFO_FILE 2>>$UNIXCMDERR
else
	printMachineInfo > $ORA_MACHINFO_FILE 2>>$UNIXCMDERR
fi

if [ -s $UNIXCMDERR ];
then
	cat $UNIXCMDERR >> $ORA_MACHINFO_FILE
fi

# search finish time
setTime
SEARCH_FINISH=$NOW

# if ${1} is set then we probably got called from checkBEAinst.sh and we  
# don't need to print the following
if [ "${1}" = "" ] ; then
	$ECHO "\nScript $SCRIPT_NAME finished at $SEARCH_FINISH"

	$ECHO "\nPlease collect the output file generated: $ORA_MACHINFO_FILE"
fi

# delete the tmp files
rm -rf $ORA_IPADDR_FILE $ORA_DEBUG_FILE $ORA_PROCESSOR_FILE $UNIXCMDERR 2>/dev/null

exit 0
