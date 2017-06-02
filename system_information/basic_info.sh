#!/bin/bash

tool_install(){
for i in `dmidecode -t system |grep Manufacturer |awk -F":" '{print $2}'`
do
    if [ $i == 'HP' ];then
		yum install gcc gcc-c++ -y
		rpm -ivh http://file.idc.pub/software/HPRaid/hpacucli-9.0-24.0.noarch.rpm >> /dev/null
    else
		rpm -ivh http://file.idc.pub/software/LSI-ToolsMegacli/Lib_Utils-1.00-09.noarch.rpm >> /dev/null
		rpm -ivh http://file.idc.pub/software/LSI-ToolsMegacli/MegaCli-8.00.48-1.i386.rpm /dev/null
    fi
done
}
#tool_install

system_message=`dmidecode -t system |grep -e "Manufacturer" -e "Serial" -e 'Product Name'`
memory_infromation=`dmidecode | grep -P -A 5 "Memory\s+Device" | grep Size |grep -v Range |sort`
memory_size_one=`dmidecode | grep -P -A 5 "Memory\s+Device" | grep Size |grep -v Range |sort|grep MB|awk '{print $2}'|uniq`
memory_size_num=`dmidecode | grep -P -A 5 "Memory\s+Device" | grep Size |grep -v Range |sort|grep MB|awk '{print $2}'|wc -l`
memory_size_total=$(($memory_size_one*$memory_size_num))
memory_frequency=`dmidecode | grep -A16 "Memory Device" | grep 'Speed' |grep MHz`
maximum_memory_mount=`dmidecode | grep -P 'Maximum\s+Capacity'`
cpu_num=`cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
cpu_core_sigle=`cat /proc/cpuinfo| grep "cpu cores"| uniq`
cpu_logic=`cat /proc/cpuinfo| grep "processor"| wc -l`
cpu_basic_frequency=`cat /proc/cpuinfo |grep MHz|uniq`
PCIE_Slot_number=`dmidecode -t slot |grep Type|wc -l`
PCIE_Slot_type=`dmidecode -t slot |grep "PCI Express"`

basic_echo(){
	echo -e "\e[32m ##manufacturer、type、SN####################################### \e[0m"
	echo -e "\e[31m $system_message \e[0m"
	echo -e "\e[32m ##memory information########################################### \e[0m"
	echo -e "\e[31m $memory_infromation \e[0m"
	echo -e "\e[32m ##memory size total############################################ \e[0m"
	echo -e "\e[31m $memory_size_total MB/GB \e[0m"
	echo -e "\e[32m ##memory frequency############################################# \e[0m"	
	echo -e "\e[31m $memory_frequency \e[0m"
	echo -e "\e[32m ##maximum memory mount######################################### \e[0m"	
	echo -e "\e[31m $maximum_memory_mount \e[0m"
	echo -e "\e[32m ##physical CPU's number######################################## \e[0m"	
	echo -e "\e[31m $cpu_num \e[0m"
	echo -e "\e[32m ##cores of each CPU############################################ \e[0m"	
	echo -e "\e[31m $cpu_core_sigle \e[0m"
	echo -e "\e[32m ##logic CPU's number########################################### \e[0m"	
	echo -e "\e[31m $cpu_logic \e[0m"
	echo -e "\e[32m ##cpu basic frequency########################################## \e[0m"	
	echo -e "\e[31m $cpu_basic_frequency \e[0m"
	echo -e "\e[32m ##PCIE Slot number############################################# \e[0m"	
	echo -e "\e[31m $PCIE_Slot_number \e[0m"
	echo -e "\e[32m ##PCIE Slot type############################################### \e[0m"	
	echo -e "\e[31m $PCIE_Slot_type \e[0m"
}
hp_raid_echo(){
	echo -e "\e[32m ##raid SN###################################################### \e[0m"
	echo -e "\e[31m $hp_raid_sn \e[0m"
	echo -e "\e[32m ##raid level and Disk capacity################################# \e[0m"	
	echo -e "\e[31m $raid_level \e[0m"
	echo -e "\e[32m ##The number of physical disk size and capacity################ \e[0m"
	echo -e "\e[31m $physical_hp_num_size \e[0m" 
	echo -e "\e[32m ##hard drive size############################################## \e[0m"
	echo -e "\e[31m $hard_drive_size \e[0m"
}
ibm_raid_echo(){
	echo -e "\e[32m ##raid information############################################# \e[0m"
	echo -e "\e[31m $raid_message \e[0m"
	echo -e "\e[32m ##disk size#################################################### \e[0m"	
	echo -e "\e[31m $disk_size \e[0m"
	echo -e "\e[32m ##The number of physical disk size and capacity################ \e[0m"
	echo -e "\e[31m $physical_disk_num_size \e[0m"
	echo -e "\e[32m ##Raid cache information####################################### \e[0m"
	echo -e "\e[31m $raid_cache \e[0m"
	echo -e "\e[32m ##battery information########################################## \e[0m"
	echo -e "\e[31m $battery_message \e[0m"
	echo -e "\e[32m ##disk status################################################## \e[0m"
	echo -e "\e[31m $disk_status \e[0m"
	echo -e "\e[32m ##each RAID Logical Disk####################################### \e[0m"
	echo -e "\e[31m $raid_local_disk \e[0m"
}
raid_func(){
#i=`dmidecode -t system |grep Manufacturer |awk -F":" '{print $2}'`
    if dmidecode -t system |grep Manufacturer|grep -e "HP" -e "Hewlett-Packard" ;then
		if [ -f /usr/sbin/hpacucli ];then
			hp_raid_sn=`hpacucli ctrl all show`
			raid_level=`hpacucli ctrl slot=0 ld all show`
			physical_hp_num_size=`hpacucli ctrl slot=0 pd all show`
			hard_drive_size=`hpacucli ctrl slot=0 array A ld 1 show`
			hp_raid_echo
		elif [ -f /usr/sbin/hpssacli ];then
			hp_raid_sn=`hpssacli ctrl all show`
			raid_level=`hpssacli ctrl slot=0 ld all show`
			physical_hp_num_size=`hpssacli ctrl slot=0 pd all show`
			hard_drive_size=`hpssacli ctrl slot=0 array A ld 1 show`
			hp_raid_echo
		else
			echo "hpacucli/hpssacli: command not found,HP raid tools no setup!"	
		fi
    else
		raid_message=`/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aALL|grep -i raid`
		disk_size=`/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aALL |grep -i size|grep -vi strip|awk -F":" '{print $2}'`
		physical_disk_num_size=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep -e "Slot" -e "Raw"`
		raid_cache=`/opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -LALL -aAll |grep -e "Virtual" -e "Default" -e "Current"`
		battery_message=`/opt/MegaRAID/MegaCli/MegaCli64 -AdpBbuCmd -aAll`
		raid_local_disk=`/opt/MegaRAID/MegaCli/MegaCli64 -LdPdInfo-aAll -NoLog|grep -Ei '(^Virtual Disk|^RAID Level|^PD type|^Raw Size|^Enclosure|^Slot|error|firmware)'| awk '{if($0~/^Virtual/||$0~/^RAID/){printf("\033[35m%s\033[0m\n",$0)}else if($0 ~ /^Enclosure/){printf("\033[31m%s: %s\033[0m ",$1,$4)}else if($0 ~ /^Slot/){printf("\033[31m%s\033[0m\n",$0)}else if($0~/^Other/||$0~/Firmware/){printf("\033[33m%s\033[0m\n",$0)}else if($0~/^Raw/){printf("\033[33m%s%s\033[0m\n",$2,$3)}else{printf("\033[33m%s\033[0m ",$0)}}'`
		disk_status=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList-aAll -NoLog| grep -Ei '(enclosure|slot|error|firmware|pre|Foreign|^PD type|^Raw Size)'| awk '{if($0 ~ /Slot Number/ || $0 ~ /Enclosure/){printf("\033[32m%s ",$0);if($0 ~/Slot Number/) printf("\033[0m \n")}else if($0 ~ /bad/||$0 ~/Failed/||$0 ~ /Foreign State: Foreign/){print "\033[31m"$0"\033[0m"}else{print "\033[33m"$0"\033[0m"}}'`
		ibm_raid_echo
    fi
}

hint="please input a number ：		
		basic information   => 1
		memory information  => 2
		CPU information     => 3
		PCIE information    => 4
		raid information    => 5
		ALL information     => Enter
		===>>>"
read -p "$hint" number
case $number in 
	"1")
	echo -e "\n"
	echo -e "\e[32m ##manufacturer、type、SN####################################### \e[0m"
	echo -e "\e[31m $system_message \e[0m"
	;;
	"2")
	echo -e "\n"
	echo -e "\e[32m ##memory information########################################### \e[0m"
	echo -e "\e[31m $memory_infromation \e[0m"
	echo -e "\e[32m ##memory size total############################################ \e[0m"
	echo -e "\e[31m $memory_size_total MB/GB \e[0m"
	echo -e "\e[32m ##memory frequency############################################# \e[0m"	
	echo -e "\e[31m $memory_frequency \e[0m"
	echo -e "\e[32m ##maximum memory mount######################################### \e[0m"	
	echo -e "\e[31m $maximum_memory_mount \e[0m"
	;;
	"3")
	echo -e "\n"
	echo -e "\e[32m ##physical CPU's number######################################## \e[0m"
	echo -e "\e[31m $cpu_num \e[0m"
	echo -e "\e[32m ##cores of each CPU############################################ \e[0m"	
	echo -e "\e[31m $cpu_core_sigle \e[0m"
	echo -e "\e[32m ##logic CPU's number########################################### \e[0m"	
	echo -e "\e[31m $cpu_logic \e[0m"
	echo -e "\e[32m ##cpu basic frequency########################################## \e[0m"	
	echo -e "\e[31m $cpu_basic_frequency \e[0m"
	;;
	"4")
	echo -e "\n"
	echo -e "\e[32m ##PCIE Slot number############################################# \e[0m"	
	echo -e "\e[31m $PCIE_Slot_number \e[0m"
	echo -e "\e[32m ##PCIE Slot type############################################### \e[0m"	
	echo -e "\e[31m $PCIE_Slot_type \e[0m"
	;;
	"5")
	echo -e "\n"
	raid_func
	;;
	"")
	echo -e "\n"
	basic_echo
	raid_func
	;;
	*)
	echo "You input a unexpected number"
esac





