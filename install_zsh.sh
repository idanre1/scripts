#!/bin/bash
aptyes='sudo DEBIAN_FRONTEND=noninteractive apt-get -y '

# Install shell
$aptyes install zsh

# attended install
# Don't run zsh at the end, since more installations are needed afterwards
env RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting


# Add flavors
mv ~/.zshrc ~/.zshrc.vanilla
ln -s ~/settings/zshrc ~/.zshrc

# Making default shell
# For not making default, put some cmd arg
# Making default shell
if [ $# -eq 0 ]; then
  sudo usermod -s /bin/zsh $USER
fi
