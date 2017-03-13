#!/bin/sh

for i in "$@"
do
case $i in
    -d | --default)   
      default=yes
    ;;
    *)
       echo "Unknown option: $i"; exit 1           
    ;;
esac
done

current=$(pwd)

cat .gene42.logo
printf "%s\n%s\n" "[Initializing Gene42 DevOps]" "______________________________________"

####### GIT #######
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

####### SSH Dir + RSA Key #######
ssh_key_name="devops_id_rsa"
ssh_folder=~/.ssh
key_file="${ssh_folder}/${ssh_key_name}"

if [ ! -d "$ssh_folder" ]; then
    mkdir -p "$ssh_folder"
fi

if [ ! -f "$key_file" ]; then
    touch "$key_file"
fi

if [ -z "$(cat $key_file)" ]; then
    printf "%s\n" "SSH key [${key_file}] was not found, please make sure it exists and run this again!"    
    exit 1
fi


sudo chmod 755 "$ssh_folder"
sudo chmod 600 "$key_file"

####### SSH Known Hosts #######
known_host_file="${ssh_folder}/known_hosts"

github_host="github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="

if [ ! -f "$known_host_file" ]; then
    printf "%s\n" "$github_host"  > "$known_host_file"
elif [ -z "$(cat $known_host_file | grep github.com | cat)" ]; then    
    printf "%s\n" "$github_host" >> "$known_host_file"
fi

sudo chmod 644 "$known_host_file"

####### SSH Config #######
ssh_config_alias=devops
ssh_config_file="${ssh_folder}/config"

add_ssh_config()
{
    printf "%s\n  %s\n  %s\n" "Host ${ssh_config_alias}" "HostName github.com" "IdentityFile ~/.ssh/${ssh_key_name}"
}

if [ ! -f "$ssh_config_file" ]; then
    add_ssh_config > "$ssh_config_file"
elif [ -z "$(cat $ssh_config_file | grep github.com | cat)" ]; then 
    printf "\n" >> "$ssh_config_file"
    add_ssh_config >> "$ssh_config_file"
fi

chmod 600 "$ssh_config_file"

####### Gene42 Folder #######
gene42_dir=~/.gene42
mkdir -p "$gene42_dir"
cd "$gene42_dir"

devops_dir=scripts
if [ -d "$devops_dir" ]; then
    ####### Reset devops-tools (private) code - remove repo and pull
    if [ "$default" = "yes" ]; then        
        while true; do
            read -r -p "Pull newest DevOps scripts (Current system.configs will not be deleted)? [y/n]:" yn
            case $yn in
                [Yy]* ) 
                    printf "%s\n" "Removing local scripts.."
                    rm -rf "$devops_dir"
                    git clone "git@${ssh_config_alias}:Gene42/devops-tools.git" "$devops_dir"
                    break;;
                [Nn]* ) break;;
                * ) echo "Please answer y (yes) or n (no).";;
            esac
        done
    fi
else
    git clone "git@${ssh_config_alias}:Gene42/devops-tools.git" "$devops_dir"
fi

printf "%s\n" "Done."

cd "$current"

