#!/bin/bash
#    Encrypt-Decrypt.sh
#    A bash script for nautilus, thunar etc to encrypt and decrypt file with gpg (AES)
#
#    Date: 8/06/2017
#    Dependency: zenity, gpg
#    Version: 0.1
#    Copyright (C) 2017 - D4void - d4void@m4he.fr
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

algo="aes256"

case $LANG in
  fr*)
    encrypt="Chiffrer"
    decrypt="Déchiffrer"
    pass="Entrez une passphrase"
    pass2="Confirmez la passphrase"
    errpass="Passphrase non identique ou vide"
    cendok="Réussite du chiffrement"
    cendnok="Echec du chiffrement"
    dendok="Réussite du déchiffrement"
    dendnok="Echec du déchiffrement"
    ;;

  *)
    encrypt="Encrypt"
    decrypt="Decrypt"
    pass="Enter passphrase"
    pass2="Confirm passphrase"
    errpass="Passphrase not the same or empty"
    cendok="Encryption done"
    cendnok="Encryption failed"
    dendok="Decryption done"
    dendnok="Decryption failed"
    ;;
esac

IFS="
"

for arg
do
    ext=`echo "$arg" | grep [.]gpg$ 2>&1`

    set -o pipefail 1

    if [ "$ext" != "" ]; then

      pass_decrypt=`zenity --width=300 --entry --entry-text "$pass_decrypt" --hide-text --title "$pass" --text "$decrypt ${arg##*/} $pass_decrypt" "" 2>/dev/null`
      echo "$pass_decrypt" | gpg -o "${arg%.*}" --batch --passphrase-fd 0 -d "$arg" | zenity --progress --auto-close --pulsate --no-cancel
      if [ $? -ne 0 ]; then
          zenity --error --text "$dendnok"
      else
          rm -f "$arg"
          zenity --info --text "$dendok"
      fi
    else
      pass_encrypt=`zenity --width=300 --entry --hide-text --entry-text "$pass_encrypt" --title "$pass" --text "$encrypt ${arg##*/}" "" 2>/dev/null`
      if [ "$pass_encrypt" != "" ]; then
        pass_encrypt2=`zenity --width=300 --entry --hide-text --entry-text "$pass_encrypt2" --title "$pass2" --text "$encrypt ${arg##*/}" "" 2>/dev/null`
        if [ "$pass_encrypt2" != "" ] && [ "$pass_encrypt" == "$pass_encrypt2" ]; then
          echo "$pass_encrypt2" | gpg --batch --passphrase-fd 0 --cipher-algo $algo -c "$arg" | zenity --progress --auto-close --pulsate --no-cancel
          if [ $? -ne 0 ]; then
            zenity --error --text "$cendnok"
          else
            rm -f "$arg"
            zenity --info --text "$cendok"            
          fi
        else
          zenity --error --text "$errpass"
        fi
      fi
    fi
done

set +o pipefail
exit 0
