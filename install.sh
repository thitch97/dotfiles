#!/bin/zsh -exu

readonly PROGDIR="$(cd "$(dirname "${0}")" && pwd)"
readonly WORKSPACE="${HOME}/workspace"
readonly GOPATH="${HOME}/go"

function main() {
  #Install devtools
	if [[ ! -d "/Library/Developer/CommandLineTools" ]]; then
		xcode-select --install
	fi

  #Install Homebrew
	if ! [ -x "$(command -v brew)" ]; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	brew update
	brew bundle
	brew cleanup

  #Install ZSH
  CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)

  if [ ! "$CHECK_ZSH_INSTALLED" -ge 1 ]; then
    echo "\033[0;33m Zsh is not installed!\033[0m"
    echo "Installing Zsh..."

    brew install zsh

    sudo sh -c "echo $(which zsh) >> /etc/shells"

    exit
  fi

  unset CHECK_ZSH_INSTALLED

  chsh -s "$(which zsh)"

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	ln -sf "${PROGDIR}/.zshrc" "${HOME}/.zshrc"


	ln -sf "${PROGDIR}/.gitconfig" "${HOME}/.gitconfig"
	mkdir -pv "${WORKSPACE}"

	if [[ ! -d "${HOME}/.config/colorschemes" ]]; then
		git clone https://github.com/chriskempson/base16-shell.git "${HOME}/.config/colorschemes"
	fi

  #Nvim Setup
	pip3 install --upgrade pip --user
	pip3 install neovim
	curl -fLo "${HOME}/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	mkdir -p "${HOME}/.config/nvim"
	ln -sf "${PROGDIR}/init.vim" "${HOME}/.config/nvim/init.vim"
	nvim -c "PlugInstall" -c "PlugUpdate" -c "qall" --headless
	nvim -c "GoInstallBinaries" -c "GoUpdateBinaries" -c "qall!" --headless

	go get -u github.com/onsi/ginkgo/ginkgo
	go get -u github.com/onsi/gomega

	echo "Success!"
}

main
