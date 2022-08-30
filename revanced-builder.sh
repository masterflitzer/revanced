#!/usr/bin/env bash

if test ! -d "$HOME/storage/shared"
then
    termux-setup-storage
fi

pkg upgrade -y
pkg install unzip openjdk-17 nodejs -y

DOWNLOAD="https://github.com/reisxd/revanced-builder/archive/refs/heads/main.zip"
BUILDER="revanced-builder-main"
STORAGE="$HOME/storage/shared"

cd $HOME/
curl -Lso $BUILDER.zip $DOWNLOAD
rm -fr $BUILDER/
unzip $BUILDER.zip
rm $BUILDER.zip

if test ! -d "$BUILDER"
then
    printf "\nbuilder dir doesn't exist, the extraction probably failed\n\n"
    exit 1
fi

cd $BUILDER/
mkdir revanced
cp $STORAGE/revanced/revanced.keystore revanced/revanced.keystore
cp $STORAGE/revanced/includedPatchesList.json includedPatchesList.json
npm i
node .
cp revanced/revanced.keystore $STORAGE/revanced/revanced.keystore
cp includedPatchesList.json $STORAGE/revanced/includedPatchesList.json
mv -f $STORAGE/microg.apk $STORAGE/revanced/
mv -f $STORAGE/ReVanced-*.apk $STORAGE/revanced/
