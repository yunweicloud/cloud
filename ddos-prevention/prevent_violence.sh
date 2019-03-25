#!/bin/bash
#Author and Date: Nong-v 2019-03-25
#The script is designed according to the connection failure of ssh. 
#When the consecutive ssh connection fails 5 times, it will be based on the 10 records of the recent connection failure recorded in the log. 
#If the same IP address appears in this 10, it is considered This IP is brute force server.
#The script will call iptables policy, this ip is blocked.

tail -0f /var/log/secure|while read line;do
	echo $line|grep  'Failed password' &>/dev/null && let sum++
	if [ $sum -ge 5 ];then
		for i in `seq $(awk '/Failed password/' /var/log/secure|tail|awk '{print $11}'|sort|uniq|wc -l)`;do
		ip_sum=$(awk '/Failed password/' /var/log/secure|tail|awk '{print $11}'|sort|uniq -c|awk NR==$i'{print $1')	
		ip=$(awk '/Failed password/' /var/log/secure|tail|awk '{print $11}'|sort|uniq -c|awk NR==$i'{print $2}')
		if [ $ip_sum -ge 3 ];then
			iptables -A INPUT -s $ip -j DROP
		fi
		sum=0
		done
	fi
done
