#! /bin/bash

mkdir -p "_decks/$2/img/"

filename="_decks/$2/img/$3.png"

if [ ! -f "$filename" ]; then   
  curl 'https://limitlesstcg.com/tools/pnggen' \
    -H 'authority: limitlesstcg.com' \
    -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
    -H 'accept-language: en-GB,en-US;q=0.9,en;q=0.8' \
    -H 'cache-control: max-age=0' \
    -H 'content-type: application/x-www-form-urlencoded' \
    -H 'origin: https://limitlesstcg.com' \
    -H 'referer: https://limitlesstcg.com/tools/imggen' \
    -H 'sec-ch-ua: "Chromium";v="118", "Google Chrome";v="118", "Not=A?Brand";v="99"' \
    -H 'upgrade-insecure-requests: 1' \
    -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36' \
    --data-raw "$1" \
    --compressed \
    -o "$filename"

else
   echo "File $filename already exists" >&2 
fi
