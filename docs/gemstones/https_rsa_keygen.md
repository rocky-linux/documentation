---
title: https - RSA Key Generation
author: Steven Spencer
update: 26-Jan-2022
---

# https - RSA Key Generation

This script has been used by me many times. No matter how often you use the openssl command structure, sometimes you have to refer back to the procedure. This script allows you to automate key generation for a web site using RSA. Note that this script is hard coded with a 2048-bit key length. For those of you who feel strongly that the key length minimum should be 4096 bits, simply change that portion of the script. Just know that you need to weigh the memory and speed that a site needs to load on a device, against the security of the longer key length.

## Script

Name this script anything you like, example: `keygen.sh`, make the script executable (`chmod +x scriptname`) and place it in a directory that is in your path, example: /usr/local/sbin

```bash
#!/bin/bash
if [ $1 ]
then
      echo "generating 2048 bit key - you'll need to enter a pass phrase and verify it"
      openssl genrsa -des3 -out $1.key.pass 2048
      echo "now we will create a pass-phrase less key for actual use, but you will need to enter your pass phrase a third time"
      openssl rsa -in $1.key.pass -out $1.key
      echo "next, we will generate the csr"
      openssl req -new -key $1.key -out $1.csr
      #cleanup
      rm -f $1.key.pass
else
      echo "requires keyname parameter"
      exit
fi
```

!!! Note

    You will enter the pass phrase three times in succession.

## Brief Description

* This bash script requires a parameter to be entered ($1) which is the name of the site without any www, etc. For example, "mywidget".
* The script creates the default key with a password and 2048-bit length (this can be edited, as noted above to a longer 4096 bit length)
* The password is then immediately removed from the key, the reason is that web server restarts would require that the key password be entered each time, and on reboot, which can be problematic in practice.
* Next the script creates the CSR (Certificate Signing Request), which can then be used to purchase an SSL certificate from a provider.
* Finally, the cleanup step removes the previously created key with the password attached.
* Entering the script name without the parameter generates the error: "requires keyname parameter".
* The positional parameter variable, i.e., $n, is used here. Where $0 represents the command itself and $1 to $9 represent the first to ninth parameters. When the number is greater than 10, you need to use braces, such as ${10}.
