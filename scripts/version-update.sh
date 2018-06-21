#!/bin/bash
cd /data/alanpeng/kubernetes-versions/scripts/
./get-k8s-version-list.sh
diff ./k8s-version-new.txt ./k8s-version.txt |grep v |awk '{print $2}' > ./k8s-version-diff.txt

if test -s ./k8s-version-diff.txt; then
  ./uploadfiles.sh
  cat ./k8s-version-diff.txt |mail -s 'New kubernetes release!' alan_peng@wise2c.com
fi
