# Encryption
Bash script using the hybrid(asymmetric symmetric) encryption approach for large files. This uses PEM public/private keys which can be converted from id_rsa

Put both decrypt.sh and encrypt.sh in your path
## Encrypt a file with someone's public key 
###__Usage__
```bash
encrypt.sh fileToEncrypt
encrypt.sh -in fileToEncrypt
encrypt.sh -in fileToEncrypt  -out toto.tar
encrypt.sh -in fileToEncrypt  -inkey id_rsa.pub.pem
```

## Decrypt a file with the private key
###__Usage__
```bash
decrypt.sh fileToDecrypt
decrypt.sh -in fileToDecrypt
decrypt.sh -in fileToDecrypt  -inkey ~/.ssh/id_rsa.pub.pem
```

Based on the following webpages
 * __http://www.czeskis.com/random/openssl-encrypt-file.html__
 * __http://bikulov.org/blog/2013/10/12/hybrid-symmetric-asymmetric-encryption-for-large-files/__
