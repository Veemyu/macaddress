#! /bin/sh

set -e
set -o pipefail

export LC_CTYPE=C

basedir=$(dirname "$0")

while true; do
  prefix=$(printf "%02x" $(( RANDOM % 128 )))

  even_prefix=$((16#${prefix}%2))
  if [[ $even_prefix -eq 0 ]]; then
    break
  fi
done

mac_prefix="${prefix}-"
mac_prefix=$(echo $mac_prefix | tr '[:lower:]' '[:upper:]')

rand=$(openssl rand -hex 5 | sed 's/\(..\)/\1-/g; s/.$//' | tr '[:lower:]' '[:upper:]')

host_name="${mac_prefix}${rand}"

computer_name=$(echo $host_name | tr '-' ':')
echo $computer_name
echo $host_name
sudo scutil --set ComputerName "$computer_name"
sudo scutil --set LocalHostName "$host_name"
sudo scutil --set HostName "$host_name"
printf "%s\n" "Spoofed hostname to $host_name"

# Spoof MAC address of Wi-Fi interface
#mac_address_prefix=$(networksetup -listallhardwareports | awk -v RS= '/en0/{print $NF}' | head -c 8)
#mac_address_suffix=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
mac_address=$(echo "$computer_name" | awk '{print tolower($0)}')
echo "Here comes the Mac ADDRESS"
echo $mac_address
networksetup -setairportpower en0 on
sudo /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --disassociate
sudo ifconfig en0 ether "$mac_address"
printf "%s\n" "Spoofed MAC address of en0 interface to $mac_address"
