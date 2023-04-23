#!/bin/bash
# Purpose: To prepare the server prior to joining domain

log="/var/log/Server_Setup.log"

## Update Server Hostname
echo -e "----Updating Server Hostname----" 2>&1 | tee $log
read -p "Enter Server's hostname: " hostname
        echo -e "Input hostname = $hostname" 2>&1 | tee -a $log
hostnamectl set-hostname $hostname
systemctl restart systemd-hostnamed
        echo -e "----Checking Hostname Update Status----" 2>&1 | tee -a $log
systemctl status systemd-hostnamed | grep -A5 -i $hostname 2>&1 | tee -a $log
        if [ $? -eq 0 ]
                then
                echo -e "hostname -- $hostname was updated successfully" 2>&1 | tee -a $log
        fi
echo -e "..\n..\n.." 2>&1 | tee -a $log

## Update Server's Application Header to Warning Banner
echo -e "----Updating Application Header to Warning Banner----" 2>&1 | tee -a $log
read -p "Enter Application Header follow by Environment, e.g. APPS-UAT: " header
sed -i.bak -e "s|SYSTEMNAME\-ENV|$header|g" /etc/issue
sed -i.bak -e "s|SYSTEMNAME\-ENV|$header|g" /etc/issue.net
sed -i.bak -e "s|SYSTEMNAME\-ENV|$header|g" /etc/motd
sed -i.bak -e "s|SYSTEMNAME\-ENV|$header|g" /etc/dconf/db/gdm.d/01-banner-message
grep -e "$header" /etc/issue* /etc/motd /etc/dconf/db/gdm.d/01-banner-message
echo -e "..\n..\n.." 2>&1 | tee -a $log

## Update Server Network-script
echo -e "----Updating Network Info----" 2>&1 | tee -a $log
read -p "Enter Server's IP Address: " ipaddr
read -p "Enter Server's Gateway IP: " gateway
read -p "Enter NETMASK: " netmask
read -p "Enter Production NIC's MAC Address:" hwaddr
echo -e "Select Domain 1.Domain1 2.Domain2"
while :
do
        read domain
        case $domain in
                1)
                        DNS1="primary dns server ipaddr"
                        DNS2="secondary dns server ipaddr"
                        echo "Noted."
                        break
                        ;;
                2)
                        DNS1="primary dns server ipaddr"
                        DNS2="secondary dns server ipaddr"
                        echo "Noted."
                        break
                        ;;
                *)
                        echo "Please retry."
                        ;;

        esac
done

echo -e "----Checking network update status----" 2>&1 | tee -a $log
sed -i.bak '/^IPADDR/d' /etc/sysconfig/network-scripts/ifcfg-ens160
sed -i.bak '/^DNS/d' /etc/sysconfig/network-scripts/ifcfg-ens160
sed -i.bak '/^GATEWAY/d' /etc/sysconfig/network-scripts/ifcfg-ens160
sed -i.bak '/^PREFIX/d' /etc/sysconfig/network-scripts/ifcfg-ens160
sed -i.bak '/^ONBOOT/d' /etc/sysconfig/network-scripts/ifcfg-ens160
sed -i.bak '/^BOOTPROTO/d' /etc/sysconfig/network-scripts/ifcfg-ens160
sed -i.bak '/^HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-ens160
echo -e "BOOTPROTO=none\nHWADDR=$hwaddr\nONBOOT=yes\nIPADDR=$ipaddr\nGATEWAY=$gateway\nNETMASK=$netmask\nDNS1=$DNS1\nDNS2=$DNS2" >> /etc/sysconfig/network-scripts/ifcfg-ens160
grep -e "IPADDR\|DNS\|GATEWAY\|ONBOOT\|BOOTPROTO\|NETMASK\|HWADDR" /etc/sysconfig/network-scripts/ifcfg-ens160 2>&1 | tee -a $log
echo -e "..\n..\n.." 2>&1 | tee -a $log

## Restart Network service and NetworkManager
echo -e "----Restarting Network and Showing Network Service Status----" 2>&1 | tee -a $log
systemctl restart network
systemctl status network -l | grep -n5 "Process" 2>&1 | tee -a $log
echo -e "........" 2>&1 | tee -a $log
systemctl restart NetworkManager
systemctl status NetworkManager -l | grep -n5 "Process" 2>&1 | tee -a $log
echo -e "....\n...." 2>&1 | tee -a $log
ip a s | grep -A2 ens160 2>&1 | tee -a $log
echo -e "..\n..\n.." 2>&1 | tee -a $log

## To enable timestamp on history
echo "export HISTTIMEFORMAT='%F %T -> '" | tee -a /etc/profile /etc/bashrc
source /etc/bashrc
# echo -e "----Showing last 5 history entries with timestamp----" 2>&1 | tee -a $log
# history | tail -5 2>&1 | tee -a $log
echo -e "..\n..\n.." 2>&1 | tee -a $log

## Create Interim Local Admin Account to Apps Vendor
echo -e "----Creating Interim Local Admin Account----" 2>&1 | tee -a $log
read -p "Enter Interim Account to be created: " account
read -p "Enter Interim Password for account, $account: " password
useradd -g wheel $account
echo "$password" | passwd --stdin $account
echo -e "----Wheel account, $account has been successfully created with standard password, $password ----" 2>&1 | tee -a $log
echo -e "----Verifying account creation.." 2>&1 | tee -a $log
grep -e "$account" /etc/passwd 2>&1 | tee -a $log
echo -e "..\n..\n.." 2>&1 | tee -a $log

echo -e "--------Server Initial Setup has been successfully completed. Please refer to $log for more information--------"