#!/bin/bash

echo "Automated script for downloading and preparing GO, BAZO Keypairgen, miner and client"
echo "Setup GO - Started"
sudo snap install --classic go
echo "GO Version:"
go version
echo "GO ENV:"
go env
echo "Setup GO - Finished"
echo " "

echo "Updating GCC - Started"
sudo apt-get update
sudo apt install gcc
echo "Updating GCC - Finished"
echo " "

echo "Clear GO cache - Started"
cd /home/ubuntu/.cache/
sudo rm -R go-build/
echo "Clear GO cache - Finished"
echo " "

echo "Set GOPATH - Started"
echo "export PATH=$PATH:/usr/local/go/bin" >> .profile
echo "export GOPATH=$HOME/go;" >> .profile
echo "export PATH=$PATH:$GOPATH/bin;" >> .profile
source .profile
echo "GOPATH: " $GOPATH
echo "PATH: " $PATH
echo "Set GOPATH - Finished"
echo " "

echo "Setup BAZO-Keypairgen - Started"
echo "  Downloading BAZO-Keypairgen from Github"
go get github.com/bazo-blockchain/bazo-keypairgen
cd
cd /home/ubuntu/go/src/github.com/bazo-blockchain/bazo-keypairgen
go build
echo "  Create validator.txt & multisig.txt"
./bazo-keypairgen validator.txt
./bazo-keypairgen multisig.txt
echo "Setup BAZO-Keypairgen - Finished"
echo " "

echo "Setup BAZO-Miner - Startet."
echo "  Downloading BAZO-Miner from Github"
go get github.com/bazo-blockchain/bazo-miner
cd
cd /home/ubuntu/go/src/github.com/bazo-blockchain/bazo-keypairgen
echo "  Copy vaildator.txt & multisig.txt into miner folder"
cp validator.txt /home/ubuntu/go/src/github.com/bazo-blockchain/bazo-miner/validator.txt
cp multisig.txt /home/ubuntu/go/src/github.com/bazo-blockchain/bazo-miner/multisig.txt
echo "  Validator.txt & multisig.txt  copied"
cd
echo "  Replace INITROOTKEY1 & INITROOTKEY2 in configs.go"
validator_file="/home/ubuntu/go/src/github.com/bazo-blockchain/bazo-miner/validator.txt"
first_key=$(head -n1 "$validator_file" | tr -d '\n')
echo $first_key
second_key=$(head -n2 "$validator_file" | tail -n1 | tr -d '\n')
echo $second_key
configs_file="/home/ubuntu/go/src/github.com/bazo-blockchain/bazo-miner/storage/configs.go"
sed -ie "s/INITROOTPUBKEY1 = .*/INITROOTPUBKEY1 = \"$first_key\"/" "$configs_file"
sed -ie "s/INITROOTPUBKEY2 = .*/INITROOTPUBKEY2 = \"$second_key\"/" "$configs_file"
echo "  Replacement done"
cd /home/ubuntu/go/src/github.com/bazo-blockchain/bazo-miner
go build
echo "Setup BAZO-Miner - Finished"
echo " "

echo "Setup BAZO-Client - Started"
echo "  Downloading BAZO-Client from Github"
cd 
go get github.com/bazo-blockchain/bazo-client
cd /home/ubuntu/go/src/github.com/bazo-blockchain/bazo-client
go build
cd 
echo "Setup BAZO-Client - Finished"
echo " "

echo "Enable Colorful Prompt"
sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc
source .bashrc
echo "Colorful Prompt Enabled
