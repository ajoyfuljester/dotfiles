#!/usr/bin/env bash

output="$XDG_CONFIG_DIRS/hypr/vars.conf"

variables=()

echo > ${output}

for var in "${variables[@]}"; do
	printf "\$env_${var} = " >> ${output}
	printf "${!var}\n" >> ${output}
done




