#!/bin/bash
# dotfiles/bin/bittersweet.sh

# bittersweet.sh
#	Configures macOS just the way I like it
# Tested on:
#	10.13

set -euo pipefail
# -e exit if any command returns non-zero status code
# -u prevent using undefined variables
# -o pipefail force pipelines to fail on first non-zero status code


function usage {

	echo -e "\nConfigures macOS just the way I like it 🤓\n"
	echo "Usage:"
	echo "	defaults	- Write new system and application default settings"
	echo "	vmware 		- Change VMWare defaultVMPath to '${HOME}/Virtual Machines'"
	echo "	gpgtools 	- Install GPGTools"
	echo "	brew 		- Install Homebrew, Homebrew-file and export HOMEBREW_BREWFILE" 
	echo "	brewfile 	- Install Homebrew packages from Brewfile"
	echo "	configs 	- Install ssh, gpg, etc configuration files"

	echo -e "\n 	\033[0;31mhailmary\033[0m 	- Run every function in order listed above"

	exit 0
}


function write_defaults {

	echo "[🍺] Writing some system & application defaults"

	defaults write com.apple.TextEdit RichText -int 0
	# TextEdit: Use Plain Text Mode as Default
	# Default: com.apple.TextEdit RichText -int 1

	defaults write com.apple.mail minSizeKB 5000
	# Mail: If attatchment is over 5MB ask to send via Mail Drop
	# Default: com.apple.mail minSizeKB 20000

	defaults write com.apple.menuextra.battery ShowPercent -string "YES"
	# Menu Bar: Show battery percentage
	# Default: com.apple.menuextra.battery ShowPercent -string "NO"

}


function install_gpgtools {

	local version=$(curl -s https://gpgtools.org/releases/gpgsuite/release-notes.html \
					| grep -m 1 data-version= \
					| awk -F\" '{print $(NF-1)}')
					# Get the latest gpgtools version string
					# Not sure if this method will survive an update  
	
	local url="https://releases.gpgtools.org/GPG_Suite-${version}.dmg"
	local download_path="${HOME}/Downloads/GPG_Suite-${version}.dmg"
	
	if ! [ -x "$(command -v brew)" ]; then

		echo "[🍺] Installing GPGTools"
		
		echo "[🍺] Downloading GPG_Suite-${version}.dmg"
		curl -o "${download_path}" "${url}" 
		# Download 

		echo "[🍺] Mounting ${download_path}"
		hdiutil attach -quiet "${download_path}"
		# Mount the DMG


		echo "[⚠️ ] Password required for install"
		sudo installer -pkg "/Volumes/GPG Suite/Install.pkg" -target "/"

		echo "[🍺] Unmounting /Volumes/GPG Suite"
		hdiutil detach -quiet "/Volumes/GPG Suite"

	else

		local installed_version=$(gpg --version | head -n 1)

		echo "[🍺] ${installed_version} already installed"

	fi
}


function change_vmware_home {

	# Create new directory $HOME/Virtual Machines
	# Set prefvmx.defaultVMPath to $HOME/Virtual Machines in ~/Library/Preferences/VMWare Fusion/preferences
	# TODO: Allow user to pass their own path for prefvmx_defaultVMPath  

	local vmware_preferences_file="${HOME}/Library/Preferences/VMware Fusion/preferences"
	local vmware_preferences_directory="${HOME}/Library/Preferences/VMware Fusion"
	local prefvmx_defaultVMPath="${HOME}/VMware Fusion"

	if [ ! -d "${vmware_preferences_directory}" ]; then
		# Check if VMWare Fusion is installed
		echo "[❌] VMWare Fusion is not installed"
	else
		
		if grep -q prefvmx.defaultVMPath "${vmware_preferences_file}" ; then
			# Check if prefvmx.defaultVMPath is already set
			echo "[❌] prefvmx.defaultVMPath is already set"
			exit 1
		else
			echo "[🍺] Setting VMWare prefvmx.defaultVMPath to '${prefvmx_defaultVMPath}'"

			if mkdir -p "${prefvmx_defaultVMPath}" ; then
				# Attempt to create the directory for VM storage 
				echo "[✅] Successfully created '${prefvmx_defaultVMPath}'"
				
				if echo "prefvmx.defaultVMPath = ${prefvmx_defaultVMPath}" >> "${vmware_preferences_file}" ; then
					echo "[✅] Successfully set prefvmx.defaultVMPath"
				else
					echo "[❌] Failed to set prefvmx.defaultVMPath to '${prefvmx_defaultVMPath}'"
					exit 1
				fi

			else
				echo "[❌] Failed to create '${prefvmx_defaultVMPath}'"
				exit 1
			fi
		fi
	fi	
}


function install_brew {

	# Install Homebrew and Homebrew-file
	
	if ! [ -x "$(command -v brew)" ]; then

		echo "[🍺] Installing Homebrew"
		echo -e "[⚠️ ] \033[0;31mStick around\033[0m - Requires you to press RETURN and input your password"
		sleep 5
	   	
	   	if /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ; then
	   		echo "[✅] Successfully installed Homebrew 🍻"
	   	else
	   		echo "[❌] Failed to install Homebrew 😢"
	   		exit 1
	   	fi    

  	else
  		
  		brew update
     	brew upgrade
     	brew cleanup
    fi

   	echo "[🍺] Installing Homebrew-file"

   	if ! [ -x "$(command -v brew-file)" ]; then

   		if brew install rcmdnk/file/brew-file ; then
   			echo "[✅] Successfully installed Homebrew-file"
   		else
   			echo "[❌] Failed to install Homebrew-file"
   			exit 1
   		fi
   	else
   		echo "[🍺] Homebrew-file already installed"
   	fi 

}


function install_brewfile {

	# Install Homebrew packages from dotfiles/Brewfile
	# Will install programs from the Mac AppStore if user is logged in
	
	export HOMEBREW_BREWFILE="${homebrew_brewfile}"
	echo "[🍺] Exported HOMEBREW_BREWFILE=${homebrew_brewfile}"

   	echo "[🍺] Installing Homebrew packages from Brewfile"
   	
   	if brew file install ; then 
   		echo "[✅] Successfully installed packages from Brewfile"
	else
		echo "[❌] Failed to install packages from Brewfile"
		exit 1
	fi
}


function install_file { 

	# install_file $dir $source $destination
	# Check if $dir exists if not create it
	# Check if cp -i suceeds, if file exists ask user whether to overwrite
	# TODO: Get $dir from $destination path     


	local dir=${1:-""}
	local source=${2:-""}
	local destination=${3:-""}

	if [ -d "${dir}" ]; then
		echo "[🍺] ${dir} already exists"

		if cp -i "${source}" "${destination}" ; then
			echo "[✅] Successfully installed ${destination}"
		else
			echo "[❌] Failed to install ${destination}"
			exit 1
		fi

	else
		
		if mkdir -p "${dir}" ; then
			echo "[✅] Successfully created ${dir}"
		
			if cp -i "${source}" "${destination}" ; then
				echo "[✅] Successfully installed ${destination}"
			else
				echo "[❌] Failed to install ${destination}"
				exit 1
			fi

		else
			echo "[❌] Failed to create ${dir}"
			exit 1	
		fi	
	fi

}


function install_configs {
	# Always call this last

	# Install SSH config file
	# config
	install_file "${HOME}"/.ssh 	"${git_dir}"/.ssh/config 	"${HOME}"/.ssh/config

	# Install GPG configs 
	# ggp.conf and gpg-agent.conf
	install_file "${HOME}"/.gnupg 	"${git_dir}"/.gnupg/gpg.conf  		"${HOME}"/.gnupg/gpg.conf
	install_file "${HOME}"/.gnupg  	"${git_dir}"/.gnupg/gpg-agent.conf  "${HOME}"/.gnupg/gpg-agent.conf	

}


function main {

	local cmd=${1:-"usage"}
	local homebrew_brewfile=${2:-${HOME}/Documents/Projects/dotfiles/Brewfile}
	local git_dir=${2:-$( cd .. "$( dirname "${BASH_SOURCE[0]}" )" && pwd )}
	# Get the path to ../dotfiles 
	# Expected that this script is run from ../dotfiles/bin 
	# https://stackoverflow.com/a/246128
	# https://gist.github.com/tvlooy/cbfbdb111a4ebad8b93e

	if [[ "${cmd}" == "defaults" ]]; then
		write_defaults

	elif [[ "${cmd}" == "vmware" ]]; then
		change_vmware_home

	elif [[ "${cmd}" == "brew" ]]; then
		install_brew

	elif [[ "${cmd}" == "brewfile" ]]; then
		install_brewfile "${homebrew_brewfile}"

	elif [[ "${cmd}" == "configs" ]]; then
		install_configs "${git_dir}"

	elif [[ "${cmd}" == "gpgtools" ]]; then 
		install_gpgtools

	elif [[ "${cmd}" == "hailmary" ]]; then
		# Execute all the functions
		# Order matters!
		# TODO: Manually adding new fucntions sucks
		echo -e "[🍺] \033[0;31mHailmary\033[0m engaged"

		write_defaults
		install_gpgtools
		change_vmware_home
		install_brew
		install_brewfile "${homebrew_brewfile}"

		# install_configs should probably be done last
		install_configs "${git_dir}"

	else
		usage
	fi
}

main "$@"