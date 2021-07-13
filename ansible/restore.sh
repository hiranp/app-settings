#!/bin/bash
required_applications="mas"

function requires {
    if ! command -v brew &> /dev/null
    then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    echo "Installing required applications [$required_applications]..."
    brew install -q $required_applications
}

function import_app_store_apps {
    if ! mas account &> /dev/null 
    then
        echo "ERROR: Please sign in to the Apple App Store before continuing"
        exit 1
    fi
    echo "* App Store applications..."
    mas install $(tr '\n' ' ' < export/app_store/installed_app_ids.txt)
}

function import_brew_installs {
    echo "* Homebrew installs..."
    for tap in $(cat export/homebrew/taps.txt)
    do
        brew tap $tap
    done
    brew install $(cat export/homebrew/formulae.txt)
    brew cask install $(cat export/homebrew/casks.txt)
}

function import_machine_settings {
    echo "* System settings..."
    
    defaults import -globalDomain export/defaults/globalDomain.plist
    rm export/defaults/globalDomain.plist

    for domain in $(ls export/defaults)
    do
        defaults import $domain export/defaults/$domain
    done
}

function import_application_settings {
    echo "* Application settings..."
    rsync -a --prune-empty-dirs --include '*/' export/Library ~/
}

requires

echo "Extracting backup at export.zip..."
unzip -o -q export.zip

echo "Importing:"
import_app_store_apps
import_brew_installs
import_application_settings
import_machine_settings

