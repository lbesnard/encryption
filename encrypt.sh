#!/bin/bash
usage=" $(basename "$0") [-h] [-in] \e[4mFileToEncrypt\e[24m [-out] \e[4mEncryptedFilenameOutput\e[24m   [-inkey] \e[4mPEM_privateKeyLocation\e[24m

 Encrypt a large file using assymetric symetrical encryption

 The 128 key files are generated on the fly to encrypt the file chosen by the
 user. Both 128 key files are then encrypted with the public pem key. see step
 0 of Ref1 (below)
 All the files are then tar-red

 Parameters
 -in  | --file-in     : file to encrypt
 -out | --file-out    : (optional) filename of tar containing encrytped keys and
                         main file
                         By default {file to encrypt}_encrypted.tar
 -inkey| --public-key:  (optional)location of the pem key to use.
                         By default  $HOME/.ssh/id_rsa.pub.pem

 Usage
 ./encrypt.sh -in fileToEncrypt
 ./encrypt.sh -in fileToEncrypt  -out toto.tar
 ./encrypt.sh -in fileToEncrypt  -inkey ~/.ssh/id_rsa.pub.pem

 References:
 Ref1 http://www.czeskis.com/random/openssl-encrypt-file.html
 Ref2 http://bikulov.org/blog/2013/10/12/hybrid-symmetric-asymmetric-encryption-for-large-files/

 Will generate an error if the key is not a public PEM key
"

# default public key location value
pubkey=$HOME/.ssh/id_rsa.pub.pem

#Handle
while :
do
    case "$1" in

        -in | --file-in)
                  shift
                  file="$1"
                  ;;

        -out | --file-out)
                  shift
                  fileout="$1"
                  ;;

        -inkey | --public-key)
                  shift
                  pubkey="$1"
                  ;;

        -h | --help)
                  echo -e "$usage"
                  exit
                  ;;
        -* | ?*)
                  echo "Error: Unknown option: $1" >&2
                  echo "Try 'encrypt --help' for more information."
                  exit 1
                  ;;

        *)        # No more options
                  break
                  ;;
    esac
    shift
done


if [ ! -f $pubkey ]; then
    printf '%s\n' 'Public key in pem format not found! Please create one\n' >&2
    exit 1
fi


if [ ! -f $file ]; then
    echo $file ": File to encrypt not found!"
    exit 1
fi


# output encrypted file default
if [  -z "$fileout" ]; then
   fileout=${file}_encrypted.tar;
fi

# check if TMPDIR env variables exists. Else create randomely generated tmp dir
TMPDIR=${TMPDIR:=`mktemp -d -t`}

# Generate a 256 bit random key
passfile=$TMPDIR/${file}_passfile
openssl rand 128 > ${passfile}1
openssl rand 128 > ${passfile}2
cat ${passfile}1 ${passfile}2  >>  ${passfile}


# Encrypt large file
openssl enc -aes-256-cbc -salt -in $file -out ${file}.ssl -pass file:${passfile}

# Encrypt both keys
openssl rsautl -encrypt -pubin -inkey ${pubkey}  -in ${passfile}1 -out ${passfile}1.ssl
openssl rsautl -encrypt -pubin -inkey ${pubkey}  -in ${passfile}2 -out ${passfile}2.ssl

# tar all keys and encrypted file into tar
# -C change directory, and basename get the actual name from the fullpath
tar czf $fileout  ${file}.ssl -C $TMPDIR $(basename ${passfile}1.ssl) $(basename ${passfile}2.ssl)

# remove temporary file
rm  ${passfile} ${passfile}1 ${passfile}2  ${passfile}1.ssl ${passfile}2.ssl ${file}.ssl

echo 'Encrypted file created ' `readlink -f $fileout`  >&1

exit 0
