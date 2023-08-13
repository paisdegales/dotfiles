#!/bin/bash

function main(){
	echo "Welcome to the post install script for Fedora ${FEDORA_VERSION}!"

	echo -e "Would you like to enable debugging? yes/no: "
	read debug_flag
	if [ debug_flag == "yes" ]; then
		set -xv
	fi

	# routine
}

function update_fedora(){
	# updating all system packages
	sudo dnf distro-sync

	# setting up some useful repositoers
	echo "Setting rpmfusion free and nonfree repositories"
	sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
	sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	# install flatpak if it isn't already installed
	if [ ! -a "/usr/bin/flatpak" ] ; then
		sudo dnf install flatpak -y
		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		flatpak remote-add --if-not-exists fedora oci+https://registry.fedoraproject.org
	fi

	# remove nano
	sudo dnf uninstall nano -y
}

function install_programming_languages(){
	# C/C++ language
	local C_LANGUAGE="make gcc gdb valgrind"
	echo "Installing C language package: ${C_LANGUAGE}"
	sudo dnf install ${C_LANGUAGE} -y

	# Rust
	echo "Installing Rust"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

	# Python

	# Javascript
	# echo "Installing Rust"
	# install nvm and latest stable version of npm
	# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
	# bash -c "nvm install --lts"

	# Lua

	# Go
}

function install_cli_tools(){
	local COMMANDLINE_PROGRAMS="git tmux vim neovim micro lynx ffmpeg gparted"
	echo "Installing cli tools: ${COMMANDLINE_PROGRAMS}"
	sudo dnf install ${COMMANDLINE_PROGRAMS} -y
}

function install_flatpak_programs(){
	local FLATPAK_PROGRAMS="com.discordapp.Discord org.mypaint.MyPaint"
	echo "Installing flatpak apps: ${FLATPAK_PROGRAMS}"
	sudo flatpak install ${FLATPAK_PROGRAMS} -y
}

function install_nvidia_driver(){
	sudo dnf update -y # and reboot if you are not on the latest kernel
	sudo dnf install akmod-nvidia # rhel/centos users can use kmod-nvidia instead
	sudo dnf install xorg-x11-drv-nvidia-340xx-cuda #optional for cuda up to 6.5 support
	sudo dnf install vulkan

	## this is done by checking if the return of ??? command is ok (read more in the website)
	echo "Sleeping for 4min, while waiting for all nvidia modules get built..."
	sleep 240
}

function install_docker(){
	sudo dnf -y install dnf-plugins-core
	sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo 
	sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin 
	sudo systemctl start docker
}

function set_working_environment(){
	# config files
	git clone https://github.com/paisdegales/dotfiles.git ~

	# personal notes
	git clone https://github.com/paisdegales/notes.git ~

	# kitty terminal
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

	# fish shell
	sudo dnf install fish

	# awesome window manager
	sudo dnf install awesome
}

function routine(){
	mkdir log

	log_file=log/update_fedora.log
	time update_fedora &> ${log_file}

	log_file=log/install_cli_tools.log
	time install_cli_tools &> ${log_file}

	log_file=log/install_programming_languages.log
	time install_programming_languages &> ${log_file}

	log_file=log/set_working_environment.log
	time set_working_environment &> ${log_file}

	log_file=log/install_flatpak_programs.log
	time install_flatpak_programs &> ${log_file}

	# log_file=update_fedora.log
	# time install_nvidia_driver

	# log_file=update_fedora.log
	# time install_docker
}

main

# 6.4 BASH CONDITIONAL EXPRESSIONS
# 3.5 SHELL EXPANSION
# 3.2.5.1 LOOP
# 3.2.5.2 IF

# Insomnia, DBeaver, GIMP, Wireshark, OBS, Blender, Epiphany, VLC
