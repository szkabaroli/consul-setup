#!/usr/bin/env bash
#source helper.sh

helm repo add hashicorp https://helm.releases.hashicorp.com && helm repo update

# install consul in the first dc
kubectl config use-context consul-dc-1
helm install --values etc/dc1-values.yaml consul hashicorp/consul --create-namespace --namespace consul --version "0.43.0" --atomic 

kubectl get pods --namespace consul
kubectl apply -f etc/proxy-defaults.yaml --namespace consul

# Export secrets
kubectl get secret consul-federation --namespace consul -o yaml > consul-federation-secret.yaml

# Deploy Consul datacenter dc2
kubectl config use-context consul-dc-2

# Create the namespace consul in dc2
kubectl create namespace consul

# Create the federation secret in dc2.
kubectl apply -f consul-federation-secret.yaml --namespace consul

helm install --values etc/dc2-values.yaml consul hashicorp/consul --namespace consul --version "0.43.0" --atomic

kubectl get pods --namespace consul
kubectl apply -f etc/proxy-defaults.yaml --namespace consul

kubectl exec statefulset/consul-server --namespace consul -- consul members -wan