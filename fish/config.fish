if status is-interactive
	# Commands to run in interactive sessions can go here

	#######################################
	########## Static variables ###########
	#######################################

	# set LANG 'de_DE.UTF-8'
	set -x GMAIL 'cd.vieira14@gmail.com'
	set -x OUTLOOK 'cd_vieira@hotmail.com'
	set -x EMAIL $GMAIL
	set -x GPG_TTY "$(tty)"

	# xdg user directories
	# analogous to /etc
	set -x XDG_CONFIG_HOME "$HOME/.config"

	# analogous to /var/cache
	set -x XDG_CACHE_HOME "$HOME/.cache"

	# analogous to /usr/share
	set -x XDG_DATA_HOME "$HOME/.local/share"

	# analogous to /var/lib
	set -x XDG_STATE_HOME "$HOME/.local/state"

	# according to 'man portals.conf' and the XDG Specification, this gets
	# used when loading the '.conf' file for '/usr/libexec/xdg-desktop-portal'.
	# All '.conf' files can be found under /usr/share/xdg-desktop-portal/.
	# By default, '/usr/share/xdg-desktop-portal/portals.conf' gets used,
	# but we can use another one more suitable for the desktop in use (dwl),
	# like '/usr/share/xdg-desktop-portal/wlroots-portals.conf'.
	# set -x XDG_CURRENT_DESKTOP wlroots

	# 'pam_systemd' sets XDG_RUNTIME_DIR automatically
	# set -x XDG_RUNTIME_DIR "/run/user/$UID"

	# both are analogous to PATH
	# set -x XDG_DATA_DIRS "/usr/local/share:/usr/share"
	# set -x XDG_CONFIG_DIRS "/etc/xdg"

	# After fish 4.3, the 'fish_key_bindings' variable no longer has
	# universal scope, but rather global scope
	set --global fish_key_bindings fish_default_key_bindings

	# set script variable to help detecting the current linux distro
	if test -e /etc/os-release
		set LINUX_DISTRO_NAME (cat /etc/os-release | grep "^NAME" | awk -F"=" '{ print $2 }' | tr -d "'")
	end



	#######################################
	######### Dynamic variables ###########
	#######################################

	set add_to_path \
		"$HOME/.local/bin" \
		"$HOME/.cargo/bin" \
		"$HOME/.yarn/bin" \
		"/opt/riscv/bin" \
		"/opt/riscv32/bin" \
		"/usr/local/texlive/$(date +%Y)/bin/x86_64-linux"

	for dirpath in $add_to_path
		if test -d $dirpath; and not contains $dirpath $PATH
			set -x PATH $PATH $dirpath
		end
	end

	# set EDITOR env var
	set editors 'nvim' 'vim' 'micro' 'nano' 'less'
	for editor in $editors
		if type -q $editor
			set -x EDITOR "$editor"
			break
		end
	end

	# in case neovim is installed, use it as pager
	if type -q 'nvim'
		set -x MANPAGER 'nvim +Man!'
	end

	# in case qutebrowser is installed, use it as def browser
	# if type -q 'qutebrowser'
	# 	# https://github.com/qutebrowser/qutebrowser/blob/main/misc/org.qutebrowser.qutebrowser.desktop
	# 	set qutebrowser_desktop_files \
	# 		'/usr/local/applications/org.qutebrowser.qutebrowser.desktop' \
	# 		'/usr/share/applications/org.qutebrowser.qutebrowser.desktop'
	# 	for desktop_file in $qutebrowser_desktop_files
	# 		if test -e $desktop_file
	# 			xdg-settings set default-web-browser org.qutebrowser.qutebrowser.desktop
	# 			set -x BROWSER 'org.qutebrowser.qutebrowser.desktop'
	# 		end
	# 	end
	# end



	#######################################
	############## Aliases ################
	#######################################

	alias ls 'ls --group-directories-first --color=auto'
	alias la 'ls --group-directories-first --color=auto -la'
	alias view 'vim -R'
	alias dmesg 'dmesg -H'
	alias info 'info --vi-keys'
	alias nv 'nvim'

	# in case lynx is installed, override its default cfg file with ours
	if type -q 'lynx'; and test -e ~/repos/dotfiles/lynx/lynx.cfg
		alias lynx 'lynx -cfg=~/repos/dotfiles/lynx/lynx.cfg'
	end
	
	# shortcut tmux to automatically open my most used folders
	# if type -q 'tmux'
	# 	alias tmux "tmux new-session -c ~/repos/dotfiles -n dotfiles \; \
	# 		new-window -c ~/repos/notes -n notes \; \
	# 		new-window -c ~/repos/code -n code \; "
	# end



	#######################################
	########### Abbreviations #############
	#######################################

	abbr dc cd
	abbr sl ls
	abbr maek make



	#######################################
	############# Functions ###############
	#######################################

	# test vimscript files in the terminal
	if ! test (string match viml (functions))
		function viml
			for vimfile in (string match '*.vim' $argv)
				vim -es -c "source $vimfile" -c 'q'
			end
		end
	end

	# use '......' idiom to move to any directory level up
	function multicd
		echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
	end
	abbr --add dotdot --position command --regex '^\.\.+$' --function multicd

	# copy the old cd command from fish and enhance it with ls
	if ! test (string match oldcd (functions))
		functions -c cd oldcd
		function cd
			oldcd $argv
			ls
		end
	end

	function open_tcp_ports
		# -Q: remove recv and senq information (i don't know what those mean)
		# -p: show all processes which are using that socket
		#     threads can also be shown with the -T option
		# -4: only show information related to ipv4 sockets
		# -a: show information of both listening and non-listening sockets
		# -t: only show information related to tcp sockets
		# -o: display timeout information (when the socket is going to expire)
		# -D file: save the output to a file
		ss -Qp4ato
	end

	# if test "$LINUX_DISTRO_NAME" = 'Gentoo'
	# end



	#######################################
	########## Initializations ############
	#######################################

	fish_config prompt choose informative

	fish_config theme choose tomorrow-night-bright

	# We have to check for 'nvm' instead of 'nvm_load' (for some strange
	# reason). Anyway, it works the same way, since both functions are
	# defined in '$XDG_CONFIG_HOME/functions/nvm.fish'
	#
	# Alternatively, 'nvm_load' can be postponed and be called
	# manually/on-demand in order to make fish initialize faster
	# if type -q 'nvm'
	# 	nvm_load > /dev/stderr
	# end

else if status is-login
	# Commands to run in login sessions can go here
end
