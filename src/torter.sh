#!/bin/sh
# Created by Jacob Hrbek <kreyren@rixotstudio.cz> under GPLv3 <https://www.gnu.org/licenses/gpl-3.0.en.html> in 19/05/2020 13:03 CET

# DNM: Leonid has 62.5 MiB/s -> Expecting speed of 10.0 MiB/s or faster -> 10.0000000000*1024*1024=10485760
# For entry: curl https://onionoo.torproject.org/details 2>/dev/null | grep -oP "^\{.*\}" | grep -oP "^\{.*flags.*\[.*Guard.*\]\}" | sed -E "s#(^\{.*or_addresses\":\[\")(\w+\.\w+\.\w+\.\w+)(\:\w+)(.*\"\].*\})#\2#gm" | tr '\n' ' '
# For the exit: curl https://onionoo.torproject.org/details 2>/dev/null | grep -oP "^\{.*\}" | grep -oP "^\{.*flags.*\[.*Exit.*\]\}" | sed -E "s#(^\{.*or_addresses\":\[\")(\w+\.\w+\.\w+\.\w+)(\:\w+)(.*\"\].*\})#\2#gm" | tr '\n' ','

# 83874816/1024/1024 = 79.9892578125
###! Configure Tor's torrc to use relays suitable for fast connection
###! Uses data from https://onionoo.torproject.org/details
###! Calculating the mirror speed from the json file
###! - SPEED/1024/1024 = Speed in megabytes
###! - Example: 83874816/1024/1024 = 79.9892578125 MiB/s
###! PLATFORMS:
###! - Linux) Expected to work
###! - FreeBSD) Requires testing
###! - Darwin) Requires testing
###! - Redox) Not expected to work as of 19/05/2020 -> Made as gesture to support Redox development <3
###! - Windows) Requires sh to be exported for windows kernel
###! - Windows/Cygwin) Requires testing
###! - ReactOS) Requires sh to be exported for ReactOS kernel
###! EXIT CODES:
###! - 0) Success on UNIX - OR - General FATAL on Windows
###! - 1) General FATAL error on UNIX - OR - Success on Windows
###! - 27) Fatal FIXME message - Used for unimplemented features
###! - 36) Self-check failed - Used for code-bugs where logic doesn't do what it is supposed to
###! - 83) die() bug - When unexpected argument has been parsed in die() while still outputting the error message from code
###! - 255) Unexpected trap - Used for sanitization to capture code issues

# FIXME: Replace mensioning of 'directory' with 'folder' on windows and vise-versa on UNIX (https://devblogs.microsoft.com/oldnewthing/20110216-00/?p=11473)
# FIXME: formatting string errors has to be more helpful
# FIXME: Implement replacing of default commands

# Exit the script on anything unexpected
set -e

# FIXME: Sanitize these
myName="torter script"
UPSTREAM="FIXME: somewhere"

# Customization of the output
# FIXME-QA: Resolve duplicate code
# FIXME: edebug() is not reachable here
## die() - FATAL
if [ -z "$DIE_FORMAT_STRING_FATAL" ]; then
	DIE_FORMAT_STRING_FATAL="FATAL($myName): %s\\n"
elif [ -n "$DIE_FORMAT_STRING_FATAL" ]; then
	edebug 1 "die output using variable DIE_FORMAT_STRING_FATAL is customized using '$DIE_FORMAT_STRING_FATAL'"
else
	die 255 "processing DIE_FORMAT_STRING_FATAL"
fi
## die() - SUCCESS
if [ -z "$DIE_FORMAT_STRING_SUCCESS" ]; then
	DIE_FORMAT_STRING_SUCCESS="%s\\n"
elif [ -n "$DIE_FORMAT_STRING_SUCCESS" ]; then
	edebug 1 "die output using variable DIE_FORMAT_STRING_SUCCESS is customized using '$DIE_FORMAT_STRING_SUCCESS'"
else
	printf 'FATAL: %s\n' "processing DIE_FORMAT_STRING_SUCCESS"
	exit 255
fi
## die() - 27|FIXME
if [ -z "$DIE_FORMAT_STRING_27" ]; then
	DIE_FORMAT_STRING_27="FIXME($myName): %s\\n"
elif [ -n "$DIE_FORMAT_STRING_27" ]; then
	edebug 1 "die output using variable DIE_FORMAT_STRING_SUCCESS is customized using '$DIE_FORMAT_STRING_SUCCESS'"
else
	printf 'FATAL: %s\n' "processing DIE_FORMAT_STRING_27"
	exit 255
fi
## die() - 36
if [ -z "$DIE_FORMAT_STRING_36" ]; then
	DIE_FORMAT_STRING_36="FATAL($myName): Self-check for %s failed\\n"
elif [ -n "$DIE_FORMAT_STRING_36" ]; then
	edebug 1 "die output using variable DIE_FORMAT_STRING_36 is customized using '$DIE_FORMAT_STRING_36'"
else
	printf 'FATAL: %s\n' "processing DIE_FORMAT_STRING_36"
	exit 255
fi
## die() - 255
if [ -z "$DIE_FORMAT_STRING_255" ]; then
	DIE_FORMAT_STRING_255="FATAL($myName): Unexpected happend while %s\\n"
elif [ -n "$DIE_FORMAT_STRING_255" ]; then
	edebug 1 "die output using variable DIE_FORMAT_STRING_255 is customized using '$DIE_FORMAT_STRING_255'"
else
	printf 'FATAL: %s\n' "processing DIE_FORMAT_STRING_255"
	exit 255
fi

# Date format - Uses ISO 8601 by default
# FIXME: Sanitize and allow customization
# NOTICE(Krey): Do not cache the value since we are expecting this to output different date each time it's called
DATE_FORMAT="[ $(date -u +"%Y-%m-%dT%H:%M:%SZ") ] "

die() {
	case "$1" in
		0)
			# FIXME: Sanitycheck for uname
			case "$(uname -s)" in
				Linux|FreeBSD|Redox)
					printf "$DIE_FORMAT_STRING_SUCCESS" "$2" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_SUCCESS is invalid" ; exit 111 ;}
					printf "$DATE_FORMAT$DIE_FORMAT_STRING_SUCCESS" "$2" >> "$logLocation" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_SUCCESS is invalid" ; exit 111 ;}
				;;
				Windows)
					printf "$DIE_FORMAT_STRING_FATAL" "$2" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_FATAL is invalid" ; exit 111 ;}
					printf "$DATE_FORMAT$DIE_FORMAT_STRING_FATAL" "$2" >> "$logLocation" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_FATAL is invalid" ; exit 111 ;}
				;;
				*)
					die 255 "processing kernel '$(uname -s)'"
				;;
			esac
		;;
		1)
			# FIXME: Sanitycheck for uname
			case "$(uname -s)" in
				Linux|FreeBSD|Redox)
					printf "$DIE_FORMAT_STRING_FATAL" "$2" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_FATAL is invalid" ; exit 111 ;}
					printf "$DATE_FORMAT$DIE_FORMAT_STRING_FATAL" "$2" >> "$logLocation" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_FATAL is invalid" ; exit 111 ;}
				;;
				Windows)
					printf "$DIE_FORMAT_STRING_SUCCESS" "$2" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_SUCCESS is invalid" ; exit 111 ;}
					printf "$DATE_FORMAT$DIE_FORMAT_STRING_SUCCESS" "$2" >> "$logLocation" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_SUCCESS is invalid" ; exit 111 ;}
				;;
				*)
					die 255 "processing kernel '$(uname -s)'"
				;;
			esac
		;;
		27|fixme)
			printf "$DIE_FORMAT_STRING_27" "$2" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_27 is invalid" ; exit 111 ;}
			printf "$DATE_FORMAT$DIE_FORMAT_STRING_27" "$2" >> "$logLocation" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_27 is invalid" ; exit 111 ;}
		;;
		36)
			printf "$DIE_FORMAT_STRING_36" "$2" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_SUCCESS is invalid" ; exit 111 ;}
			printf "$DATE_FORMAT$DIE_FORMAT_STRING_36" "$2" >> "$logLocation" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string DIE_FORMAT_STRING_SUCCESS is invalid" ; exit 111 ;}
		;;
		255)
			printf "$DIE_FORMAT_STRING_255" "$2"
			printf "$DATE_FORMAT$DIE_FORMAT_STRING_255" "$2" >> "$logLocation"
		;;
		*)
			# FIXME: Implement logging
			printf "BUG($myName): %s\n" "Invalid argument has been parsed in die function, please file a new issue in $UPSTREAM"
			printf 'FATAL: %s\n' "$2" | tee -a "$logLocation"
			exit 83 # Used for die bug
	esac

	exit "$1"

	# In case exit above doesn't work
	printf 'BUG: %s\n' "Invalid exit code parsed in die() function -> exiting with 83, please file a new issue on $UPSTREAM about this"
	exit 83
}
edebug() {
	# FIXME: Implement other channels
	case "$DEBUG" in
		1)
			case "$1" in
				1)
					if [ "$DEBUG" = 1 ]; then
						printf 'DEBUG: %s\n' "$2"
						return 0
					elif [ "$DEBUG" = 0 ] || [ -z "$DEBUG" ]; then
						true
						return 0
					else
						die 255 "procesing edebug 1 with value"
					fi
				;;
			esac
		;;
		0|"")
			true
		;;
		*)
			# FIXME: Implement skipping this with env var
			die 28 "Unexpected value '$DEBUG' is stored in DEBUG variable, allowed values are: '1', '0' or ''"
	esac
}
einfo() {
	printf "$EINFO_FORMAT_STRING" "$1"
	printf "$DATE_FORMAT$EINFO_FORMAT_STRING" "$1" >> "$logLocation"
	return 0
}
ewarn() {
	printf "$EWARN_FORMAT_STRING" "$1"
	printf "$DATE_FORMAT$EWARN_FORMAT_STRING" "$1" >> "$logLocation"
	return 0
}
eerror() {
	printf "$EERROR_FORMAT_STRING" "$1"
	printf "$DATE_FORMAT$EERROR_FORMAT_STRING" "$1" >> "$logLocation"
	return 0
}
efixme() {
	printf "$EFIXME_FORMAT_STRING" "$1"
	printf "$DATE_FORMAT$EFIXME_FORMAT_STRING" "$1" >> "$logLocation"
	return 0
}
ebench() {
	# FIXME: Implement
	case "$1" in
		start)
			printf "$EBENCH_FORMAT_STRING_START" "$1" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string EDEBGU_FORMAT_STRING is invalid" ; exit 111 ;}
			SECONDS=0
			return 0 ;;
		result)
			printf "$EBENCH_FORMAT_STRING_RESULT" "$1" || { printf 'FORMAT-STRING-ERROR: %s\n' "Format string EDEBGU_FORMAT_STRING is invalid" ; exit 111 ;}
			return 0 ;;
		*) die 2 "$1 TEST"
esac
}

# Identify system
if command -v uname 1>/dev/null; then
	# Identify distribution
	case "$(uname -s)" in
		Linux)
			# Used for path to store logs in
			if [ "$(id -u)" = 0 ]; then
				# FIXME: Make sure that /var/log exists
				logLocation="/var/log/$myName.log"
			elif [ "$(id -u)" = 1000 ]; then
				# FIXME: Make sure that the path exists
				logLocation="$HOME/.$myName.log"
			fi

			if [ -f /etc/os-release ]; then
				DISTRO="$(grep -o "ID\=.*" /etc/os-release)"
					DISTRO="${DISTRO##ID=}"
			elif [ ! -f /etc/os-release ] && command -v lsb_release 1>/dev/null; then
				# FIXME: This stores 'Debian' where 'debian' is expected (on debian system)
				DISTRO="$(lsb_release -si)"
			elif [ ! -f /etc/os-release ] && ! command -v lsb_release 1>/dev/null; then
				die 1 "Unable to identify this $(uname -s) system through /etc/os-release (which doesn't exists!) and through lsb_release (which is not executable in this environment)"
			else
				die 255 "indentifying distro with value DISTRO value '$DISTRO'"
			fi
		;;
		FreeBSD|Darwin|Windows) die fixme "Kernel '$(uname -s)' is currently not supported by $myName since it was not tested" ;;
		Redox) die fixme "$(uname -s) is currently not supported assuming that their sh is not in working state, current implementation is made to show support for redox development, let us know if redox can run this script on $UPSTREAM" ;;
		*) die 255 "processing kernel '$(uname -s)'"
	esac
elif ! command -v uname 1>/dev/null; then
	die 1 "Command 'uname' is not executable on this environment -> Unable to identify the system"
else
	die 255 "identifying the system"
fi

# Initialize the script in log
einfo "Started $myName"

# Resolve root
if [ "$(id -u)" = 0 ]; then
	edebug 1 "$myName has been executed on root, no need to elevate it"
	unset SUDO
elif [ "$(id -u)" = 1000 ]; then
	ewarn "This script is designed to work on root which was not provided, trying to elevate.."
	sleep 3 # In case end-user wants to terminate it
	if command -v sudo 1>/dev/null; then
		SUDO=sudo
	elif ! command -v sudo 1>/dev/null; then
		die 3 "$myName was unable to elevate root on this environment assuming $myName executed as non-root without access to sudo"
	else
		die 255 "elevating using sudo"
	fi
else
	die 255 "processing unexpected user with ID '$(id -u)'"
fi

# Check if curl is available, if not try to resolve it
if ! command -v curl 1>/dev/null; then
	case "$DISTRO" in
		debian|Debian)
			if command -v apt 1>/dev/null; then
				case "$(apt list curl 2>/dev/null | grep -m1 curl)" in
					curl/*)
						edebug 1 "curl is installable on this environment"
					;;
					"")
						ewarn "Command 'curl' is not installable on this environment, trying to sync repositories.."
						# NOTICE(Krey): Do not double-quote - Spaces expected
						$SUDO apt update || die 1 "Unable to update apt repositories on $DISTRO"

						# Self-check
						case "$(apt list curl 2>/dev/null | grep -m1 curl)" in
							curl/*) edebug 1 "Curl is now available after apt updating it's repositories, self-check passed" ;;
							"") die 36 "making sure that curl is installable on this environment" ;;
							*) die 255 "self-checking for curl command"
						esac
					;;
					*) die 255 "checking for curl command"
				esac

				# NOTICE(Krey): Do not double-quote - Spaces expected
				$SUDO apt install -y curl || die 1 "Unable to install curl on this environment"
			fi
		;;
		*) die fixme "Unsupported distribution '$DISTRO', has been parsed in $myName -> Unable to get requried curl which is not executable in this environment"
	esac

	# Self-check
	if ! command -v curl 1>/dev/null; then
		die 36 "processing curl"
	elif command -v curl 1>/dev/null; then
		edebug 1 "curl is available on this environment which passed self-check"
	else
		die 255 "self-checking executability of curl command"
	fi
fi

# FIXME: Regex
