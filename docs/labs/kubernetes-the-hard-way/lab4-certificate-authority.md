---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - lab exercise
---

# Lab 4: Provisioning a CA and Generating TLS Certificates

In this lab, you will provision a [PKI Infrastructure](https://en.wikipedia.org/wiki/Public_key_infrastructure) using OpenSSL to bootstrap a Certificate Authority and generate TLS certificates for the following components:

* kube-apiserver
* kube-controller-manager
* kube-scheduler
* kubelet
* kube-proxy

Run commands in this section from the `jumpbox`.

## Certificate Authority

In this section, you will provision a Certificate Authority that you will use to generate additional TLS certificates for the other Kubernetes components. Setting up CA and generating certificates with `openssl` can be time-consuming, especially when doing it for the first time. To streamline this lab,  an `openssl` configuration file, `ca.conf`, must be included, which defines all the details needed to generate certificates for each Kubernetes component.

Take a moment to review the `ca.conf` configuration file:

```bash
cat ca.conf
```

To complete this tutorial, you do not need to understand everything in the `ca.conf` file. Still, you should consider it a starting point for learning `openssl` and the configuration that goes into managing certificates at a high level.

Every certificate authority starts with a private key and root certificate. In this section, you will create a self-signed certificate authority, and while that is all you need for this tutorial, this is something you should not consider in a real-world production environment.

Generate the CA configuration file, certificate, and private key:

```bash
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
```

Results:

```txt
ca.crt ca.key
```

!!! Tip

    To view the details encoded in the generated certificate file (ca.crt), you can use this OpenSSL command `openssl x509 -in ca.crt -text -noout | less`.  

## Create Client and Server Certificates

In this section, you will generate client and server certificates for each Kubernetes component and a client certificate for the Kubernetes `admin` user.

Generate the certificates and private keys:

```bash
certs=(
  "admin" "node-0" "node-1"
  "kube-proxy" "kube-scheduler"
  "kube-controller-manager"
  "kube-api-server"
  "service-accounts"
)
```

```bash
for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "ca.conf" -section ${i} \
    -out "${i}.csr"
  
  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done
```

The above command results will generate a private key, certificate request, and signed SSL certificate for each Kubernetes component. You can list the generated files with the following command:

```bash
ls -1 *.crt *.key *.csr
```

## Distribute the Client and Server Certificates

In this section, you will copy the various certificates to every machine using a path where each Kubernetes component will search for its certificate pair. In a real-world environment, you would treat these certificates as a set of sensitive secrets because Kubernetes uses these components as credentials to authenticate to each other.

Copy the appropriate certificates and private keys to the `node-0` and `node-1` machines:

```bash
for host in node-0 node-1; do
  ssh root@$host mkdir /var/lib/kubelet/
  
  scp ca.crt root@$host:/var/lib/kubelet/
    
  scp $host.crt \
    root@$host:/var/lib/kubelet/kubelet.crt
    
  scp $host.key \
    root@$host:/var/lib/kubelet/kubelet.key
done
```

Copy the appropriate certificates and private keys to the `server` machine:

```bash
scp \
  ca.key ca.crt \
  kube-api-server.key kube-api-server.crt \
  service-accounts.key service-accounts.crt \
  root@server:~/
```

In the next lab, you will use the `kube-proxy`, `kube-controller-manager`, `kube-scheduler`, and `kubelet` client certificates to generate client authentication configuration files.

Next: [Generating Kubernetes Configuration Files for Authentication](lab5-kubernetes-configuration-files.md)
