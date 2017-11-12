# ~/.bash_profile

#  ---------------------------------------------------------------------------
#
#	Description: My BASH configurations and aliases
#
#	Based on:
#	https://gist.github.com/natelandau/10654137
#	
#  	Sections:
#  	0.  Environment Configuration
#  	1.  Make Terminal Better (remapping defaults and adding functionality)
#
#  ---------------------------------------------------------------------------



#   -----------------------------
#   0. ENVIRONMENT CONFIGURATION
#   -----------------------------

cd /Users/$USER/Documents/Projects
# Start each terminal session in this directory

export PATH=/usr/local/bin:/usr/local/sbin:$PATH
# Export path to include Homebrew binaries

export HOMEBREW_BREWFILE=/Users/$USER/Documents/Projects/dotfiles/Brewfile
# Set location of Brewfile 


#   -----------------------------
#   1. REMAP DEFAULT COMMANDS
#   -----------------------------

alias ..='cd ..' 
# Go up one directory level
alias ...='cd ...' 
# Go up two directory levels
alias c='clear'
# Clear terminal window
alias ll='ls -aFGhl'
# Preferred ls behaviour
		# -a show files and dirs starting with .
		# -F write `/' after directories, '*' after executables and '@' after symlinks
		# -G enable colorized output
		# -h show sizes in human readable form
		# -l display in long format 