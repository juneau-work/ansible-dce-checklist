#!/bin/bash

ansible-playbook /root/fetch1.yml

logfile=$(cd /tmp/ && ls -lrt | tail -n 1  | awk '{print $9}')

cd /tmp/ && echo "e-mail from img01!" | mail -s "CaaS管理平台" -a ${logfile}  xxx@example.com

find /tmp/ -mtime +1 -name "caas*" -exec rm -rf {} \;
