#!/bin/bash
for i in `awk '{print $1}' hosts`
do
    j=`awk -v I="$i" '{if(I==$1)print $2}' hosts`
    k=`awk -v I="$i" '{if(I==$1)print $3}' hosts`
    l=`awk -v I="$i" '{if(I==$1)print $4}' hosts`
    expect chg_passwd.exp $i $j $k $l
done

