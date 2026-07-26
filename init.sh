#!/bin/sh

logmsg(){
	echo "[$(date +%Y-%m-%d-%H-%M)] init.sh:" $@ >> /tmp/myinit.log
}

# $1: basedir to search for a name such as $2
# $2: the name of the xdgruntime directory
get_first_xdgruntimedir(){
	xdgruntime_dirname=$(( ls "$1" 2>/dev/null || echo "" ) | ( grep -e "$2" 2>/dev/null || echo "" ) | head -n 1)
	if test -n "${xdgruntime_dirname}"; then
		echo "$1/${xdgruntime_dirname}"
	else
		echo ""
	fi
}

# The only problem with using 'mktemp' to set XDG_RUNTIME_DIR like this is that
# some applications might still expect XDG_RUNTIME_DIR to be /run/user/${UID}
create_xdgruntimedir_mktemp(){
	if test -d "${XDG_RUNTIME_DIR}"; then
		logmsg "'${XDG_RUNTIME_DIR}' already exists"
		return
	fi

	# use a writable directory which will be consistently available accross reboots
	mybasedir="/tmp"

	# set a name for the xdgruntime directory, you can get creative if you want to :)
	if test -n "${UID:-}"; then
		current_user_id="${UID}"
	else
		current_user_id="$(id -u)"
	fi
	xdg_runtime_dirname="${current_user_id}-runtime-dir"

	# search for any directory such as ${mybasedir}/${xdg_runtime_dirname}* and use it if existent
	existent_xdg_runtime_dir="$(get_first_xdgruntimedir "$mybasedir" "$xdg_runtime_dirname")"

	# set a default name for the XDG_RUNTIME_DIR in case the existent_xdg_runtime_dir isnt found
	default_xdg_runtime_dir_template="${mybasedir}/${xdg_runtime_dirname}"

	# set the XDG_RUNTIME_DIR
	if test -d "${existent_xdg_runtime_dir}"; then
		XDG_RUNTIME_DIR=${existent_xdg_runtime_dir}
	else
		XDG_RUNTIME_DIR=$(mktemp -d "${default_xdg_runtime_dir_template}.XXXXXX")
	fi

	if ! test -d "${XDG_RUNTIME_DIR}"; then
		logmsg "failed when creating XDG_RUNTIME_DIR through mktemp"
		return
	fi

	# check if the XDG_RUNTIME_DIR has the right ownership
	if ! xdg_owner_uid=$(stat -c '%u' "$XDG_RUNTIME_DIR"); then
		logmsg "could not stat '$XDG_RUNTIME_DIR'"
		return
	fi

	if test "${xdg_owner_uid}" != "${current_user_id}"; then
		logmsg "xdg owner uid '${xdg_owner_uid}' of directory '${XDG_RUNTIME_DIR}' does not match with current user id, aborting definition of XDG_RUNTIME_DIR"
		return
	fi

	# check if the XDG_RUNTIME_DIR has the right permissions
	if ! xdg_perms=$(stat -c '%a' "$XDG_RUNTIME_DIR"); then
		logmsg "could not stat '$XDG_RUNTIME_DIR'"
		return
	fi

	if test "${xdg_perms}" != "700"; then
		logmsg "xdg perms (${xdg_perms}) of directory '${XDG_RUNTIME_DIR}' arent 700, aborting definition of XDG_RUNTIME_DIR"
		return
	fi

	# do it just do it
	export XDG_RUNTIME_DIR
}

# The following method requires 'sudo' and for that reason it's not really
# convenient, specially if this script gets used by a display manager to start
# the graphical session of another user
create_xdgruntimedir_mkdir(){
	export XDG_RUNTIME_DIR="/run/user/${UID}"

	if test -d "${XDG_RUNTIME_DIR}"; then
		logmsg "'${XDG_RUNTIME_DIR}' already exists"
		return
	fi

	sudo mkdir --parents ${XDG_RUNTIME_DIR}
	sudo chown ${USER} ${XDG_RUNTIME_DIR}
	sudo chmod 0700 ${XDG_RUNTIME_DIR}
}

# More on $XDG_RUNTIME_DIR: https://specifications.freedesktop.org/basedir-spec/latest/
# Copy and Paste from that link:
#
# $XDG_RUNTIME_DIR defines the base directory relative to which user-specific
# non-essential runtime files and other file objects (such as sockets, named
# pipes, ...) should be stored. The directory MUST be owned by the user, and they
# MUST be the only one having read and write access to it. Its Unix access mode
# MUST be 0700.
# 
# The lifetime of the directory MUST be bound to the user being logged in. It
# MUST be created when the user first logs in and if the user fully logs out the
# directory MUST be removed. If the user logs in more than once they should get
# pointed to the same directory, and it is mandatory that the directory continues
# to exist from their first login to their last logout on the system, and not
# removed in between. Files in the directory MUST not survive reboot or a full
# logout/login cycle.
# 
# The directory MUST be on a local file system and not shared with any other
# system. The directory MUST be fully-featured by the standards of the operating
# system. More specifically, on Unix-like operating systems AF_UNIX sockets,
# symbolic links, hard links, proper permissions, file locking, sparse files,
# memory mapping, file change notifications, a reliable hard link count must be
# supported, and no restrictions on the file name character set should be
# imposed. Files in this directory MAY be subjected to periodic clean-up. To
# ensure that your files are not removed, they should have their access time
# timestamp modified at least once every 6 hours of monotonic time or the
# 'sticky' bit should be set on the file.
#
# OBS1: since this is a manual script and not a real login manager, i don't
#       think it should follow the whole freedesktop spec.
# OBS2: 'create_xdgruntimedir_mktemp' currently tries to reuse an existing
#        XDG_RUNTIME_DIR if that can be found and tries to set the
#        ownership/permissions accordingly, that's about it
create_xdgruntimedir(){
	if test -z "${XDG_RUNTIME_DIR}"; then
		create_xdgruntimedir_mktemp
	else
		logmsg "XDG_RUNTIME_DIR is already set to ${XDG_RUNTIME_DIR}"
	fi
}

run_dwl(){
	dwlcmd=""

	for dwlscript in "$HOME/repos/dwl/startup.sh"; do
		if test -e "${dwlscript}" && test -x "${dwlscript}"; then
			dwlcmd="-s ${dwlscript}"
			break
		fi
	done

	logmsg "dwl command: ${dwlcmd}"

	run_wl_compositor dwl ${dwlcmd}
}

run_wl_compositor(){
	logfile="wl-$(date +%Y-%m-%d-%H-%M).log"

	for logdir in "$HOME/log" "$HOME/tmp" "$HOME" '/tmp' '.'; do
		if test -d "${logdir}" && test -w "${logdir}"; then
			logfile="${logdir}/${logfile}"
			break
		fi
	done

	logmsg "log file: ${logfile}"

	create_xdgruntimedir

	logmsg "XDG_RUNTIME_DIR set to ${XDG_RUNTIME_DIR}"

	# 'dbus-launch'/'dbus-run-session' sets the $DBUS_SESSION_BUS_ADDRESS
	# variable, which refers to a dbus session (used by all processes
	# started from herein)
	#
	# '--exit-with-session' kills all processes and unsets all DBUS_*
	# environment variables that were created by dbus to launch this
	# program when the session/window manager instance terminates. This is
	# sort of a 'cleanup' procedure.
	#
	# The GentooWiki page for DBUS recommends 'dbus-launch
	# --exit-with-session' for this purpose.
	#
	# The manpage of dbus-launch recommends using 'dbus-run-session'
	# instead for sessions running within a text-mode session (such as
	# shells, agetty/elogind/TTY, greetd in text/terminal mode)
	#
	# 'https://wiki.gentoo.org/wiki/Greetd' recommends running
	# 'dbus-run-session' to run a compositor (such as Hyprland) from
	# within a greetd frontend
	#
	# https://dbus.freedesktop.org/doc/dbus-run-session.1.html
	#
	# https://dbus.freedesktop.org/doc/dbus-launch.1.html
	#
	# OBS: Beware that systems using systemd/elogind might not need to
	# use dbus-launch, because those usually set a dbus session
	# automatically on user-login through PAM. On the other hand, this
	# might be necessary in systems that use OpenRC, runit and other
	# initsystems (if they don't use elogind or another PAM-aware
	# mechanism, of course)
	exec dbus-launch --exit-with-session $@ >${logfile} 2>&1
}






###############################################################################
###############################################################################
###############################################################################

case "$1" in
	'dwl')
		run_dwl
	;;
	'labwc'|'sway'|'cwcwm')
		run_wl_compositor "$1"
	;;
	*)
		logmsg "Unknown window manager!"
		echo "run: $0 dwl/sway/labwc/cwcwm"
	;;
esac
