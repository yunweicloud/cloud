#!/bin/bash
#According to the log records of the web application, the script counts that if the number of the same IP connection exceeds 100 in three minutes, it is considered to be a DDOS attack. 
#The script will use iptables to block these IPs and prohibit the connection.
#Nong-v 2019-03-24
while :;do
	min=$(sed -n '$=' /var/log/httpd/access_log)
	sleep 180
	max=$(sed -n '$=' /var/log/httpd/access_log)
	time_sum=$[$max-$min]
	for i in `seq $(tail -$time_sum /var/log/httpd/access_log|awk '{print $1}'|sort|uniq|wc -l)`;do
		ip_sum=$(tail -$time_sum /var/log/httpd/access_log|awk '{print $1}'|sort|uniq -c|awk NR==$i'{print $1}')
		ip=$(tail -$time_sum /var/log/httpd/access_log|awk '{print $1}'|sort|uniq -c|awk NR==$i'{print $2}')
		if [ $ip_sum -ge 100 ];then
			iptables -A INPUT -s $ip -j DROP
		fi
	done
done
