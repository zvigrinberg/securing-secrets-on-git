# Securing secrets on git repositories

## Goal - To Demonstrate how to share sensitive data on git repositories securely.

### Procedure - How to encrypt and decrypt using sops and GnuPG in our team

#### One Time Setup before encrypting/decrypting
1. First download GnuPG and SOPS utils for managing keys and encryption/decryption capabilities:
```shell

[zgrinber@zgrinber securing-secrets-on-git]$ sudo yum install sops
```
```shell

[zgrinber@zgrinber securing-secrets-on-git]$ sudo yum install gpg
```
3. Connect ot our Tel-Aviv OCP cluster 
4. Now run the script `download_keys.sh` resides in this repo, with the namespace and secretname parameters you were given
   in order to download our group' pair of public and private keys to current directory
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ ./download_keys.sh <namespace> <secretname>
```
5.Make sure that 2 new keys were created:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ ls -la *.gpg
-rw-rw-r--. 1 zgrinber zgrinber 3518 Apr  6 23:33 private.gpg
-rw-rw-r--. 1 zgrinber zgrinber 1753 Apr  6 23:33 public.gpg
```
6. Import the public key to GPG utility:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ gpg --import public.gpg
```
7. Import the private key to GPG utility:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ gpg --import private.gpg
```
8. make sure that keys imported to GnuPG
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ gpg --list-keys
/home/zgrinber/.gnupg/pubring.kbx
---------------------------------
pub   rsa2048 2022-04-06 [SC] [expires: 2024-04-05]
      650C42E2EEFF28EFFCEC654E49B14A9331479A7C
uid           [ultimate] Duz Redhat <duz@redhat.com>
sub   rsa2048 2022-04-06 [E] [expires: 2024-04-05]
```
**Note: The long number that consist of a mixture of letters and digits is the fingerprint that identify the key pair of our public & private keys.**

#### Encrypting/Decrypting:

1. For encrypting all fields in-place(overriding plain-text file with encrypted file) in `file.yaml`:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ sops --encrypt --in-place --pgp `gpg --fingerprint "duz@redhat.com" | grep pub -A 1 | grep -v pub | sed s/\ //g` file.yaml
```
or just pass directly the fingerprint instead of fetch it with a subcommand:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ sops --encrypt --in-place --pgp 650C42E2EEFF28EFFCEC654E49B14A9331479A7C file.yaml
```
or use environment variable $SOPS_PGP_FP to hold the FP before invoking sops encryption:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ export SOPS_PGP_FP=650C42E2EEFF28EFFCEC654E49B14A9331479A7C
[zgrinber@zgrinber securing-secrets-on-git]$ sops --encrypt --in-place file.yaml
```
or invoke the last command from a directory containing the .sops.yaml file here(which contains this fingerprint)

2.In order to encrypt only part of the file, can supply another flag to the command to encrypt only fields the follow some regex pattern, for example:
```shell
[zgrinber@zgrinber securing-secrets-on-git]$ sops --encrypt --in-place --encrypted-regex 'password|pin|user|secret' --pgp 650C42E2EEFF28EFFCEC654E49B14A9331479A7C file.yaml
```

3.In order to decrypt, just do the following
```shell
sops -d encrypted-file.yaml
```
This will print the decrypted yaml to standard output, if needed to be save to file , can redirect to a file:
```shell
sops -d encrypted-file.yaml > ./decrypted-file.yaml
```
