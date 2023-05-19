#!/bin/bash
 sudo apt-get update
# Instalar Git si no está instalado
if ! command -v git &> /dev/null
then
    sudo apt-get install git -y
else
    echo "Git ya está instalado ✅"
fi

# Instalar Curl si no está instalado
if ! command -v curl &> /dev/null
then
    sudo apt-get install curl -y
else
    echo "Curl ya está instalado ✅"
fi

# Instalar Vim si no está instalado
if ! command -v vim &> /dev/null
then
    sudo apt-get install vim -y
    echo "Vim instalado ✅"
else
    echo "Vim ya está instalado ✅"
fi

# Instalar Zsh si no está instalado
if ! command -v zsh &> /dev/null
then
    sudo apt-get install zsh -y
    echo "Zsh instalado ✅"
else
    echo "Zsh ya está instalado ✅"
fi

# Instalar hyper.js si no está instalado
if ! command -v hyper &> /dev/null
then
    sudo apt-get install gdebi -y
    wget https://releases.hyper.is/download/deb -O hyper.deb
    sudo gdebi -n hyper.deb
    rm hyper.deb
    echo "Hyper.js instalado ✅"
else
    echo "Hyper.js ya está instalado ✅"
fi

# Instalar fig si no está instalado
if ! command -v fig &> /dev/null 
then
    sudo apt-get install figlet -y
    echo "Fig instalado ✅"
else
    echo "Fig ya está instalado ✅"
fi

# Instalar nvm 
if ! command -v nvm &> /dev/null
then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    echo "NVM instalado ✅"
else
    echo "NVM ya está instalado ✅"
fi

# Instalar Oh My Zsh si no está instalado o reinstalarlo
if ! command -v zsh &> /dev/null
then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ "$?" -ne 0 ]; then
        echo "La instalación de Oh My Zsh falló ❌"
    fi
else
    echo "Oh My Zsh ya está instalado, eliminando..."
    rm -rf $HOME/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    if [ "$?" -ne 0 ]; then
        echo "La reinstalación de Oh My Zsh falló ❌"
    fi
fi

echo "Instalando plugins de Oh My Zsh 🚀"
rm -rf $HOME/.oh-my-zsh/custom/plugins/

# Instalar zsh-syntax-highlighting
echo "Instalando zsh-syntax-highlighting 🚀"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Instalar zsh-autosuggestions
echo "Instalando zsh-autosuggestions 🚀"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Configuracion 
echo "Configurando Zsh 🚀"
cat .zshrc > ~/.zshrc
echo "Configurando Hyper.js 🚀"
cat .hyper.js > ~/.hyper.js

# Reiniciar la terminal
echo "Reiniciando la terminal 🚀"
source ~/.zshrc

echo "Instalación finalizada ✅"
