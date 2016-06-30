#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

for i in seq 1 $(grep federation.num_clusters .config | sed -e 's/^federation\.num_clusters=//g'); do
  CONFIG_="cluster$i." .tmp/conf Kconfig
done