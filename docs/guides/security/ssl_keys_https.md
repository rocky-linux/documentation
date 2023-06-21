---
title: Generating SSL Keys
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5
tags:
  - security
  - ssl
  - openssl
---
  
# Generating SSL Keys

## Prerequisites

* A workstation and a server running Rocky Linux (OK, Linux, but really, you want Rocky Linux, right?)
* _OpenSSL_ installed on the machine that you are going to be generating the private key and CSR, as well as on the server where you will eventually be installing your key and certificates
* Able to run commands comfortably from the command-line
* Helpful: knowledge of SSL and OpenSSL commands


## Introduction

Nearly every web site today _should_ be running with an SSL (secure socket layer) certificate. This procedure will guide you through generating the private key for your web site and then from this, generating the CSR (certificate signing request) that you will use to purchase your new certificate.

## Generate The Private Key

For the uninitiated, SSL private keys can have different sizes, measured in bits, which basically determines how hard they are to crack.

As of 2021, the recommended private key size for a web site is still 2048 bits. You can go higher, but doubling the key size from 2048 bits to 4096 bits is only about 16% more secure, takes more space to store the key, and causes higher CPU loads when the key is processed.

This slows down your web site performance without gaining any significant security. Stick with the 2048 key size for now and always keep tabs on what is currently recommended.

To start with, let's make sure that OpenSSL is installed on both your workstation and server:

`dnf install openssl`

If it is not installed, your system will install it and any needed dependencies.

Our example domain is example.com. Keep in mind that you would need to purchase and register your domain ahead of time. You can purchase domains through a number of "Registrars".

If you are not running your own DNS (Domain Name System), you can often use the same providers for DNS hosting. DNS translates your named domain, to numbers (IP addresses, either IPv4 or IPv6) that the Internet can understand. These IP addresses will be where the web site is actually hosted.

Let's generate the key using openssl:

`openssl genrsa -des3 -out example.com.key.pass 2048`

Note that we named the key, with a .pass extension. That's because as soon as we execute this command, it requests that you enter a passphrase. Enter a simple passphrase that you can remember as we are going to be removing this shortly:

```
Enter pass phrase for example.com.key.pass:
Verifying - Enter pass phrase for example.com.key.pass:
```

Next, let's remove that passphrase. The reason for this is that if you don't remove it, each time your web server restarts and loads up your key, you will need to enter that passphrase.

You might not even be around to enter it, or worse, might not have a console at the ready to enter it. Remove it now to avoid all of that:

`openssl rsa -in example.com.key.pass -out example.com.key`

This will request that passphrase once again to remove the passphrase from the key:

`Enter pass phrase for example.com.key.pass:`

Now that you have entered the passphrase a third time, it has been removed from the key file and saved as example.com.key

## Generate the CSR

Next, we need to generate the CSR (certificate signing request) that we will use to purchase our certificate.

During the generation of the CSR, you will be prompted for several pieces of information. These are the X.509 attributes of the certificate.

One of the prompts will be for "Common Name (e.g., YOUR name)". It is important that this field be filled in with the fully qualified domain name of the server to be protected by SSL. If the website to be protected will be https://www.example.com, then enter www.example.com at this prompt:

`openssl req -new -key example.com.key -out example.com.csr`

This opens up a dialog:

`Country Name (2 letter code) [XX]:` enter the two character country code where your site resides, example "US"

`State or Province Name (full name) []:` enter the full official name of your state or province, example "Nebraska"

`Locality Name (eg, city) [Default City]:` enter the full city name, example "Omaha"

`Organization Name (eg, company) [Default Company Ltd]:` If you want, you can enter an organization that this domain is a part of, or just hit 'Enter' to skip.

`Organizational Unit Name (eg, section) []:` This would describe the division of the organization that your domain falls under. Again, you can just hit 'Enter' to skip.

`Common Name (eg, your name or your server's hostname) []:` Here, we have to enter our site hostname, example "www.example.com"

`Email Address []:` This field is optional, you can decide to fill it out or just hit 'Enter' to skip.

Next, you will be asked to enter extra attributes which can be skipped by hitting 'Enter' through both:

```
Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Now you should have generated your CSR.

## Purchasing The Certificate

Each certificate vendor will have basically the same procedure. You purchase the SSL and term (1 or 2 years, etc.) and then you submit your CSR. To do this, you will need to use the `more` command, and then copy the contents of your CSR file.

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

You may have to perform other verification steps, depending on ownership of the domain, the registrar you are using, etc., before your certificate is issued. When it is issued, it should be issued along with an intermediate certificate from the provider, which you will use in the configuration as well.

## Conclusion

Generating all of the bits and pieces for the purchase of a web site certificate is not terribly difficult and can be performed by the systems administrator or web site administrator using the above procedure.
