#!/bin/bash
ipfs pubsub sub ssh | while read input ; do
  mapfile -t signers < <(cat ~/.ssh/allowed_signers | sed -e 's/ .*//g')
  for signer in "${signers[@]}"
  do
    message=$(echo "${input}" | sed -e 's/.*-----BEGIN MESSAGE-----;;;n;;;/-----BEGIN MESSAGE-----;;;n;;;/g' -e 's/-----END MESSAGE-----;;;n;;;.*/-----END MESSAGE-----;;;n;;;/g')
    signature=$(echo "${input}" | sed -e 's/.*-----BEGIN SSH SIGNATURE-----/-----BEGIN SSH SIGNATURE-----/g' -e 's/-----END SSH SIGNATURE-----.*/-----END SSH SIGNATURE-----/g')
    echo "${message}" | ssh-keygen -Y verify -f ~/.ssh/allowed_signers -I "${signer}" -n text -s <(echo "${signature}" | sed 's/;;;n;;;/\n/g' ) &>/dev/null
    if [ "$?" -eq 0 ] ; then
      mapfile -t lines < <(echo "${input}" | sed -e 's/.*-----BEGIN MESSAGE-----;;;n;;;//g' -e 's/-----END MESSAGE-----;;;n;;;.*//g' -e 's/;;;n;;;/\n/g')
      for line in "${lines[@]}" ; do
#        eval $line
        echo "$line"
      done
      exit 0
    fi
  done
done
