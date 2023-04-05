#!/bin/bash
mapfile -t ids < <(find ~/.ssh/ -iname "*.pub" -exec sh -c 'echo $(cat {} | sed -e "s/.* //g" ),{} | sed -e "s/.pub//g"' \;)
select id in "${ids[@]}" ; do
  input=""
  echo "Enter text, press Ctrl-D to end:"
  while read -r line ; do
    input="$input$line;;;n;;;"
  done
  input="-----BEGIN MESSAGE-----;;;n;;;${input}-----END MESSAGE-----;;;n;;;"
  signature=$(echo "${input}" | ssh-keygen -Y sign -f "${id#*,}" -n text 2>/dev/null | sed ':a;N;$!ba;s/\n/;;;n;;;/g')
  output=$(echo -n "${input}"; echo "${signature}" )
  echo "${output}" | ipfs pubsub pub ssh -
#  echo "${input}" ; echo "${signature}"
  break
done
