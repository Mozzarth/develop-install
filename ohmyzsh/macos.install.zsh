#!/bin/bash

# Instalar Homebrew (si no está instalado)
if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Instalar Git
# Si ya esta instalado no hace nada
if ! command -v git &> /dev/null
then
    brew install git
else 
     echo "Git ya está instalado ✅"
fi

# Instalar Curl
if ! command -v curl &> /dev/null
then
    brew install curl
else 
     echo "Curl ya está instalado ✅"
fi

# Instalar Vim
if ! command -v vim &> /dev/null
then
    brew install vim
else 
     echo "Vim ya está instalado ✅"
fi

# Instalar Zsh
if ! command -v zsh &> /dev/null
then
    brew install zsh
else 
     echo "Zsh ya está instalado ✅"
fi

# Instalar hyper.js
if ! command -v hyper &> /dev/null
then
    brew install --cask hyper
else 
     echo "Hyper.js ya está instalado ✅"
fi 

# Instalar fig
if ! command -v fig &> /dev/null
then
    brew install fig
else 
     echo "Fig ya está instalado ✅"
fi



# Instalar Oh My Zsh
if ! command -v zsh &> /dev/null
then
     sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
     # Asegurarse de que el comando anterior finalizó correctamente
     if [ "$?" -ne 0 ]; then
         echo "La instalación de Oh My Zsh falló"
     fi
     # echo "Instalando Oh My Zsh"
     # # ejecutar el archivo ./ohmyzsh.sh 
     # source ./ohmyzsh.sh
     # # Asegurarse de que el comando anterior finalizó correctamente
     # if [ "$?" -ne 0 ]; then
     #     echo "La instalación de Oh My Zsh falló"
     # fi
else 
     echo "Oh My Zsh ya está instalado, eliminando..."
     rm -rf $HOME/.oh-my-zsh 
     sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

     # Asegurarse de que el comando anterior finalizó correctamente
     if [ "$?" -ne 0 ]; then
         echo "La reinstalación de Oh My Zsh falló ❌"
     fi
     # echo "Oh My Zsh ya está instalado"
     # rm -rf $HOME/.oh-my-zsh
     # source ./ohmyzsh.sh
     # # Asegurarse de que el comando anterior finalizó correctamente
     # if [ "$?" -ne 0 ]; then
     #     echo "La reinstalación de Oh My Zsh falló"
     # fi

fi


echo "Instalando plugins de Oh My Zsh 🚀"
rm -rf $HOME/.oh-my-zsh/custom/plugins/

# Instalar zsh-autosuggestions
echo "Instalando zsh-autosuggestions 🚀"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Instalar zsh-autosuggestions
echo "Instalando zsh-autosuggestions 🚀"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


# Configuracion 
echo "Configurando Zsh 🚀"
cat .zshrc > ~/.zshrc
echo "Configurando Hyper.js 🚀"
cat .hyper.js > ~/.hyper.js


# Reiniciar
echo "Reiniciando Zsh 🛠️"
 ~/.zshrc
#  source ~/.zshrc

# Mensaje de finalización.
echo "Instalación finalizada ✅"

