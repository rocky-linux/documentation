---
title: Generating SSL Keys
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5
tags:
  - security
  - ssl
  - openssl
---
  
# Generating SSL/TLS keys

## Prerequisites

* A workstation and a server running Rocky Linux 
* _OpenSSL_ installed on the machine that you are going to be generating the private key and CSR (Certificate Signing Request), and on the server where you will eventually be installing your key and certificates
* Able to run commands comfortably from the command-line
* Helpful: knowledge of SSL/TLS and OpenSSL commands


## Introduction

Nearly every web site today _should_ be running with an SSL/TLS (secure socket layer) certificate. This procedure will guide you through generating the private key for your web site and then generating the CSR (certificate signing request) that you will use to purchase your certificate.

## Generate the private key

For the uninitiated, SSL/TLS private keys can have different sizes, measured in bits, determining how hard they are to crack.

As of 2021, a website's recommended private key size is still 2048 bits. You can go higher, but doubling the key size from 2048 bits to 4096 bits is only about 16% more secure, takes more space to store the key, and causes higher CPU loads when processing the key.

This slows down your web site performance without gaining any significant security. Stick with the 2048 key size and always keep tabs on what is currently recommend
To start with, ensure the installation of OpenSSL on your workstation and server:

`dnf install openssl`

If it is not installed, your system will install it and any needed dependencies.

The example domain is "example.com." Remember that you will need to purchase and register your domain beforehand. You can purchase domains through several "Registrars".

If you are not running your own DNS (Domain Name System), you can often use the same providers for DNS hosting. DNS translates your named domain, to numbers (IP addresses, either IPv4 or IPv6) that the Internet can understand. These IP addresses will be where the web site is actually hosted.

Generate the key using `openssl`:

`openssl genrsa -des3 -out example.com.key.pass 2048`

Note that you named the key, with a *.pass* extension. That is because when you run this command, it requests that you enter a passphrase. Enter a simplistic passphrase that you can remember as you are going to be removing this shortly:

```
Enter pass phrase for example.com.key.pass:
Verifying - Enter pass phrase for example.com.key.pass:
```

Next, remove that passphrase. This is because if you do not remove it, you will need to enter that passphrase each time your website restarts and loads up your key.

You might not even be around to enter it, or worse, might not have a console available. Remove it now to avoid all of that:

`openssl rsa -in example.com.key.pass -out example.com.key`

This will request that passphrase once again to remove the passphrase from the key:

`Enter pass phrase for example.com.key.pass:`

Your password is now removed from the key now that you have entered the passphrase a third time, and saved as *example.com.key*

## Generate the CSR

Next, you need to generate the CSR (certificate signing request) that you will use to purchase your certificate.

Prompting for several pieces of information occurs during the generation of the CSR. These are the X.509 attributes of the certificate.

One of the prompts will be for "Common Name (e.g., YOUR domain name)". This field must have the fully qualified domain name of the server that the SSL/TLS is protecting. If the website to be protected will be https://www.example.com, then enter www.example.com at this prompt:

`openssl req -new -key example.com.key -out example.com.csr`

This opens up a dialog:

`Country Name (2 letter code) [XX]:` enter the two character country code where your site resides, for example "US"

`State or Province Name (full name) []:` enter the full official name of your state or province, for example "Nebraska"

`Locality Name (eg, city) [Default City]:` enter the full city name, for example "Omaha"

`Organization Name (eg, company) [Default Company Ltd]:` If you want, you can enter an organization that this domain is a part of, or just hit <kbd>ENTER</kbd> to skip.

`Organizational Unit Name (eg, section) []:` This would describe the division of the organization that your domain falls under. Again, you can just hit <kbd>ENTER</kbd> to skip.

`Common Name (eg, your name or your server's hostname) []:` Here, you have to enter your site hostname, example "www.example.com"

`Email Address []:` This field is optional, you can decide to fill it out or just hit <kbd>ENTER</kbd> to skip.

Next, the procedure prompts you to enter extra attributes. Skipping these is possible by hitting <kbd>ENTER</kbd>:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Generating of your CSR is complete.

## Purchasing the certificate

Each certificate vendor will have basically the same procedure. You purchase the SSL/TLS and term (1 or 2 years, etc.) and then you submit your CSR. To do this, you will need to use the `more` command, and then copy the contents of your CSR file.

`more example.com.csr`

Which will show you something like this:

```
-----BEGIN CERTIFICATE REQUEST-----
MIICrTCCAZUCAQAwaDELMAkGA1UEBhMCVVMxETAPBgNVBAgMCE5lYnJhc2thMQ4w
DAYDVQQHDAVPbWFoYTEcMBoGA1UECgwTRGVmYXVsdCBDb21wYW55IEx0ZDEYMBYG
A1UEAwwPd3d3Lm91cndpa2kuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAzwN02erkv9JDhpR8NsJ9eNSm/bLW/jNsZxlxOS3BSOOfQDdUkX0rAt4G
nFyBAHRAyxyRvxag13O1rVdKtxUv96E+v76KaEBtXTIZOEZgV1visZoih6U44xGr
wcrNnotMB5F/T92zYsK2+GG8F1p9zA8UxO5VrKRL7RL3DtcUwJ8GSbuudAnBhueT
nLlPk2LB6g6jCaYbSF7RcK9OL304varo6Uk0zSFprrg/Cze8lxNAxbFzfhOBIsTo
PafcA1E8f6y522L9Vaen21XsHyUuZBpooopNqXsG62dcpLy7sOXeBnta4LbHsTLb
hOmLrK8RummygUB8NKErpXz3RCEn6wIDAQABoAAwDQYJKoZIhvcNAQELBQADggEB
ABMLz/omVg8BbbKYNZRevsSZ80leyV8TXpmP+KaSAWhMcGm/bzx8aVAyqOMLR+rC
V7B68BqOdBtkj9g3u8IerKNRwv00pu2O/LOsOznphFrRQUaarQwAvKQKaNEG/UPL
gArmKdlDilXBcUFaC2WxBWgxXI6tsE40v4y1zJNZSWsCbjZj4Xj41SB7FemB4SAR
RhuaGAOwZnzJBjX60OVzDCZHsfokNobHiAZhRWldVNct0jfFmoRXb4EvWVcbLHnS
E5feDUgu+YQ6ThliTrj2VJRLOAv0Qsum5Yl1uF+FZF9x6/nU/SurUhoSYHQ6Co93
HFOltYOnfvz6tOEP39T/wMo=
-----END CERTIFICATE REQUEST-----
```

You want to copy everything including the "BEGIN CERTIFICATE REQUEST" and "END CERTIFICATE REQUEST" lines. Then paste these into the CSR field on the web site where you are purchasing the certificate.

Before issuing your certificate, You may have to perform other verification steps depending on domain ownership, the registrar you are using, etc. When issued, it will include an intermediate certificate from the provider, which you will also use in the configuration.

## Conclusion

Generating all of the bits and pieces for purchasing a web site certificate is not difficult using this procedure.

