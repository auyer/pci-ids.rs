#!/bin/bash

# attempt 
urls=(
    "https://pci-ids.ucw.cz/pci.ids"
    "https://github.com/pciutils/pciids/raw/refs/heads/master/pci.ids"
)

for url in "${urls[@]}"; do
    curl -fsSL "$url" -o src/pci.ids && exit 0
done

echo "All downloads failed" >&2
exit 1
