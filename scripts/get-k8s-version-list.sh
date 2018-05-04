#!/bin/bash
curl -s "https://api.github.com/repos/kubernetes/kubernetes/tags?page=1&per_page=100" |grep name |grep -v '-' |grep -v v0. |awk -F '"' '{print $4}' > ./k8s-version-new.txt
i=2
while (($i != 0)); do
  kversion=`curl -s "https://api.github.com/repos/kubernetes/kubernetes/tags?page=${i}&per_page=100" |grep name |grep -v '-' |grep -v v0. |awk -F '"' '{print $4}'`
  if [ -n "$kversion" ]; then
    curl -s "https://api.github.com/repos/kubernetes/kubernetes/tags?page=${i}&per_page=100" |grep name |grep -v '-' |grep -v v0. |awk -F '"' '{print $4}' >> ./k8s-version-new.txt
    i=$[$i+1]
    sleep 10
  else
    i=0
  fi
done
