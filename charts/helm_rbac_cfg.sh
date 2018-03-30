#!/bin/bash
# master keys
openssl genrsa -out ./ca.key.pem 4096
openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem
# tiller
openssl genrsa -out ./tiller.key.pem 4096
# helm
openssl genrsa -out ./helm.key.pem 4096
# create certificates tiller
openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem
# create certificates helm
openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem
# sign tiller csr with cert
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem
# sign helm csr with cert
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem
# start cluster
minikube start --kubernetes-version=v1.9.1 --memory=4096 --bootstrapper=kubeadm \ 
  --extra-config=kubelet.authentication-token-webhook=true \ 
  --extra-config=kubelet.authorization-mode=Webhook \ 
  --extra-config=scheduler.address=0.0.0.0 \ 
  --extra-config=controller-manager.address=0.0.0.0
# create rbac clusterrole and clusterrolebinding for tiller sa
kubectl create -f tiller-rbac.yaml
# create rbac clusterrole and clusterrolebinding for minikube addons
kubectl create clusterrolebinding addon-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:default
# install tiller with tls
helm init --service-account tiller \
  --tiller-namespace tiller-server \ 
  --tiller-tls \ 
  --tiller-tls-cert ./tiller.cert.pem \ 
  --tiller-tls-key ./tiller.key.pem \ 
  --tiller-tls-verify --tls-ca-cert \ 
  ca.cert.pem
# cp keys for helm client
cp ca.cert.pem $(helm home)/ca.pem
cp helm.cert.pem $(helm home)/cert.pem
cp helm.key.pem $(helm home)/key.pem
# setup client to use tls
helm ls --tiller-namespace tiller-server --tls
# moving forward, append --tiller-namespace tiller-server --tls 
# to all helm commands in order to communicate with tiller via tls
