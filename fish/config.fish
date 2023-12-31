if status is-interactive
	# Commands to run in interactive sessions can go here
	if test -d "$HOME/.cargo/bin"
		set -x PATH $PATH $HOME/.cargo/bin
	end

	if test -f "$HOME/.lynx/lynx.cfg"
		set -x LYNX_CFG "$HOME/.lynx/lynx.cfg"
		# not working in arch
		# set -x LYNX_LSS "bright-blue.lss"
	end

	if test -d "$HOME/.local/bin"
		set -x PATH $PATH $HOME/.local/bin
	end

	set -x EDITOR "nvim"

	if test -d "$HOME/.bun"
		set --export BUN_INSTALL "$HOME/.bun"
		set --export PATH $PATH $BUN_INSTALL/bin
	end

	function multicd
			echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
	end
	abbr --add dotdot --regex '^\.\.+$' --function multicd

end
