#hostname#
echo "#####################hostname#########################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
echo "$(hostname)" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#manager-status#
echo "#####################manger-status#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
docker node ls >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
a=$(docker node ls | grep -v Ready | grep -v STATUS | wc -l)
if [ $a -eq 0 ];then
echo "caas-cluster is health" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
else
echo "caas-cluster is unhealth" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
fi

#docker-node-ls-time
echo "#####################docker-node-ls-time#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
(time docker node ls | grep real) 2>> /var/log/cass-check-time
dtime=$(cat /var/log/cass-check-time | grep real | awk '{ print $2}' | awk -F 'm' '{ print $1}' | grep -v grep)
if [ "$dtime" -gt 2 ];then
echo "caas-node-ls-time is unhealth" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
else
echo "caas-node-ls-time is health" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
fi
mv /var/log/cass-check-time /tmp

#space
echo "#####################host-space#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
space=$(df -h | awk '{ print $5}' | grep -v Use | sed 's/%//')
for s in $space
do
if [ "$s" -gt 80 ];then
echo "host-space is warning" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
fi
done

#cpu
echo "#####################cpu-sort#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
ps auxw --sort=%cpu | grep -v USER | sort -r -n -k 3 | head | awk '{ print $3"%",$11}' >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
C=$(ps auxw --sort=%cpu | grep -v USER | sort -r -n -k 3 | head -n 1 | awk ' { print $3=int($3)}')
if [ "$C" -gt 70 ];then
echo "cpu is unhealth,please check" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
fi

#mem
echo "#####################mem-sort#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
ps aux --sort -rss | head -n 10 | awk 'NR >1 {print $6=int($6/1024)"MB", $11}' >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#net
echo "#####################net-link#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
netstat -ant | awk '/ESTABLISHED|LISTEN|CLOSE_WAIT|TIME_WAIT/{print $6}' | sort | uniq -c | sort -n >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#file
echo "#####################file#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
for x in `ps -ef | awk '{print $2}'`; do echo `ls /proc/$x/fd 2>/dev/null | wc -l` $x `cat /proc/$x/cmdline 2>/dev/null`; done | sort -n -r | head -n 10 >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#syslog
echo "#####################syslog#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
cat /var/log/messages | grep vote | tail -n 1 >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
#cat /var/log/messages | grep error >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
cat /var/log/messages | grep "oom-killer" | tail -n 1 >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#uptime
echo "#####################uptime#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
uptime >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#memused
echo "#####################memused#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
free -h >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)

#vip
echo "#####################keepalived-vip#####################" >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
docker ps -a | grep keepalived >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
ip a | grep bond >> /var/log/caas-check/caas-check-$(date +%Y%m%d%H%M)
