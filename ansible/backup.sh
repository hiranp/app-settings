#!/bin/bash

mkdir -p export

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

function clean_up {
    echo "Cleaning up supporting software [$required_applications]..."
    brew remove $required_applications
}

function export_machine_settings {
    echo "* System settings..."
    mkdir -p export/defaults

    defaults export -globalDomain export/defaults/globalDomain.plist

    for domain in `defaults domains | tr ',' '\n'`
    do
        defaults export $domain export/defaults/$domain.plist
    done
}

function export_application_settings {
    echo "* Application settings..."
    mkdir ./export/Library
    rsync -a --prune-empty-dirs --include '*/' ~/Library/Application\ Support export/Library/
    rsync -a --prune-empty-dirs --include '*/' ~/Library/Preferences export/Library/
}

function export_app_store_apps {
    echo "* App Store applications..."
    mkdir -p export/app_store
    mas list | cut -f 1 -d ' ' > export/app_store/installed_app_ids.txt
}

function export_brew_installs {
    echo "* Homebrew installs..."
    mkdir -p export/homebrew
    brew tap > export/homebrew/taps.txt
    brew list > export/homebrew/formulae.txt
    brew list --cask > export/homebrew/casks.txt
}

function archive_exports {
    zip -r -q export.zip export/
}

requires
echo "Exporting:"
export_machine_settings
export_application_settings
export_app_store_apps
export_brew_installs
archive_exports


echo "Done!"
