### List GPG Key
```shell script
gpg --list-secret-keys --keyid-format LONG
gpg --export-secret-keys YOUR_ID_HERE > private.key
```