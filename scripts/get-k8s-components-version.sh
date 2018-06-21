#!/bin/bash

#Get etcd version
etcdversion=`curl -s -L https://github.com/kubernetes/kubernetes/raw/$1/cluster/images/etcd/Makefile |grep -v "ROLLBACK_REGISTRY_TAG?=" |grep "REGISTRY_TAG?=" |awk -F '=' '{print $2}'`
echo gcr.io/google_containers/etcd-amd64:$etcdversion > ./k8s-components-version.txt

#Get pause version
pversion=`curl -s -L https://raw.githubusercontent.com/kubernetes/kubernetes/$1/build/pause/Makefile |grep "TAG =" |awk '{print $3}'`
echo gcr.io/google_containers/pause-amd64:$pversion >> ./k8s-components-version.txt

#Get kubernetes version
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -V -r | head -n 1)" != "$1"; }

if version_gt $1 v1.9.6; then
  echo k8s.gcr.io/kube-apiserver-amd64:$1 >> ./k8s-components-version.txt
  echo k8s.gcr.io/kube-controller-manager-amd64:$1 >> ./k8s-components-version.txt
  echo k8s.gcr.io/kube-scheduler:$1 >> ./k8s-components-version.txt
  echo k8s.gcr.io/kube-proxy-amd64:$1 >> ./k8s-components-version.txt
else
  echo gcr.io/google_containers/kube-apiserver-amd64:$1 >> ./k8s-components-version.txt
  echo gcr.io/google_containers/kube-controller-manager-amd64:$1 >> ./k8s-components-version.txt
  echo gcr.io/google_containers/kube-scheduler:$1 >> ./k8s-components-version.txt
  echo gcr.io/google_containers/kube-proxy-amd64:$1 >> ./k8s-components-version.txt
fi

#Get kube-dns version
if version_lt $1 v1.6; then
  kversion=`curl -s -L https://github.com/kubernetes/kubernetes/raw/$1/cluster/addons/dns/skydns-rc.yaml.base |grep image |awk '{print $2$3}'`
else
  if version_lt $1 v1.9; then
    kversion=`curl -s -L https://github.com/kubernetes/kubernetes/raw/$1/cluster/addons/dns/kubedns-controller.yaml.base |grep image |awk '{print $2$3}'`
  else
    kversion=`curl -s -L https://github.com/kubernetes/kubernetes/raw/$1/cluster/addons/dns/kube-dns.yaml.base |grep image |awk '{print $2$3}'`
  fi
fi

if [ -n "$kversion" ]; then
  echo $kversion | tr " " "\n" >> ./k8s-components-version.txt
fi

#Get dashboard version
curl -s -L https://github.com/kubernetes/kubernetes/raw/$1/cluster/addons/dashboard/dashboard-controller.yaml |grep image |awk '{print $2$3}' >> ./k8s-components-version.txt

#Get flannel version
fversion=`curl -s 'https://api.github.com/repos/coreos/flannel/tags?page=1&per_page=100' |grep name |grep -v '-' |awk -F '"' '{print $4}' |awk 'NR==1{print}'`
echo quay.io/coreos/flannel:${fversion}-amd64 >> ./k8s-components-version.txt

#Get coredns version
if version_lt $1 v1.9; then
  :
else
  curl -s -L https://github.com/kubernetes/kubernetes/raw/$1/cluster/addons/dns/coredns.yaml.base |grep -v imagePullPolicy |grep image |awk '{print $2$3}' >> ./k8s-components-version.txt
fi

cat ./k8s-components-version.txt
