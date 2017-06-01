#!/bin/bash

read -p "请输入需要批量修改密码的IP个数:" RANGE
read -p "请输入新密码长度:" NUM
rm -rf newpasswd && touch newpasswd
for ((i=1;i<$RANGE+1;i++));
do
mkpasswd -l $NUM >> ./newpasswd 2>&1
done
paste oldpasswd newpasswd > hosts 2>&1

#1
#for i in {1..20};do
#	mkpasswd -l $NUM
#done
#2
#for i in `seq 20`;do
#	mkpasswd -l $NUM
#done
