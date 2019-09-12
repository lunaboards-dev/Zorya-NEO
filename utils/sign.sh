#!/bin/bash
for f in src/modules/*; do
	if [[ -f "$f/init.lua" ]]; then
		echo "Siging $f."
		printf "init.lua\x00" > ".tmp_1"
		openssl dgst -sha256 -sign zbsign.pem "$f/init.lua" > ".tmp_2"
		printf "manifest.ini\x00" > ".tmp_3"
		openssl dgst -sha256 -sign zbsign.pem "$f/manifest.ini" > ".tmp_4"
		if [[ -f "$f/lang.xml" ]]; then
			printf "lang.xml\x00" > ".tmp_5"
			openssl dgst -sha256 -sign zbsign.pem "$f/lang.xml" > ".tmp_6"
		fi
		cat .tmp_* > "$f/sig.bin"
		rm .tmp_*
	fi
done