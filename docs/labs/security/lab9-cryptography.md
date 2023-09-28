---
Title: Lab 9 - Cryptography
author: Wale Soyinka
contributors:
---


# Lab 9: Cryptography

## Objectives

After completing this lab, you will be able to:

- apply cryptographic concepts in securing data and communication

Estimated time to complete this lab: 120 minutes





>Three may keep a secret, if two of them are dead...
>
-- Benjamin Franklin






## Common Cryptography terms and definitions

### Cryptography

In general everyday usage, Cryptography is the act or art of writing in secret characters. In technical jargon it may be defined as the science of using mathematics to encrypt and decrypt data.

### Cryptanalysis

Cryptanalysis is the study of how to compromise (defeat) cryptographic mechanisms. It is the science of cracking code, decoding secrets, violating authentication schemes, and in general, breaking cryptographic protocols.

### Cryptology

Cryptology is the discipline of cryptography and cryptanalysis combined. Cryptology is the branch of mathematics that studies the mathematical foundations of cryptographic methods.

### Encryption

Encryption transforms data into a form that is close to impossible to read without the appropriate knowledge (e.g., a key). Its purpose is to ensure privacy by keeping information hidden from anyone for whom it is not intended.

### Decryption

Decryption is the reverse of encryption; it transforms encrypted data into an intelligible form.

### Cipher

A method of encryption and decryption is called a cipher.

Hash Functions (Digest algorithms)

Cryptographic hash functions are used in various contexts, for example to compute the message digest when making a digital signature. A hash function compresses the bits of a message to a fixed-size hash value to distribute the possible messages evenly among the possible hash values. A cryptographic hash function does this in a way that makes it extremely difficult to come up with a message that would hash to a particular hash value. Below are some examples of the best-known and most widely used hash functions. 

**a)** - **SHA-1 (Secure Hash Algorithm)** -This is a cryptographic hash algorithm published by the United States Government. It produces a 160 bit hash value from an arbitrary length string. It is considered to be very good.

**b)**- **MD5 (Message Digest Algorithm 5)** - is a cryptographic hash algorithm developed at RSA Laboratories. It can be used to hash an arbitrary length byte string into a 128 bit value.

### Algorithm

It describes a step-by-step problem-solving procedure, especially an established, recursive computational procedure for solving a problem in a finite number of steps. Technically, an algorithm must reach a result after a finite number of steps. The efficiency of an algorithm can be measured as the number of elementary steps it takes to solve the problem. There are two classes of key-based algorithms. They are:

**a) **-- **Symmetric Encryption Algorithms (secret-key)**

Symmetric algorithms use the same key for encryption and decryption (or the decryption key is easily derived from the encryption key). Secret key algorithms use the same key for both encryption and decryption (or one is easily derivable from the other). This is the more straightforward approach to data encryption, it is mathematically less complicated than public-key cryptography. Symmetric algorithms can be divided into stream ciphers and block ciphers. Stream ciphers can encrypt a single bit of plaintext at a time, whereas block ciphers take a number of bits (typically 64 bits in modern ciphers), and encrypt them as a single unit. Symmetric algorithms are much faster to execute on a computer than asymmetric ones.

Examples of symmetric algorithms are: AES, 3DES, Blowfish, CAST5, IDEA and Twofish.

**b) -- Asymmetric algorithms (Public-key algorithms)**

Asymmetric algorithms on the other hand use a different key for encryption and decryption, and the decryption key cannot be derived from the encryption key. Asymmetric ciphers permit the encryption key to be public, allowing anyone to encrypt with the key, whereas only the proper recipient (who knows the decryption key) can decrypt the message. The encryption key is also called the public key, and the decryption key is the private or secret key. 

RSA is probably the best-known asymmetric encryption algorithm.

### Digital Signature

A digital signature binds a document to the owner of a particular key.

The digital signature of a document is a piece of information based on both the document and the signer's private key. It is typically created through a hash function and a private signing function (encrypting with the signer's private key). A digital signature is a small amount of data created using some secret key, and there is a public key that can be used to verify that the signature was generated using the corresponding private key.

Several methods for making and verifying digital signatures are freely available but the most widely known algorithm is the RSA public-key algorithm.

### Cryptographic Protocols

Cryptography works on many levels. On one level you have algorithms, such as block ciphers and public key cryptosystems. Building upon these, you obtain protocols, and upon protocols, you find applications (or other protocols). Below is a list of typical everyday applications that use cryptographic protocols. These protocols are built on lower level cryptographic algorithms.

i.) Domain Name Server Security (DNSSEC)

This is a protocol for secure distributed name services. It is currently available as an Internet Draft.

ii.) Secure Socket Layer (SSL)

SSL is one of the two protocols used for secure WWW connections (the other is SHTTP). WWW security has become necessary as increasing amounts of sensitive information, such as credit card numbers, are transmitted over the Internet. 

iii.) Secure Hypertext Transfer Protocol (SHTTP)

This is another protocol for providing more security for WWW transactions.

iv) E-Mail security and related services

**GnuPG** - The GNU Privacy Guard - is compliant with the proposed OpenPGP Internet standard as described in RFC2440.

v) SSH2 Protocol

This protocol is versatile for the needs of the internet, and is currently used in the SSH2 software. The protocol is used to secure terminal sessions and TCP connections.

The following exercises examine two applications that use cryptographic protocols - GnuPG and OpenSSH.

## Exercise 1

### GnuPG

GnuPG (GNU Privacy Guard) is a set of programs for public key encryption and digital signatures. The tools can be used to encrypt data and to create digital signatures. It also includes an advanced key management facility. GnuPG uses public-key cryptography to enable users to communicate securely.

Perform the following exercises as a regular user. e.g. user ying

To create a new key pair

1. Log into the system as user “ying”

2. Make sure that the GnuPG package is installed on your system. Type:

```
[ying@serverXY ying]$ rpm -q gnupg

gnupg-*.*
```

If it isn’t, get the super-user to install it.

3. List and make a note of all the hidden directories in your home directory.

4. List the keys you currently have in your keyring. Type:

```
[ying@serverXY ying]$ gpg --list-keys
```

!!! NOTE

    You shouldn’t have any keys in your key-ring yet. But the above command will also help create a default environment to enable you create a new key-pair successfully the first time.

List the hidden directories in your home directory again. What is the name of the new directory added?

5. Use the gpg program to create your new key-pairs. Type:

```
[ying@serverXY ying\]$ gpg --gen-key

......................................

gpg: keyring \`/home/ying/.gnupg/secring.gpg' created

gpg: keyring \`/home/ying/.gnupg/pubring.gpg' created

Please select what kind of key you want:

 (1) DSA and ElGamal (default)

 (2) DSA (sign only)

 (5) RSA (sign only)

Your selection? 1
```

At the prompt for the type of key you want to create, accept the default, i.e.(DSA and ElGamal). Type 1

!!! WARNING

    Option (1) will create two key-pairs for you. The DSA key-pair will be the primary key pair - for making digital signatures and a subordinate ELGamel key pair for data encryption.

6. You will create an ELG-E key size of 1024. Accept the default again at the prompt below:

```
DSA key pair will have 1024 bits.

About to generate a new ELG-E key pair.

 minimum key size is 768 bits

 default key size is 1024 bits

 highest suggested key size is 2048 bits

What key size do you want? (1024) 1024
```

7. Create keys that will expire in a year. Type “1y” at the prompt below:

Please specify how long the key should be valid.

 0 = key does not expire

<n> = key expires in n days

<n>w  = key expires in n weeks

<n>m = key expires in n months

<n>y = key expires in n years

Key is valid for? (0) 1y

8. Type “y” to accept the expiry date shown at the prompt:

```
Is this correct (y/n)? y
```

9. Create a User-ID to identify your key with:

You need a User-ID to identify your key; the software constructs the user id

from Real Name, Comment and Email Address in this form:

"Firstname Lastname (any comment) &lt;yourname@serverXY&gt;"

Real name: Ying Yang\[ENTER\]

Comment : my test\[ENTER\]

Email address: ying@serverXY \[ENTER\]

At the confirmation prompt type “o” (Okay) to accept the correct values.

You selected this USER-ID:

"Ying Yang (my test) &lt;ying@serverXY&gt;"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O

10. Select a passphrase that you WILL NOT forget at the next prompt:

```
Enter passphrase: \*\*\*\*\*\*\*\*

Repeat passphrase: \*\*\*\*\*\*\*\*
```
## Exercise 2

### Key Administration

The gpg program is also used in key administration.

Listing your keys

1. While still logged into the system as the user ying. Display the keys in your key-ring. Type:

```
[ying@serverXY ying\]$  gpg --list-keys

gpg: WARNING: using insecure memory!

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]
```

2. To suppress the somewhat annoying “warning” about “insecure memory” add the following option to your personal gpg configuration file. Type:

```
[ying@serverXY ying\]$ echo "no-secmem-warning" &gt;&gt; ~/.gnupg/gpg.conf
```
3. Run the command to list your keys again. to make sure your change is in effect.

4. List your keys along with their signatures. Type:

```
[ying@serverXY ying\]$ gpg --list-sigs

/home/ying/.gnupg/pubring.gpg
```

5. List only your secret keys. Type:

```
[ying@serverXY ying\]$ gpg --list-secret-keys

/home/ying/.gnupg/secring.gpg

-----------------------------

sec 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

ssb 1024g/1EDB00AC 2003-10-16
```

6. Display the key fingerprints. Type:

```
[ying@serverXY ying\]$ ***gpg --fingerprint***

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

 Key fingerprint = D61E 1538 EA12 9049 4ED3 5590 3BC4 A3C1 1D12 E484

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

<span id="anchor-2"></span>Revocation certificates

Revocation certificates are used to revoke keys in case someone gets knowledge of your secret key or in case you forget your passphrase. They are also useful for other various functions.
```

To create a revocation certificate

1. While still logged in as the user ying. Create a revocation certificate. It will be displayed on your standard output. Type:

```
[ying@serverXY ying\]$ gpg --gen-revoke ying@serverXY
```

Follow the prompts and enter your passphrase when prompted to do so.

2. Now create a revocation certificate that will be stored in an ASCII format in a file called -

 “revoke.asc”. Type:

```
[ying@serverXY ying\]$ gpg --output revoke.asc --gen-revoke ying@serverXY
```

3. You should store the revocation certificate in a safe place and even make a hard printed copy.

Exporting Public Keys

The whole point of all this encrypting, signing and decrypting business is because people wish to communicate with one another - but they also wish to do so in as secure a manner as possible.

With that said - the perhaps not to so obvious has to be stated:

You must exchange public keys to communicate with other people using a public-key-based cryptosystem..

Or at least make your public key available in any publicly accessible place (Bill-boards, web pages, key servers, radio, T.V, SPAMMING via e-mail ..etc)

To export your public keys

1. Export your public key in binary format to a file called “ying-pub.gpg”. Type:

```
[ying@serverXY ying\]$ ***gpg --output ying-pub.gpg --export &lt;your\_key’s\_user\_ID&gt;***
```

!!! NOTE

    Please replace &lt;your\_key’s\_user\_ID&gt; with any string that correctly identifies your keys. On our sample system this value can be any one of the following:

    ying@serverXY, ying, yang

    OR

    The actual key ID - 1D12E484

2. Export your public key to a file called “ying-pub.asc”. But this time generate it in

 ASCII-armored format. Type:

```
[ying@serverXY ying\]$***gpg --output ying-pub.asc --armor --export ying@serverXY ***
```

3. Use the cat command to view the binary version of ying’s public key (ying-pub.gpg)

4. To reset your terminal type: `reset`

5. Use the cat command to view the ASCII version of ying’s public key (ying-pub.asc)

6. You will observe that the ASCII version is more suited for posting on web-pages or spamming etc.

## Exercise 3

### Digital signatures

Creating and verifying signatures uses the public/private key pair, which differs from encryption and decryption. A signature is created using the private key of the signer. The signature can be verified using the corresponding public key.

To digitally sign a file

1. Create a file named “secret-file.txt” with the text “Hello All” in it. Type:

```
[ying@serverXY ying\]$ echo "Hello All" &gt; secret1.txt
```

2. Use cat to view the contents of the file. Use the file command to see the kind of file it is.

3. Now sign the file with your digital signature. Type:

```
[ying@serverXY ying\]$ gpg -s secret1.txt
```
Input your passphrase when prompted.

The above command will create another file “secret1.txt.gpg” which is compressed and has a signature attached to it. Run the “file” command on the file to check this. View the file with cat

4. Check the signature on the signed “secret1.txt.gpg” file. Type:

```
[ying@serverXY ying\]$ gpg --verify secret1.txt.gpg

gpg: Signature made Thu 16 Oct 2003 07:29:37 AM PDT using DSA key ID 1D12E484

gpg: Good signature from "Ying Yang (my test) &lt;ying@serverXY&gt;"
```

5. Create another file secret2.txt with the text “ Hello All” in it.

6. Sign the secret2.txt file, but let the file be ASCII armored this time. Type:

```
[ying@serverXY ying\]$ gpg -sa secret2.txt
```

An ASCII armored file called “secret2.txt.asc” will be created in your pwd.

7. Use the cat command to view the contents of the ASCII armored file created for you above.

8. Create another file called “secret3.txt” with the text “hello dude” in it. Type:

```
[ying@serverXY ying echo "hello dude" &gt; secret3.txt
```

9. Append your signature to the body of the file you created above. Type:
```
[ying@serverXY ying\]$ gpg --clearsign secret3.txt
```
This will create an uncompressed file (secret3.txt.asc) that is wrapped in your ASCII-armored signature.

Write down the command to verify the signature of the file that was created for you.

10. Open up the file to view its contents with any pager. Can you read the text you entered into the file?

MAKE SURE THAT YOUR PARTNER HAS PERFORMED THE WHOLE OF

“EXERCISES -1, 2, 3” ABOVE BEFORE YOU CONTINUE TO “EXERCISE 4” BELOW

IF YOU DON’T HAVE A PARTNER. LOG OFF USER YING’s ACCOUNT AND LOG INTO THE SYSTEM AS THE USER “me”.

THEN REPEAT THE WHOLE OF “EXERCISES -1,2,3” AS THE USER “me”.

YOU MAY THEN PERFORM EXERCISE 4 BELOW. REPLACE ALL REFERENCES TO THE USER YING AT “serverPR” WITH - USER “me” AT serverXY (i.e. your localhost)

YOU CAN USE EITHER - USER “me@serverXY” or USER “ying@serverPR”

AS YOUR PARTNER IN THE NEXT EXERCISE.

## Exercise 4

 In this exercise, you will use the so-called “Web of Trust” to communicate with another user.

Importing public keys

1. Log into the system as user ying./

2. Make your ASCII-armored public-key file (ying-pub.asc) available to your partner ( use

 either - me@serverXY or ying@serverPR)

!!! NOTE:

There are several ways of doing this e.g. e-mail, copying and pasting, scp, ftp, Saving on a diskette etc.

Select the most efficient method for yourself.

3. Ask your partner to make their public key file available to you. 

4. Assuming your partner’s public key is store in a file called “ me-pub.asc” in your pwd;

 Import the key into your key-ring. Type:

```
[ying@serverXY ying\]$ gpg --import me-pub.asc

gpg: key 1D0D7654: public key "Me Mao (my test) &lt;me@serverXY&gt;" imported

gpg: Total number processed: 1

gpg: imported: 1
```

5. Now list the keys in your key-ring. Type:

```
[ying@serverXY ying\]$ gpg --list-keys

/home/ying/.gnupg/pubring.gpg

-----------------------------

pub 1024D/1D12E484 2003-10-16 Ying Yang (my test) &lt;ying@serverXY&gt;

sub 1024g/1EDB00AC 2003-10-16 \[expires: 2004-10-15\]

pub 1024D/1D0D7654 2003-10-16 Me Mao (my test) &lt;me@serverXY&gt;

sub 1024g/FD20DBF1 2003-10-16 \[expires: 2004-10-15\]
```

6. In particular list the key that is associated with the user-ID me@serverXY. Type:

```
[ying@serverXY ying\]$ gpg --list-keys me@serverXY
```

7. View the fingerprint of the key for me@serverXY. Type:

```
[ying@serverXY ying\]$ gpg --fingerprint me@serverXY
```


<span id="anchor-4"></span>Encrypting and decrypting files

The procedure for encrypting and decrypting files or documents is straight forward.

If you want to encrypt a message to the user ying, you will encrypt it using user ying’s public key.

Upon receipt, ying will need to decrypt the message with ying’s private key.

ONLY ying can decrypt the message or file that was encrypted with ying’s public key

To encrypt a file

1. While logged into the system as the user ying, create a file called encrypt-sec.txt. Type:

```
[ying@serverXY ying\]$ echo "hello" &gt; encrypt-sec.txt
```

Make sure you can read the contents of the file using cat.

2. Encrypt the file encrypt-sec.txt, such that only the user “me” can view the file. i.e. you will encrypt

 it using me@serverXY’s public key ( which you now have in your key-ring). Type:

```
[ying@serverXY ying\]$ gpg --encrypt --recipient me@serverXY encrypt-sec.txt
```

 The above command will create an encrypted file called “encrypt-sec.txt.gpg” in your pwd.

 To decrypt a file

1. The file you encrypted above was meant for me@serverXY.

 Try to decrypt the file. Type:
```
\[ying@serverXY ying\]$ gpg --decrypt encrypt-sec.txt.gpg

gpg: encrypted with 1024-bit ELG-E key, ID FD20DBF1, created 2003-10-16

 "Me Mao (my test) &lt;me@serverXY&gt;"

gpg: decryption failed: secret key not available
```

2. Have we learnt any valuable lesson here?

3. Make the encrypted file you created available to the correct owner and have them run the above

 command to decrypt the file. Were they more successful in decrypting the file.

!!! NOTE

    Be very careful when decrypting binary files ( e.g. programs), because after successfully decrypting a file gpg will attempt to send the contents of the file to standard output.

Make a habit of using the command below instead when decrypting files:

```
[ying@serverXY ying\]$ gpg --output encrypt-sec --decrypt encrypt-sec.txt.gpg
```

This forces sending the output to a file called “encrypt-sec”.

Which can then be viewed (or run) using any program that is suited for the file (or content) type.

!!! TIPS

1. Most of the commands and options used with the gpg program also have short forms that results in less

 typing for the user at the command line. e.g.

```
gpg --encrypt --recipient me@serverXY encrypt-sec.txt
```
The short form of the above command is:
```
gpg -e -r me@serverXY encrypt-sec.txt
```
2. To encrypt the string "hello" and mails it as an ASCII armored message to the user with the mail address

 ying@serverXY; Use the command below:
```
echo "hello" | gpg -ea -r ying@serverXY | mail ying@serverXY
```

3. To encrypt the file "your\_file" with the public key of "me@serverXY" and write it to "your\_file.gpg"

 after ***signing*** it with your user id (using your digital signature); Use the command below:

```
gpg -se -r me@serverXY your\_file
```
4. There is a publicly available key server at wwwkeys.pgp.net. You can use gpg to upload your key there with:

gpg --send-keys &lt;your\_real\_email\_address&gt; --keyserver wwwkeys.pgp.net

OpenSSH (www.openssh.org)

OpenSSH is OpenBSD's SSH (Secure SHell) protocol implementation.

It is a FREE version of the SSH protocol suite of network connectivity tools. OpenSSH encrypts all traffic (including passwords) to effectively eliminate eavesdropping, connection hijacking, and other network-level attacks. Additionally, OpenSSH provides a plethora of secure tunneling capabilities, as well as a variety of authentication methods.

It helps to provide secure encrypted communications between two untrusted hosts over an insecure network (such as the internet).

It includes both the server-side components and the client-side suite of programs

**sshd**

The server side includes the secure shell daemon (sshd). sshd is the daemon that listens for connections from clients.

It forks a new daemon for each incoming connection. The forked daemons handle key exchange, encryption,

authentication, command execution, and data exchange. According to sshd’s man page, sshd works as follows:

For SSH protocol version 2:

Each host has a host-specific key (RSA or DSA) used to identify the host. When the daemon starts, it does not generate a server key (As is the case in SSH protocol version 1). Forward security is provided through a Diffie-Hellman key agreement. This key agreement results in a shared session key.

The rest of the session is encrypted using a symmetric cipher, currently 128 bit AES, Blowfish, 3DES, CAST128, Arcfour, 192 bit AES, or 256 bit AES. The client selects the encryption algorithm to use from those offered by the server. Additionally, session integrity is provided through a cryptographic message authentication code (hmac-sha1 or hmac-md5).

Protocol version 2 provides a public key-based user (PubkeyAuthentication) or client host (HostbasedAuthentication) authentication method, conventional password authentication, and challenge response-based methods.

The SSH2 protocol implemented in OpenSSH is standardized by the “IETF secsh” working group

ssh

The client's suite of programs include “ssh”. This is a program used for logging into remote systems and can also be used for executing commands on remote systems.

## Exercise 5

### sshd

```
Usage: sshd [options\

Options:

 -f file Configuration file (default /etc/ssh/sshd\_config)

 -d Debugging mode (multiple -d means more debugging)

 -i Started from inetd

 -D Do not fork into daemon mode

 -t Only test configuration file and keys

 -q Quiet (no logging)

 -p port Listen on the specified port (default: 22)

 -k seconds Regenerate server key every this many seconds (default: 3600)

 -g seconds Grace period for authentication (default: 600)

 -b bits Size of server RSA key (default: 768 bits)

 -h file File from which to read host key (default: /etc/ssh/ssh\_host\_key)

 -u len Maximum hostname length for utmp recording

 -4 Use IPv4 only

 -6 Use IPv6 only

 -o option Process the option as if it was read from a configuration file.
```
 

Most Linux systems out of the box already have the OpenSSH server configured and running with some defaults. The configuration file for sshd usually resides under - /etc/ssh/ - and is called sshd\_config.

sshd\_config

1. Open up the ssh server’s config file with any pager and study it. Type:
```
[root@serverXY root\]\# less /etc/ssh/sshd_config
```

!!! NOTE:

sshd_config is a rather odd configuration file.

You will notice that unlike other Linux config files - comments (\#) in the sshd\_config file denotes the defaults values of the options. i.e. comments represents already compiled-in defaults.

2. Consult the man page for sshd\_config and explain what the options below do?

AuthorizedKeysFile

Ciphers

HostKey

Port

Protocol

X11Forwarding

HostKey

3. Change your pwd to the /etc/ssh/ directory.

4. List all the files in the directory below:

Creating host keys

Your ssh server already has hosts keys that it uses. Those keys were generated when your system was first installed. In this exercise you will learn how to create host type keys for your server. But you wont actually use the keys.

To generate host keys for your server

1. Create a new directory under your pwd. Call it spare-keys. cd to the new directory. Type:

```
[root@serverXY ssh\]# mkdir spare-keys && cd spare-keys
```
2. Use the ssh-keygen program to create a host key with the following characteristics:

a. key type should be “rsa”

b. Key should have no comments

c. Private key file should be named - ssh\_host\_rsa\_key

d. The key should not use any passphrase

 Type:

```
[root@serverXY spare-keys]# ssh-keygen -q -t rsa -f ssh\_host\_rsa\_key -C '' -N ''
```

3. View the fingerprint of the key you created above. Type:

```
[root@serverXY spare-keys]# ssh-keygen -l -f ssh_host_rsa_key
```

4. Write down the command to create a ***dsa*** type key called “ssh\_host\_dsa\_key” with no comments,

 and no passphrase?

## Exercise 6

### ssh

```
Usage:- ssh \[-l login\_name\] hostname | user@hostname \[command\]

 ssh \[-afgknqstvxACNTX1246\] \[-b bind\_address\] \[-c cipher\_spec\]

 \[-e escape\_char\] \[-i identity\_file\] \[-l login\_name\] \[-m mac\_spec\]

 \[-o option\] \[-p port\] \[-F configfile\] \[-L port:host:hostport\]

\[-R port:host:hostport\] \[-D port\] hostname | user@hostname \[command\]
```

To use ssh

1. Log into serverXY as the user me.

2. Use ssh to connect to serverPR. Type:

```
[me@serverXY me\]$ ***ssh serverPR***
```

 Type in me’s password when prompted. If you get any warning messages type “yes” to continue.

3. After logging in, create a directory called - myexport and create an empty file. Type:

```
[me@serverPR me\]$ mkdir ~/myexport && touch myexport
```

Make a note of the random file that was created for you, under ~/myexport ?

4. Log off serverPR. Type:

```
[me@serverPR me]$ exit
```

You will be returned to your local shell at serverXY.

5. Use ssh to remotely execute the “ls” command to view the list of files in ying’s home directory at

 serverPR. Type:

```
[me@serverXY me]$ssh ying@serverPR “ls /home/ying”
```
Type in ying’s password when prompted. If you get any warning messages type “yes” to continue.

6. While still logged in as me on serverXY, log into serverPR as the user ying. Type:

```
[me@serverXY me\]$ ***ssh -l ying serverPR ***
```

**Type in ying’s password when prompted.**

7. Type “exit” to log off serverPR and return to serverXY.

<span id="anchor-7"></span>scp

scp - secure copy (remote file copy program)

scp copies files between hosts on a network. It uses ssh for data transfer, and uses the same authentication and provides the same security as ssh.

```
usage: scp [-346ABCOpqRrTv] [-c cipher] [-D sftp_server_path] [-F ssh_config]
           [-i identity_file] [-J destination] [-l limit]
           [-o ssh_option] [-P port] [-S program] source ... target
 ```

To use scp

1. Make sure you are still logged in as the user me on serverXY.

2. Create a directory under your home directory called myimport and cd to the directory.

3. Copy over all the files under the “/home/me/myexport/” directory on serverPR. Type:

```
[me@serverXY myimports\]$ scp serverPR:/home/me/myexport  .
```
4. List the contents of your pwd ?

 Was that totally cool or what ?

5. What is the command to copy over all the under “/home/me/.gnugp/” on serverPR ?

6. Now copy over all the files under ying’s home directory on serverPR. Type:

```
[me@serverXY myimports\]$ scp -r ying@serverPR:/home/ying/*  .
```

## Exercise 7

### Creating User Public and Private keys for SSH

Each user who wants to use SSH with RSA or DSA authentication needs a set of public and private keys. The ssh-keygen program can be used to create these keys ( just as it was used earlier when you created spare keys for your system)

The only “advised” difference when creating user keys is to also create a passphrase.

The passphrase is a password that the is used to encrypt the private key before it is stored on the file system.

The public is store in a file with the same file name as the private key but with the extension “.pub” appended to it. There is no way to recover a lost passphrase. A new key must be generated if the passphrase is lost or forgotten. 

To create ying’s authentication keys

1. Log into your local machine as the user ying.

2. Run the “ssh-keygen” program to create a “***dsa***” type key with the default length. Type:

```
[ying@serverXY ying]$ ssh-keygen -t dsa

Generating public/private dsa key pair.

Press \[ENTER\] to accept the default file location.

Enter file in which to save the key (/home/ying/.ssh/id\_dsa): \[ENTER\]

Enter a very good passphrase when prompted - i.e. one that is difficult to guess.

Created directory '/home/ying/.ssh'.

Enter passphrase (empty for no passphrase): ********

Enter same passphrase again: *******

Your identification has been saved in /home/ying/.ssh/id\_dsa.

Your public key has been saved in /home/ying/.ssh/id\_dsa.pub.

The key fingerprint is:

61:68:aa:c2:0c:af:9b:49:4a:11:b8:aa:b5:84:18:10 ying@serverXY.example.org
```


3. cd to your “**~/.ssh/**” directory. List the files in the directory?

4. What is the “ssh-keygen” command to view the fingerprint of your keys?

5. Use the cat command to view the contents of your public-key file (i.e. “**~/.ssh/id\_rsa.pub**”).

## Exercise 8

### Authenticating via Public-Key

Thus far you have been using a password based authentication scheme to log into user accounts at serverPR.

This means that, you had to have known the corresponding account’s password on the remote side to have been able to log in successfully.

In this exercise you will configure public-key authentication between your user account on serverXY and the ying’s user account at serverPR.

To configure public-key authentication

1. Log into your local system as the user ying.

2. cd to your “~/.ssh” directory.

3. Type in the horrible looking command below:
```
[ying@serverXY .ssh\]$ cat id\_dsa.pub | ssh ying@serverPR \

 '(cd ~/.ssh && cat - &gt;&gt; authorized\_keys && chmod 600 authorized\_keys)'
```

 The above command reads:

 a. cat the contents of your dsa public-key file, but send the out to the pipe ( | ) instead of the usual standard out.

 b. run the command “***cd ~/.ssh && cat - &gt;&gt; authorized\_keys && chmod 600 authorized\_keys”***

 as the user ying on serverPR.

 c. The whole point of the command is simply to copy and append the contents of your public-key

 file to the “/home/ying/.ssh/authorized\_keys” on serverPR and give it the correct permissions.

 If you know of any other manual way to achieve the same result, please do so.

4. After you have added your public-key to the authorized\_keys file on the remote system. Attempt to

 login to serverPR as ying via ssh. Type:

```
[ying@serverXY .ssh]$ ssh serverPR

Enter passphrase for key '/home/ying/.ssh/id\_dsa': ********
```

Note very carefully that, you are being prompted for your passphrase this time instead of the

password. Enter the passphrase you created earlier when you created your keys.

5. After successfully logging into serverPR; Log back out.

## Exercise 9

### ssh-agent

According to the man page - ssh-agent is a program to hold private keys used for public key authentication (RSA, DSA). The idea is that ssh-agent is started in the beginning of an X-session or a login session, and all other windows or programs are started as clients to the ssh-agent program. Through use of environment variables the agent can be located and automatically used for authentication when logging into other machines using ssh.

```
usage: ssh-agent [-c | -s] [-Dd] [-a bind_address] [-E fingerprint_hash]
                 [-P allowed_providers] [-t life]
       ssh-agent [-a bind_address] [-E fingerprint_hash] [-P allowed_providers]
                 [-t life] command [arg ...]
       ssh-agent [-c | -s] -k
```

In this exercise you will learn how to configure the agent such that you wont have to type in your passphrase every time you want to connect to another system using public-key authentication.

1. Make sure you are logged into your local system as the user ying.

2. Type in the command below:

```
[ying@serverXY .ssh\]$ eval `ssh-agent`

Agent pid 5623
```

Take note of the PID of the agent:

3. Use the `ssh-add` program to add your keys to the agent you launched above. Type:

```
[ying@serverXY .ssh\]$ ***ssh-add***

 Enter your passphrase when prompted.

Enter passphrase for /home/ying/.ssh/id\_dsa:

Identity added: /home/ying/.ssh/id\_dsa (/home/ying/.ssh/id\_dsa)
```


4. Now connect to serverPR as the user ying. You WILL NOT be prompted for a password or passphrase (i.e if everything has been done correctly). Type:

```
[ying@serverXY .ssh\]$ ssh serverPR
```

5. Enjoy.
