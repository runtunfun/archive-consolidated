#!/bin/bash


for SERVER in `grep "Host " ~/.ssh/config.d/* | grep -v ds | cut -d " " -f 2 | sort -u`                                                                             ─╯
do
ssh USER@${SERVER} hostname -f > 20220817a_${SERVER}_dpkg-l.csv
ssh USER@${SERVER} uname -s >> 20220817a_${SERVER}_dpkg-l.csv
ssh USER@${SERVER} dpkg --list | awk '/^ii/ {print $2}' | grep -v ^lib | sort -u >> 20220817a_${SERVER}_dpkg-l.csv
done
