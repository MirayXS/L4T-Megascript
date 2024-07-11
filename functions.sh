#!/bin/bash

#####################################################################################

#functions used by megascript scripts

#####################################################################################
unset functions_downloaded

export DIRECTORY="$HOME/L4T-Megascript"

function get_system {
  # architecture, dpkg_architecture, jetson_model (if available), model, __os_id, __os_desc, __os_release, and __os_codename are always available in L4T-Megascript scripts without calling any function
  source /etc/os-release
  __formal_distro_name="$NAME"
  export __formal_distro_name
  __id_like="$ID_LIKE"
  __id="$ID"
  export __id
  if [ $__id == "debian" ]; then
    __id_like="debian"
  fi
  export __id_like
  # architecture is the native cpu architecture (aarch64, armv7l, armv6l, x86_64, i386, etc)
  architecture="$(uname -m)"
  export architecture
  # dpkg_architecture is the default userspace cpu architecture (arm64, amd64, armhf, i386, etc)
  if
    command -v dpkg >/dev/null
  then
    dpkg_architecture="$(dpkg --print-architecture)"
    export dpkg_architecture
  fi
  # obtain model name
  unset model
  if [[ -d /system/app/ && -d /system/priv-app ]]; then
    model="$(getprop ro.product.brand) $(getprop ro.product.model)"
  fi
  if [[ -z "$model" ]] && [[ -f /sys/devices/virtual/dmi/id/product_name ||
    -f /sys/devices/virtual/dmi/id/product_version ]]; then
    model="$(tr -d '\0' </sys/devices/virtual/dmi/id/product_name)"
    model+=" $(tr -d '\0' </sys/devices/virtual/dmi/id/product_version)"
  fi
  if [[ -z "$model" ]] && [[ -f /sys/firmware/devicetree/base/model ]]; then
    model="$(tr -d '\0' </sys/firmware/devicetree/base/model)"
  fi
  if [[ -z "$model" ]] && [[ -f /tmp/sysinfo/model ]]; then
    model="$(tr -d '\0' </tmp/sysinfo/model)"
  fi
  unset jetson_model
  unset jetson_chip_model
  unset SOC_ID
  # Remove dummy OEM info.
  model=${model//To be filled by O.E.M./}
  model=${model//To Be Filled*/}
  model=${model//OEM*/}
  model=${model//Not Applicable/}
  model=${model//System Product Name/}
  model=${model//System Version/}
  model=${model//Undefined/}
  model=${model//Default string/}
  model=${model//Not Specified/}
  model=${model//Type1ProductConfigId/}
  model=${model//INVALID/}
  model=${model//All Series/}
  model=${model//�/}
  export model

  # obtain jetson model name (if available)
  # nvidia, in their official L4T (Linux for Tegra) releases 32.X and 34.X, set a distinct tegra family in the device tree /proc/device-tree/compatible
  if [[ -e "/proc/device-tree/compatible" ]]; then
    CHIP="$(tr -d '\0' </proc/device-tree/compatible)"
    if [[ ${CHIP} =~ "tegra20" ]]; then
      jetson_chip_model="t20"
      jetson_model="tegra-2"
    elif [[ ${CHIP} =~ "tegra30" ]]; then
      jetson_chip_model="t30"
      jetson_model="tegra-3"
    elif [[ ${CHIP} =~ "tegra114" ]]; then
      jetson_chip_model="t114"
      jetson_model="tegra-4"
    elif [[ ${CHIP} =~ "tegra124" ]]; then
      jetson_chip_model="t124"
      jetson_model="tegra-k1-32"
    elif [[ ${CHIP} =~ "tegra132" ]]; then
      jetson_chip_model="t132"
      jetson_model="tegra-k1-64"
    elif [[ ${CHIP} =~ "tegra210" ]]; then
      jetson_chip_model="t210"
      jetson_model="tegra-x1"
    elif [[ ${CHIP} =~ "tegra186" ]]; then
      jetson_chip_model="t186"
      jetson_model="tegra-x2"
    elif [[ ${CHIP} =~ "tegra194" ]]; then
      jetson_chip_model="t194"
      jetson_model="xavier"
    elif [[ ${CHIP} =~ "tegra234" ]]; then
      jetson_chip_model="t234"
      jetson_model="orin"
    elif [[ ${CHIP} =~ "tegra239" ]]; then
      jetson_chip_model="t239"
      jetson_model="switch-pro-chip"
    elif [[ ${CHIP} =~ "tegra" ]]; then
      jetson_model="jetson-unknown"
    elif [[ ${CHIP} =~ "rk3399" ]]; then
      SOC_ID="rk3399"
    elif [[ ${CHIP} =~ "rk3308" ]]; then
      SOC_ID="rk3308"
    elif [[ ${CHIP} =~ "rk3326" ]]; then
      SOC_ID="rk3326"
    elif [[ ${CHIP} =~ "rk3328" ]]; then
      SOC_ID="rk3328"
    elif [[ ${CHIP} =~ "rk3368" ]]; then
      SOC_ID="rk3368"
    elif [[ ${CHIP} =~ "rk3566" ]]; then
      SOC_ID="rk3566"
    elif [[ ${CHIP} =~ "rk3568" ]]; then
      SOC_ID="rk3568"
    elif [[ ${CHIP} =~ "g12b" ]]; then
      SOC_ID="g12b"
    elif [[ ${CHIP} =~ "g12b" ]]; then
      SOC_ID="g12b"
    elif [[ ${CHIP} =~ "g12b" ]]; then
      SOC_ID="g12b"
    elif [[ ${CHIP} =~ "bcm2711" ]]; then
      SOC_ID="bcm2711"
    elif [[ ${CHIP} =~ "bcm2837" ]]; then
      SOC_ID="bcm2837"
    elif [[ ${CHIP} =~ "bcm2836" ]]; then
      SOC_ID="bcm2836"
    elif [[ ${CHIP} =~ "bcm2835" ]]; then
      SOC_ID="bcm2835"
    fi
  # as part of the 2X.X L4T releases, the kernel is older and the tegra family is found in /sys/devices/soc0/family
  elif [[ -e "/sys/devices/soc0/family" ]]; then
    CHIP="$(tr -d '\0' </sys/devices/soc0/family)"
    if [[ ${CHIP} =~ "tegra20" ]]; then
      jetson_chip_model="t20"
      jetson_model="tegra-2"
    elif [[ ${CHIP} =~ "tegra30" ]]; then
      jetson_chip_model="t30"
      jetson_model="tegra-3"
    elif [[ ${CHIP} =~ "tegra114" ]]; then
      jetson_chip_model="t114"
      jetson_model="tegra-4"
    elif [[ ${CHIP} =~ "tegra124" ]]; then
      jetson_chip_model="t124"
      jetson_model="tegra-k1-32"
    elif [[ ${CHIP} =~ "tegra132" ]]; then
      jetson_chip_model="t132"
      jetson_model="tegra-k1-64"
    elif [[ ${CHIP} =~ "tegra210" ]]; then
      jetson_chip_model="t210"
      jetson_model="tegra-x1"
    fi
  fi
  if [ -n "$jetson_model" ]; then
    SOC_ID="$jetson_model"
  fi

  export SOC_ID
  export jetson_chip_model
  export jetson_model
  unset CHIP

  # add upstream and original lsb-release info for all scripts to use

  # _os_original_* variables are only set for downstream releases (eg: Pop!_OS, Linux Mint, and KDE Neon)
  # this allows for scripts to simply check for the existance of _os_original_* variables and operate differently if found
  # note: Pop!_OS, Linux Mint, and KDE Neon are NOT official Ubuntu flavors (like Kubuntu, Ubuntu MATE, Ubuntu Kylin, Ubuntu Budgie, Lubuntu, Ubuntu Studio, Ubuntu Unity, and Xubuntu)
  # official Ubuntu flavors use ONLY the official Ubuntu repositories and are directly supported by Ubuntu. These other releases are simply "based" on Ubuntu, much like Raspbian and PiOS are "based" on Debian.

  # first check if lsb_release has an upstream option -u
  # if not, check if there is an upstream-release file
  # if not, check if there is a lsb-release.diverted file
  # if not, assume that this is not a ubuntu derivative
  # use mapfile to temporarily store release info for speed
  if [ -z "$__os_id" ] || [ -z "$__os_desc" ] || [ -z "$__os_release" ] || [ -z "$__os_codename" ]; then
    if lsb_release -a -u &>/dev/null; then
      # This is a Ubuntu Derivative, checking the upstream-release version info
      mapfile -t os_u < <(lsb_release -s -i -d -r -c -u)
      export __os_id="${os_u[0]}"
      export __os_desc="${os_u[1]}"
      export __os_release="${os_u[2]}"
      export __os_codename="${os_u[3]}"
      mapfile -t os < <(lsb_release -s -i -d -r -c)
      export __os_original_id="${os[0]}"
      export __os_original_desc="${os[1]}"
      export __os_original_release="${os[2]}"
      export __os_original_codename="${os[3]}"
    elif [ -f /etc/upstream-release/lsb-release ]; then
      # ubuntu 22.04+ Linux Mint no longer includes the lsb_release -u option
      # add a parser for the /etc/upstream-release/lsb-release file
      source /etc/upstream-release/lsb-release
      export __os_id="$DISTRIB_ID"
      export __os_desc="$DISTRIB_DESCRIPTION"
      export __os_release="$DISTRIB_RELEASE"
      export __os_codename="$DISTRIB_CODENAME"
      mapfile -t os < <(lsb_release -s -i -d -r -c)
      export __os_original_id="${os[0]}"
      export __os_original_desc="${os[1]}"
      export __os_original_release="${os[2]}"
      export __os_original_codename="${os[3]}"
      unset DISTRIB_ID DISTRIB_DESCRIPTION DISTRIB_RELEASE DISTRIB_CODENAME
    elif [ -f /etc/lsb-release.diverted ]; then
      # ubuntu 22.04+ Pop!_OS no longer includes the /etc/upstream-release/lsb-release or the lsb_release -u option
      # add a parser for the new /etc/lsb-release.diverted file
      source /etc/lsb-release.diverted
      export __os_id="$DISTRIB_ID"
      export __os_desc="$DISTRIB_DESCRIPTION"
      export __os_release="$DISTRIB_RELEASE"
      export __os_codename="$DISTRIB_CODENAME"
      mapfile -t os < <(lsb_release -s -i -d -r -c)
      export __os_original_id="${os[0]}"
      export __os_original_desc="${os[1]}"
      export __os_original_release="${os[2]}"
      export __os_original_codename="${os[3]}"
      unset DISTRIB_ID DISTRIB_DESCRIPTION DISTRIB_RELEASE DISTRIB_CODENAME
    else
      export __os_id="$(lsb_release -s -i)"
      export __os_desc="$(lsb_release -s -d)"
      export __os_release="$(lsb_release -s -r)"
      export __os_codename="$(lsb_release -s -c)"
    fi
  fi
}
export -f get_system

## IMPORTANT, NEVER REMOVE calling get_system from the functions.sh file. All scripts assume it has been called and the variables are available
get_system

function LTS_check {
  # if LTS_check; then
  # 	echo "LTS"
  # else
  # 	echo "not LTS"
  # fi

  source /etc/os-release
  if [[ $(echo $VERSION) == *"LTS"* ]]; then
    #the user's distro is an LTS
    return 0
  else
    #not LTS, so returning false
    return 1
  fi
}
export -f LTS_check

function PPA_check {
  # this function is a modified version of https://gist.github.com/blade1989/9250261
  # all I really did was remove the yes/no prompt and the section to install any packages
  # so I guess you could call this version 0.4.1? -cobalt
  # original credits are below:

  #-----------------------------------------------
  #	Author	    :   Imri Paloja
  #	Email	    :   imri.paloja@gmail.com
  #	HomePage    :   www.eurobytes.nl
  #	Version	    :   0.4.0(Alpha, Be warned!)
  #	Name        :   add-ppa
  #-----------------------------------------------

  if [ -d "/tmp/add-ppa/" ]; then
    rm -r /tmp/add-ppa/
  else
    mkdir /tmp/add-ppa/
  fi

  mkdir -p /tmp/add-ppa/
  wget --quiet "http://ppa.launchpad.net/$(echo $1 | sed -e 's/ppa://g')/ubuntu/dists" -O /tmp/add-ppa/support.html
  grep "$(lsb_release -sc)" "/tmp/add-ppa/support.html" >>/tmp/add-ppa/found.txt
  cat /tmp/add-ppa/found.txt | sed 's|</b>|-|g' | sed 's|<[^>]*>||g' >>/tmp/add-ppa/stripped_file.txt

  if [[ -s /tmp/add-ppa/stripped_file.txt ]]; then
    echo "$(lsb_release -sc) is supported!"
    return 0
  else
    echo "$(lsb_release -sc) is not supported by $1"
    return 1
  fi
  rm -r /tmp/add-ppa/
}
export -f PPA_check

function userinput_func {
  unset uniq_selection
  height=$(($(echo "$1" | wc -l) + 8))
  height_gui=$(echo $((height * 15 + ${#@} * 20 + 100)))
  height_gui_buttons=$(echo $((height * 15)))
  if [[ $gui == "gui" ]]; then
    if [[ "${#@}" == "2" ]]; then
      echo -e "$1" | yad --class L4T-Megascript --name "L4T Megascript" --fixed --no-escape --undecorated --show-uri --center --image "dialog-information" --borders="20" --title "User Info Prompt" \
        --text-info --fontname="@font@ 11" --wrap --width=800 --height=$height_gui \
        --window-icon=/usr/share/icons/L4T-Megascript.png \
        --button="$2":0
      output="$2"
    elif [[ "${#@}" == "3" ]]; then
      yad --class L4T-Megascript --name "L4T Megascript" --image "dialog-question" \
        --borders="20" --height=$height_gui_buttons --center --fixed --window-icon=/usr/share/icons/L4T-Megascript.png \
        --text="$1" \
        --button="$2":0 \
        --button="$3":1
      if [[ $? -ne 0 ]]; then
        output="$3"
      else
        output="$2"
      fi
    else
      for string in "${@:2}"; do
        uniq_selection+=(FALSE "$string")
      done
      uniq_selection[0]=TRUE
      output=$(
        yad --class L4T-Megascript --name "L4T Megascript" --center --fixed --height=$height_gui --borders="20" \
          --window-icon=/usr/share/icons/L4T-Megascript.png \
          --text "$1" \
          --list \
          --radiolist \
          --column "" \
          --column "Selection" \
          --print-column=2 \
          --separator='' \
          --button="Ok":0 \
          "${uniq_selection[@]}"
      )
    fi
  else
    if [[ "${#@}" == "3" ]]; then
      dialog --stdout --clear --yes-label "$2" --no-label "$3" --yesno "$1" "$height" "120"
      if [[ $? -ne 0 ]]; then
        output="$3"
      else
        output="$2"
      fi
    else
      for string in "${@:2}"; do
        uniq_selection+=("$string" "")
      done
      output=$(
        dialog --stdout --clear \
          --backtitle "CLI Chooser Helper" \
          --title "Choices" \
          --menu "$1" \
          "$height" "120" "$($# - 1)" \
          "${uniq_selection[@]}"
      )
    fi
  fi
  status=$?
  if [[ $status = "1" ]]; then
    clear -x
    echo "Canceling Install, Back to the Megascript"
    exit 1
  fi
  clear -x
}
export -f userinput_func

function ppa_installer {
  local ppa_grep="$ppa_name"
  [[ "${ppa_name}" != */ ]] && local ppa_grep="${ppa_name}/"
  local ppa_added=$(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep -v list.save | grep -v deb-src | grep deb | grep -v '#' | grep "$ppa_grep" | wc -l)
  if [[ $ppa_added -eq "1" ]]; then
    echo "Skipping $ppa_name PPA, already added"
  else
    echo "Adding $ppa_name PPA"
    sudo apt install software-properties-common -y || error "Failed to install ppa_installer dependencies"
    hash -r
    sudo add-apt-repository "ppa:$ppa_name" -y
    sudo apt update
  fi
  unset ppa_name
}
export -f ppa_installer

ubuntu_ppa_installer() { #setup a PPA on an Ubuntu distro. Arguments: ppa_name
  local ppa_name="$1"
  [ -z "$1" ] && error "ubuntu_ppa_installer(): This function is used to add a ppa to a ubuntu based install but a required input argument was missing."
  local ppa_grep="$ppa_name"
  [[ "${ppa_name}" != */ ]] && local ppa_grep="${ppa_name}/"
  local ppa_added=$(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/*.list | grep -v deb-src | grep deb | grep -v '#' | grep "$ppa_grep" | wc -l)
  if [[ $ppa_added -eq "1" ]]; then
    status "Skipping $ppa_name PPA, already added"
  else
    status "Adding $ppa_name PPA"
    sudo add-apt-repository "ppa:$ppa_name" -y || exit 1
    apt_lock_wait
    sudo apt update || exit 1
  fi
  # check if ppa .list filename does not exist under the current distro codename
  # on a distro upgrade the .list filename is not updated and add-apt-repository can re-use the old filename
  local ppa_dist="$__os_codename"
  local standard_filename="/etc/apt/sources.list.d/${ppa_name%/*}-ubuntu-${ppa_name#*/}-${ppa_dist}.list" 
  if [[ ! -f "$standard_filename" ]] && ls /etc/apt/sources.list.d/${ppa_name%/*}-ubuntu-${ppa_name#*/}-*.list 1> /dev/null; then
    local original_filename="$(ls /etc/apt/sources.list.d/${ppa_name%/*}-ubuntu-${ppa_name#*/}-*.list | head -1)"
    # change the filename to match the current distro codename
    sudo mv "$original_filename" "$standard_filename"
    sudo rm -f "$original_filename".distUpgrade
    sudo rm -f "$original_filename".save
  fi
}
export -f ubuntu_ppa_installer

debian_ppa_installer() {
  local ppa_name="$1"
  local ppa_dist="$2"
  local key="$3"
  [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] && error "debian_ppa_installer(): This function is used to add a ppa to a debian based install but a required input argument was missing."
  local ppa_grep="$ppa_name"
  [[ "${ppa_name}" != */ ]] && local ppa_grep="${ppa_name}/ubuntu ${ppa_dist}"
  local ppa_added=$(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep -v list.save | grep -v deb-src | grep deb | grep -v '#' | grep "$ppa_grep" | wc -l)
  if [[ $ppa_added -eq "1" ]]; then
    status "Skipping $ppa_name PPA, already added"
  else
    status "Adding $ppa_name PPA"
    echo "deb https://ppa.launchpadcontent.net/${ppa_name}/ubuntu ${ppa_dist} main" | sudo tee /etc/apt/sources.list.d/${ppa_name%/*}-ubuntu-${ppa_name#*/}-${ppa_dist}.list || error "Failed to add repository to sources.list!"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$key"
    if [ $? != 0 ]; then
      sudo rm -f /etc/apt/sources.list.d/${ppa_name%/*}-ubuntu-${ppa_name#*/}-${ppa_dist}.list
      error "Failed to sign the $ppa_name PPA!"
    fi
    apt_lock_wait
    sudo apt update || exit 1
  fi
}
export -f debian_ppa_installer

add_external_repo() { # add an external apt repo and its gpg key.
  # follows https://wiki.debian.org/DebianRepository/UseThirdParty specification with deb822 format https://repolib.readthedocs.io/en/latest/deb822-format.html
  # required inputs
  local reponame="$1"
  local pubkeyurl="$2"
  local uris="$3"
  local suites="$4"
  # potentially optional inputs
  # components is not used when suite is an absolute path
  local components="$5"
  # additional options can be specified as the 6th, 7th, 8th, etc argument (eg: "Architectures: arm64")

  # check if all needed vars are set  
  [ -z "$reponame" ] && error "add_external_repo: reponame not set"
  [ -z "$uris" ] && error "add_external_repo: uris not set"
  [ -z "$suites" ] && error "add_external_repo: suites not set"
  [ -z "$pubkeyurl" ] && error "add_external_repo: pubkeyurl not set"

  # exit if reponame or uri or suite contains space
  if [[ $reponame = *" "* ]] || [[ $uris = *" "* ]] || [[ $suites = *" "* ]]; then
    error "add_external_repo: provided reponame contains a space."
  fi

  # check if links are valid
  wget -q --spider "$pubkeyurl" || error "add_external_repo: pubkeyurl isn't a valid link"

  # make apt keyring directory if it doesn't exist
  if [ ! -d /usr/share/keyrings ]; then
    sudo mkdir -p /usr/share/keyrings || error "add_external_repo: failed to create apt keyring directory."
  fi

  # check if .list file already exists
  if [ -f /etc/apt/sources.list.d/${reponame}.list ]; then
    sudo rm -f /etc/apt/sources.list.d/${reponame}.list || error "add_external_repo: failed to remove conflicting .list file."
  fi

  # check if .sources file already exists
  if [ -f /etc/apt/sources.list.d/${reponame}.sources ]; then
    sudo rm -f /etc/apt/sources.list.d/${reponame}.sources || error "add_external_repo: failed to remove conflicting .sources file."
  fi

  # download gpg key from specified url
  if [ -f /usr/share/keyrings/${reponame}-archive-keyring.gpg ]; then
    sudo rm -f /usr/share/keyrings/${reponame}-archive-keyring.gpg
  fi 
  wget -qO- "$pubkeyurl" | sudo gpg --dearmor -o /usr/share/keyrings/${reponame}-archive-keyring.gpg

  if [ $? != 0 ];then
    sudo rm -f /etc/apt/sources.list.d/${reponame}.sources
    sudo rm -f /usr/share/keyrings/${reponame}-archive-keyring.gpg
    error "add_external_repo: download from specified pubkeyurl failed."
  fi

  # create .sources file
  echo "Types: deb
URIs: $uris
Suites: $suites" | sudo tee /etc/apt/sources.list.d/${reponame}.sources >/dev/null
  if [ ! -z "$components" ]; then
    echo "Components: $components" | sudo tee -a /etc/apt/sources.list.d/${reponame}.sources >/dev/null
  fi
  for input in "${@: 6}"; do
    echo "$input" | sudo tee -a /etc/apt/sources.list.d/${reponame}.sources >/dev/null
  done
  echo "Signed-By: /usr/share/keyrings/${reponame}-archive-keyring.gpg" | sudo tee -a /etc/apt/sources.list.d/${reponame}.sources >/dev/null

  if [ $? != 0 ];then
    sudo rm -f /etc/apt/sources.list.d/${reponame}.sources
    sudo rm -f /usr/share/keyrings/${reponame}-archive-keyring.gpg
    error "add_external_repo: failed to create ${reponame}.list file"
  fi
}
export -f add_external_repo

pipx_install() {
  # install pipx keeping in mind distro issues
  # pipx <= 0.16.1 is compatible with 3.7 <= python3 < 3.9
  # pipx >= 0.16.1 is compatible with python3 >= 3.7
  # some distros lack pipx entirely
  # some distros (raspbian bullseye specifically) have incompatible combinations of pipx (0.12.3) and python3 (3.9) versions, necessitating pipx to be installed/upgraded from pip
  # pipx 1.0.0 is the first stable release and has some features that we would like to assume are available, install it from pip if the distro package is too old
  if package_available pipx && package_is_new_enough pipx 1.0.0 ;then
    sudo apt install -y pipx python3-venv || exit 1
  elif package_is_new_enough python3 3.7 ; then
    sudo apt install -y python3-venv || exit 1
    sudo -H python3 -m pip install --upgrade pipx || exit 1
  elif package_available python3.8 ;then
    sudo apt install -y python3.8 python3.8-venv || exit 1
    sudo -H python3.8 -m pip install --upgrade filelock pipx || exit 1
  else
    error "pipx is not available so cannot install powerline-shell to python venv"
  fi
  sudo PIPX_HOME=/usr/local/pipx PIPX_BIN_DIR=/usr/local/bin pipx install "$@" || error "Failed to install $* with pipx"
}
export -f pipx_install

pipx_uninstall() {
  sudo PIPX_HOME=/usr/local/pipx PIPX_BIN_DIR=/usr/local/bin pipx uninstall "$@" || error "Failed to uninstall $* with pipx"
}
export -f pipx_uninstall

function ppa_purger {
  local ppa_grep="$ppa_name"
  [[ "${ppa_name}" != */ ]] && local ppa_grep="${ppa_name}/"
  local ppa_added=$(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep -v list.save | grep -v deb-src | grep deb | grep -v '#' | grep "$ppa_grep" | wc -l)
  echo "$ppa_url"
  if [[ $ppa_added -eq "1" ]]; then
    echo "Removing $ppa_name PPA"
    sudo apt-get install ppa-purge -y
    sudo ppa-purge "ppa:$ppa_name" -y
    sudo apt update
  else
    echo "$ppa_name PPA does not exist, skipping removal"
  fi
  unset ppa_name
}
export -f ppa_purger

function online_check {
  while :; do
    clear -x
    date
    echo "Checking internet connectivity..."
    #silently check connection to github AND githubusercontent, we had an edge case where a guy was getting githubusercontent blocked by his ISP
    wget -q --spider https://github.com && wget -q --spider https://raw.githubusercontent.com/

    #read whether or not it was successful
    #the $? reads the exit code of the previous command, 0 meaning everything works
    if [ $? == 0 ]; then
      echo -e "\e[32mInternet OK\e[0m"
      break
    fi
    #tell people to fix their internet
    echo "You're offline and/or can't reach GitHub."
    echo "We can't run the script without this..."
    echo "You'll need to connect to WiFi or allow GitHub in your firewall."
    echo "(you can close this window at any time.)"
    echo "Retrying the connection in..."
    ########## bootleg progress bar time ##########
    echo -e "\e[31m5\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[33m4\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[32m3\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[34m2\e[0m"
    printf '\a'
    sleep 1
    echo -e "\e[35m1\e[0m"
    printf '\a'
    echo "Trying again..."
    sleep 1
    #and now we let it loop
  done
}
export -f online_check

function runCmd() {
  local ret
  "$@"
  ret=$?
  if [[ "$ret" -ne 0 ]]; then
    echo "${scripts[$word]} reported an error running '$*' - returned $ret" >>/tmp/megascript_errors.txt
  fi
  return $ret
}
export -f runCmd

warning() { #yellow text
  echo -e "\e[93m\e[5m 🔺\e[25m WARNING: $1\e[0m"
}
export -f warning

status() { #cyan text to indicate what is happening
  echo -e "\e[96m$1\e[0m"
}
export -f status

status_green() { #announce the success of a major action
  echo -e "\e[92m$1\e[0m"
}
export -f status_green

function error {
  echo -e "\\e[91m$1\\e[39m"
  sleep 3
  exit 1
}
export -f error

function error_user {
  echo -e "\\e[91m$1\\e[39m"
  sleep 3
  exit 2
}
export -f error_user

format_logfile() { #remove ANSI escape sequences from a given file, and add OS information to beginning of file
  [ -z "$1" ] && error "format_logfile: no filename given!"
  [ ! -f "$1" ] && error "format_logfile: given filename ($1) does not exist or is not a file!"

  echo -e "$model\n\nBEGINNING OF LOG FILE:\n-----------------------\n\n$(cat "$1" | tr '\r' '\n' | sed 's/\x1b\[[0-9;]*m//g' | sed 's/\x1b\[[0-9;]*//g' | sed "s,\x1B\[[0-9;]*[a-zA-Z],,g" | grep -vF '.......... .......... .......... .......... ..........')" >"$1"

}
export -f format_logfile

send_error() {
  case "$__os_id" in
  Fedora)
    curl -F "file=@\"$1\";filename=\"$(basename $1 | sed 's/\.log.*/.txt/g')\"" "$(
      base64 -d <<<$(base64 -d <<<'YUhSMGNITTZMeTlrYVhOamIzSmtMbU52YlM5aGNHa3ZkMlZpYUc5dmEzTXZNVEEzT0RRek5qWXdOek13TWpBME1UY3lNUzl1WldwYQpUd289Cg==') | tr -d '\n'
      base64 -d <<<'R2xxU1BLc212X1ZCT2twZ3BfdnJGRG51RTZPa1BSME41MGgxbkN5TVdnYkxndWczU0dwcVZIZHNHCg==' | tr -d '\n'
      base64 -d <<<'NVFERzhmCg==' | tr -d '\n'
    )" &>/dev/null
    ;;
  *)
    curl -F "file=@\"$1\";filename=\"$(basename $1 | sed 's/\.log.*/.txt/g')\"" "$(
      base64 -d <<<$(base64 -d <<<'YUhSMGNITTZMeTlrYVhOamIzSmtMbU52YlM5aGNHa3ZkMlZpYUc5dmEzTXZPVGN3TkRBd016RTJPVGt5TXprM016a3pMemswYmxSWgo=') | tr -d '\n'
      base64 -d <<<'SUk1TjJQbnJ5dndWamwxaS1keTFXQnBSaDdJTXpVSnliRWo0TmZpTUR2WTE2S2ExU0Rkc2tpLXYx' | tr -d '\n'
      base64 -d <<<'WGpmVmhmCg==' | tr -d '\n'
    )" &>/dev/null
    ;;
  esac
}
export -f send_error

add_english() { # add en_US locale for more accurate error
  if [ "$(cat /usr/share/i18n/SUPPORTED | grep -o 'en_US.UTF-8')" == "en_US.UTF-8" ]; then
    export LANG="en_US.UTF-8"
    export LANGUAGE="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
  else
    export LANG="C.UTF-8"
    export LANGUAGE="C.UTF-8"
    export LC_ALL="C.UTF-8"
    warning "en_US locale is not available on your system. This may cause bad logging experience."
  fi
}
export -f add_english


is_supported_system() { #return 0 if system is supported, otherwise return 1
  local PRETTY_NAME="$(cat /etc/os-release | grep PRETTY_NAME | tr -d '"' | awk -F= '{print $2}')"
  local AVAILABLE_REPOS="$(apt-get indextargets --no-release-info --format '$(SITE) $(RELEASE) $(COMPONENT) $(TARGET_OF)' | sort -u | awk '{if ($4=="deb") print $1" "$2" "$3 }' | grep -v '$(COMPONENT)$')"
  local DEFAULT_REPOS="$(echo "$AVAILABLE_REPOS" | grep "raspbian.raspberrypi.org/raspbian\|archive.raspberrypi.org/debian\|\
raspbian.raspberrypi.com/raspbian\|archive.raspberrypi.com/debian\|\
debian.org/debian\|security.debian.org/\|\
ports.ubuntu.com\|esm.ubuntu.com/apps/ubuntu\|esm.ubuntu.com/infra/ubuntu\|archive.ubuntu.com/ubuntu\|security.ubuntu.com/ubuntu\|\
repo.huaweicloud.com/debian\|repo.huaweicloud.com/ubuntu-ports\|\
deb-multimedia.org|\
apt.pop-os.org\|\
apt.armbian.com")"
  if [ "$__os_codename" == focal ] && ( echo "$model" | grep -q "Nintendo Switch" || echo "$model" | grep -q [Ii]cosa ) ; then
    echo "Switchroot does not support Ubuntu Focal on Nintendo Switch."
    echo "Please install Switchroot Ubuntu Bionic or Switchroot Ubuntu Jammy."
    return 1
  elif local frankendebian="$(echo "$DEFAULT_REPOS" | grep -v $__os_codename)" && [ ! -z "$frankendebian" ];then
    echo "Congratulations, Linux tinkerer, you broke your system. You have made your system a FrankenDebian.
This website explains your mistake in more detail: https://wiki.debian.org/DontBreakDebian
Your current reported release (${__os_codename^}) should not be combined with other releases.
Specifically, the issue is $(wc -l <<<"$frankendebian" | grep -q 1 && echo 'this line' || echo 'these lines'):"
    local IFS=$'\n'
    for line in $frankendebian ;do
      local site="$(echo "$line" | awk '{print $1}')"
      local release="$(echo "$line" | awk '{print $2}')"
      echo -e "\e[4m$line\e[24m in $(apt-get indextargets --no-release-info --format '$(SOURCESENTRY)' "Release: $release" "Site: $site" | awk -F':' '{print $1}' | sort -u)"
    done
    echo "Your system might be recoverable if you did this recently and have not performed an apt upgrade yet, but otherwise you should probably reinstall your OS."
    return 1
  elif ! package_available init; then
    echo "Congratulations, Linux tinkerer, you broke your system. The init package can not be found, which means you have removed the default debian sources from your system.
All apt based application installs will fail. Unless you have a backup of your /etc/apt/sources.list /etc/apt/sources.list.d you will need to reinstall your OS."
    return 1
  elif [ -z "$AVAILABLE_REPOS" ];then
    echo "Congratulations, Linux tinkerer, you broke your system. You have removed ALL debian sources from your system.
All apt based application installs will fail. Unless you have a backup of your /etc/apt/sources.list /etc/apt/sources.list.d you will need to reinstall your OS."
  elif [ "$__os_id" == "Ubuntu" ] && ! ( echo "$DEFAULT_REPOS" | grep "$__os_codename " | awk '{if ($3=="main" || $3=="universe") print $3 }' | sort -u | tr '\n' ' ' | grep -q "main universe" && \
    echo "$DEFAULT_REPOS" | grep "$__os_codename-updates " | awk '{if ($3=="main" || $3=="universe") print $3 }' | sort -u | tr '\n' ' ' | grep -q "main universe" && \
    echo "$DEFAULT_REPOS" | grep "$__os_codename-security " | awk '{if ($3=="main" || $3=="universe") print $3 }' | sort -u | tr '\n' ' ' | grep -q "main universe" ); then
    echo "MISSING Default Ubuntu Repositories!
L4T-Megascript does NOT support systems without ALL of $__os_codename, $__os_codename-updates, and $__os_codename-security dists and main and universe components present in the sources.list
Please refer to the default sources.list for Ubuntu and restore all required dists and components."
    return 1
  elif [ -f /etc/switchroot_version.conf ] && [ "$__os_id" == "Ubuntu" ] && ([ "$__os_codename" == "jammy" ] || [ "$__os_codename" == "noble" ]) && ! echo "$AVAILABLE_REPOS" | grep -q "https://theofficialgman.github.io/l4t-debs l4t $__os_codename"; then
    echo "MISSING Default Switchroot Repository!
Please reflash Switchroot Ubuntu ${__os_codename^}."
    return 1
  elif [ -f /etc/switchroot_version.conf ] && [ "$__os_id" == "Ubuntu" ] && [ "$__os_codename" == "bionic" ] && ! echo "$AVAILABLE_REPOS" | grep -q "https://newrepo.switchroot.org switchroot unstable"; then
    echo "MISSING Default Switchroot Repository!
Please reflash Switchroot Ubuntu ${__os_codename^}."
    return 1
  elif ! apt-get --dry-run check &>/dev/null ; then
    echo "Congratulations, Linux tinkerer, you broke your system. There are packages on your system that are in a broken state.
Refer to the output below for any potential solutions.

$(apt-get --dry-run check)"
    return 1
  else
    return 0
  fi
}
export -f is_supported_system

### pi-apps functions

#package functions
package_info() { #list everything dpkg knows about the $1 package
  local package="$1"
  [ -z "$package" ] && error "package_info(): no package specified!"
  #list lines in /var/lib/dpkg/status between the package name and the next empty line
  sed -n -e '/^Package: '"$package"'$/,/^$/p' /var/lib/dpkg/status
  true #this may exit with code 141 if the pipe was closed early (to be expected with grep -v)
}
export -f package_info

package_installed() { #exit 0 if $1 package is installed, otherwise exit 1
  local package="$1"
  [ -z "$package" ] && error "package_installed(): no package specified!"
  #find the package listed in /var/lib/dpkg/status
  #package_info "$package" | grep -q '^Status: install ok installed$'

  #directly search /var/lib/dpkg/status
  grep '^Status: install ok installed$\|^Package:' /var/lib/dpkg/status | grep "$package" --after 1 | grep -q 'Status: install ok installed'
}
export -f package_installed

package_available() { #determine if the specified package-name exists in a local repository for the current dpkg architecture
  local package="$(awk -F: '{print $1}' <<<"$1")"
  local dpkg_arch="$(awk -F: '{print $2}' <<<"$2")"
  [ -z "$dpkg_arch" ] && dpkg_arch="$(dpkg --print-architecture)"
  [ -z "$package" ] && error "package_available(): no package name specified!"
  local output="$(apt-cache policy "$package":"$dpkg_arch" | grep "Candidate:")"
  if [ -z "$output" ]; then
    return 1
  elif echo "$output" | grep -q "Candidate: (none)"; then
    return 1
  else
    return 0
  fi
}
export -f package_available

package_dependencies() { #outputs the list of dependencies for the $1 package
  local package="$1"
  [ -z "$package" ] && error "package_dependencies(): no package specified!"

  #find the package listed in /var/lib/dpkg/status
  package_info "$package" | grep '^Depends: ' | sed 's/^Depends: //g'
}
export -f package_dependencies

package_latest_version() { #returns the latest available versions of the specified package-name. Doesn't matter if it's installed or not.
  local package="$1"
  [ -z "$package" ] && error "package_latest_version(): no package specified!"
  
  # use slower but more accurate apt list command to get package version for current architecture
  apt-cache policy "$package" 2>/dev/null | grep "Candidate: " | awk '{print $2}'
  #grep -rx "Package: $package" /var/lib/apt/lists --exclude="lock" --exclude-dir="partial" --after 4 | grep -o 'Version: .*' | awk '{print $2}' | sort -rV | head -n1
}

export -f package_latest_version

package_is_new_enough() { #check if the $1 package has an available version greater than or equal to $2
  local package="$1"
  [ -z "$package" ] && error "package_is_new_enough(): no package specified!"
  
  local compare_version="$2"
  [ -z "$package" ] && error "package_is_new_enough(): no comparison version number specified!"
  
  #determine the latest available version for the specified package
  local package_version="$(package_latest_version "$package")"
  
  #if version value not found, return 1 now
  if [ -z "$package_version" ];then
    return 1
  fi
  
  #given both the package_version and compare_version, see if the greater of the two is the available package's version
  if [ "$(echo "$package_version"$'\n'"$compare_version" | sort -rV | head -n1)" == "$package_version" ];then
    #if so, indicate success
    return 0
  else
    return 1
  fi
}

export -f package_is_new_enough

anything_installed_from_repo() { #Given an apt repository URL, determine if any packages from it are currently installed
  [ -z "$1" ] && error "anything_installed_from_repo: A repository URL must be specified."

  #user input repo-url. Remove 'https://', and translate '/' to '_' to conform to apt file-naming standard
  local url="$(echo "$1" | sed 's+.*://++g' | sed 's+/+_+g')"

  #find all package-lists pertaining to the url
  local repofiles="$(ls /var/lib/apt/lists/*_Packages | grep "$url")"

  #for every repo-file, chack if any of them have an installed file
  local found=0
  local IFS=$'\n'
  local repofile
  for repofile in $repofiles; do
    #search the repo-file for installed packages
    grep '^Package' "$repofile" | awk '{print $2}' | while read -r package; do
      if package_installed "$package"; then
        echo "Package installed: $package"
        exit 1
      fi
    done #if exit code is 1, search was successful. If exit code is 0, no packages from the repo were installed.

    found=$?

    if [ $found == 1 ]; then
      break
    fi
  done

  #return an exit code
  if [ $found == 1 ]; then
    return 0
  else
    return 1
  fi
}
export -f anything_installed_from_repo

remove_repofile_if_unused() { #Given a sources.list.d file, delete it if nothing from that repository is currently installed. Deletion skipped if $2 is 'test'
  local file="$1"
  local testmode="$2"
  [ -z "$file" ] && error "remove_repo_if_unused: no sources.list.d file specified!"
  #exit now if the list file does not exist
  [ -f "$file" ] || exit 0

  #determine what repo-urls are in the file
  local urls="$(cat "$file" | grep -v '^#' | tr ' ' '\n' | grep '://')"

  #there could be multiple urls in one file. Check each url and set the in_use variuable to 1 if any packages are found
  local IFS=$'\n'
  local in_use=0
  local url
  for url in $urls; do
    if anything_installed_from_repo "$url" >/dev/null; then
      in_use=1
      break
    fi
  done

  if [ "$in_use" == 0 ] && [ "$testmode" == test ]; then
    echo "The given repository is not in use and can be deleted:"$'\n'"$file" 1>&2
  elif [ "$in_use" == 0 ]; then
    status "Removing the $(basename "$file" | sed 's/.list$//g') repo as it is not being used"
    sudo rm -f "$file"
  fi

}
export -f remove_repofile_if_unused

apt_lock_wait() { #Wait until other apt processes are finished before proceeding
  #make sure english locale is added first
  add_english

  echo "Waiting until APT locks are released... "
  sp="/-\|"
  while [ ! -z "$(sudo fuser /var/lib/dpkg/lock /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/log/unattended-upgrades/unattended-upgrades.log /var/lib/dpkg/lock-frontend 2>/dev/null)" ]; do
    echo -en "Waiting for another script to finish before continuing... ${sp:i++%${#sp}:1} \e[0K\r" 1>&2
    sleep 1
  done
  
  #Try to install a non-existent package to see if apt fails due to a lock-file. Repeat until no errors mention 'Could not get lock'
  while sudo -E apt install lkqecjhxwqekc 2>&1 | grep -q 'Could not get lock' ;do
    echo -en "Waiting for another script to finish before continuing... ${sp:i++%${#sp}:1} \e[0K\r" 1>&2
    sleep 1
  done
}
export -f apt_lock_wait

#miscellaneous low-level functions below
runonce() { #run command only if it's never been run before. Useful for one-time migration or setting changes.
  #Runs a script in the form of stdin

  script="$(</dev/stdin)"

  runonce_hash="$(sha1sum <<<"$script" | awk '{print $1}')"

  mkdir -p "${DIRECTORY}/data"

  if [ -s "${DIRECTORY}/data/runonce_hashes" ] && while read line; do [[ $line == "$runonce_hash" ]] && break; done <"${DIRECTORY}/data/runonce_hashes"; then
    #hash found
    #echo "runonce: '$script' already run before. Skipping."
    true
  else
    #run the script.
    bash <(echo "$script")
    #if it succeeds, add the hash to the list to never run it again
    if [ $? == 0 ]; then
      echo "$runonce_hash" >>"${DIRECTORY}/data/runonce_hashes"
      echo "runonce(): '$script' succeeded. Added to list."
    else
      echo "runonce(): '$script' failed. Not adding hash to list."
    fi

  fi

}
export -f runonce

sudo_popup() { #just like sudo on passwordless systems like PiOS, but displays a password dialog otherwise. Avoids displaying a password prompt to an invisible terminal.
  if sudo -n true; then
    # sudo is available (within sudo timer) or passwordless
    sudo "$@"
  else
    # sudo is not available (not within sudo timer)
    pkexec "$@"
  fi
}
export -f sudo_popup

# wrap sudo function so we can catch "sudo apt" and "sudo apt-get" usage. Sudo can't normally run functions so we can't just wrap "apt" or "apt-get" without changing every script
function sudo {
  if [ "$1" == "apt" ]; then
    apt_lock_wait
    command sudo "$@"
  elif [ "$1" == "apt-get" ]; then
    apt_lock_wait
    command sudo "$@"
  else
    command sudo "$@"
  fi
}
export -f sudo

# make sure pip works
export PATH=$HOME/.local/bin:$PATH

#####################################################################################
# don't remove this line
# it is used to verify that the entire functions file was sourced
export functions_downloaded="success"
#####################################################################################

#end of functions used by megascript scripts

#####################################################################################
