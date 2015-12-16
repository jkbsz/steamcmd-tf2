#!/bin/bash

#set -x
set -e

cat << EOC
# Requirements
#       Centos 7.0 64
#               yum update ; yum install glibc.i686 libstdc++.i686 unzip curl wget  ncurses-libs.i686
EOC
while true; do
	read -p "Continue? [YN]" yn
	case $yn in
        	[Yy]* ) break ;;
		[Nn]* ) exit ;;
		* ) echo "Please answer Y or N.";;
                esac
done


base_install=~/steamcmd

if [ ! -d $base_install ] ; then
        echo "[$base_install]"
        mkdir $base_install
fi

cd $base_install

# Get steamcmd_linux

if [ ! -f "steamcmd_linux.tar.gz" ] ; then
	wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
	tar xvzf steamcmd_linux.tar.gz
fi

# Create install script

steamcmd_script=${base_install}/tf2_ds.txt
install_dir=${base_install}/tf2

echo "login anonymous" > $steamcmd_script
echo "force_install_dir ${install_dir}" >> $steamcmd_script
echo "app_update 232250" >> $steamcmd_script
echo "quit" >> $steamcmd_script

# Install Team Fortress 2

${base_install}/steamcmd.sh +runscript $steamcmd_script

# MetaMod, Source Mod

function install_mmsm {
	curl http://cdn.probablyaserver.com/sourcemod/mmsource-1.10.6-linux.tar.gz | tar xvz --overwrite --directory ${install_dir}/tf/
	curl https://www.sourcemod.net/smdrop/1.7/sourcemod-1.7.3-git5280-linux.tar.gz | tar xvz --overwrite --directory ${install_dir}/tf/

	while true; do
		read -p "Admin Steam_ID (Q or empty to finish)" steamid
		case $steamid in
			[Qq]* ) break ;;
			* ) if [ -z "$steamid" ]; then break; fi ; echo -e "\"$steamid\"\t\"99:z\"" >>  ${install_dir}/tf/addons/sourcemod/configs/admins_simple.ini ;;
		esac
	done
	
	echo "v--- admins_simple.ini ---v"
	cat ${install_dir}/tf/addons/sourcemod/configs/admins_simple.ini
	echo "^--- admins_simple.ini ---^"
	
}

while true; do
    read -p "Install mmsource and sourcemod? [YN]" yn
    case $yn in
        [Yy]* ) install_mmsm ; break ;;
        [Nn]* ) break ;;
        * ) echo "Please answer Y or N.";;
    esac
done

# ETF2L configs

function etf2l_configs {
	wget http://etf2l.org/configs/etf2l_configs.zip
	unzip etf2l_configs.zip -d ${install_dir}/tf/cfg/
	rm etf2l_configs.zip
}

while true; do
    read -p "Install ETF2L configs? [YN]" yn
    case $yn in
        [Yy]* ) etf2l_configs ; break ;;
        [Nn]* ) break ;;
        * ) echo "Please answer Y or N.";;
    esac
done

# server.cfg

function server_config {

	if [ -f ${install_dir}/tf/cfg/server.cfg ] ; then
		mv ${install_dir}/tf/cfg/server.cfg ${install_dir}/tf/cfg/server.cfg-$(date +%Y%m%d%H%M%S)
	fi
	
	echo "hostname Server of $(cat /dev/urandom | tr -dc A-Za-z | head -c15)" >> ${install_dir}/tf/cfg/server.cfg
	echo "rcon_password $(cat /dev/urandom | tr -dc A-Za-z | head -c15)" >> ${install_dir}/tf/cfg/server.cfg
	echo "sv_password $(cat /dev/urandom | tr -dc A-Za-z | head -c15)" >> ${install_dir}/tf/cfg/server.cfg
	
	echo "v--- server.cfg ---v"
	cat ${install_dir}/tf/cfg/server.cfg
	echo "^--- server.cfg ---^"
}

while true; do
    read -p "Generate server config? [YN]" yn
    case $yn in
        [Yy]* ) server_config ; break ;;
        [Nn]* ) break ;;
        * ) echo "Please answer Y or N.";;
    esac
done

# Startup

cat <<EOL	
${install_dir}/srcds_run \ 
	-autoupdate \ 
	-steam_dir ${base_install} \ 
	-steamcmd_script ${steamcmd_script} \ 
	-game tf \ 
	+log on \ 
	+sv_pure 1 \ 
	+map cp_granary \ 
	+maxplayers 24 \ 
	+ip $(ip route get 1 | awk '{print $NF;exit}')


#changelevel koth_product_rc8
#exec etf2l_6v6_koth
EOL


