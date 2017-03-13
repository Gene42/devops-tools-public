#!/bin/sh

current=$(pwd)

printf "%s\n" "------------------------ Initializing Gene42 DevOps ------------------------"

install_git()
{
    _package_manager=$(which apt-get)

    if [ "$?" = "0" ] && [ "$(echo $_package_manager | grep apt-get | cat)" ]; then
        sudo apt-get -y install git
    else
        _package_manager=$(which yum)
        if [ "$?" = "0" ] && [ "$(echo $_package_manager | grep apt-get | cat)" ]; then
            sudo yum -y install git
        else 
            printf "%s\n" "Neither apt-get nor yum was found, will not continue!"
            exit 1
        fi
    fi
}

git_result=$(which git)
if [ "$?" != "0" ] || [ -z "$git_result" ]; then
    install_git
fi

key_name="devops_id_rsa"
ssh_folder=~/.ssh
key_file="${ssh_folder}/${key_name}"

if [ ! -d "$ssh_folder" ]; then
    mkdir -p "$ssh_folder"
fi

if [ ! -f "$key_file" ]; then
    printf "%s\n" "Ssh key [${key_file}] was not found, please make sure it exists and run this again!"    
    exit 1
fi

sudo chmod 755 "$ssh_folder"
sudo chmod 600 "$key_file"

known_host_file="${ssh_folder}/known_hosts"

github_host="github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="

if [ ! -f "$known_host_file" ]; then
    printf "%s\n" "$github_host"  > "$known_host_file"
elif [ -z "$(cat $known_host_file | grep github.com | cat)" ]; then    
    printf "%s\n" "$github_host" >> "$known_host_file"
fi

gene42_dir=~/.gene42
mkdir -p "$gene42_dir"
cd "$gene42_dir"

devops_dir=scripts
if [ -d "$devops_dir" ]; then
    echo "TODO"
else
    git clone git@github.com:Gene42/devops-tools.git "$devops_dir"
fi

cd "$current"

