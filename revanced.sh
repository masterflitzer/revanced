#!/usr/bin/env bash

main () {
    CWD=$(dirname $(realpath $0))
    CONFIG="$CWD/revanced.json"
    ROOT="false"

    RV_CLI="revanced/revanced-cli"
    RV_INTEGRATIONS="revanced/revanced-integrations"
    RV_PATCHES="revanced/revanced-patches"

    APP_PFLOTSH_ECMWF="com.garzotto.pflotsh.ecmwf_a"
    APP_REDDIT="com.reddit.frontpage"
    APP_TIKTOK="com.ss.android.ugc.trill"
    APP_TWITTER="com.twitter.android"
    APP_WARNWETTER="de.dwd.warnapp"
    APP_YOUTUBE="com.google.android.youtube"
    APP_YOUTUBE_MUSIC="com.google.android.apps.youtube.music"
    APPS=($APP_PFLOTSH_ECMWF $APP_REDDIT $APP_TIKTOK $APP_TWITTER $APP_WARNWETTER $APP_YOUTUBE $APP_YOUTUBE_MUSIC)

    test "-r" = $1 && ROOT="true"

    if ! (command -v java && command -v jq) &> /dev/null
    then
        cat << 'EOF'

You need to install Java 17+ (e.g. OpenJDK) and jq
You can install it with: sudo apt update && sudo apt install openjdk-17-jre jq

EOF
        return 1
    fi

    if ! test -f "$CONFIG"
    then
        cat << EOF

Couldn't find the config file at $CONFIG

EOF
        return 1
    fi

    cat << EOF

Following apps can be patched:
      App                  Package
    * Pflotsh ECMWF        $APP_PFLOTSH_ECMWF.apk
    * Reddit               $APP_REDDIT.apk
    * TikTok               $APP_TIKTOK.apk
    * Twitter              $APP_TWITTER.apk
    * WarnWetter           $APP_WARNWETTER.apk
    * YouTube (*)          $APP_YOUTUBE.apk
    * YouTube Music (*)    $APP_YOUTUBE_MUSIC.apk

With (*) marked apps need microG to work on non-rooted devices
The microg patch will automatically be ignored if you specify the '-r' option for a root build

Here you can get the list of available patches: https://github.com/revanced/revanced-patches

In order to patch an app you need to put the apk (not bundled) in the same directory as this script is and name it as shown above

You can download apk files from the following sources:
    * Pflotsh ECMWF:    **not available on apkmirror**
    * Reddit:           https://apkmirror.com/apk/redditinc/reddit/
    * TikTok:           https://apkmirror.com/apk/tiktok-pte-ltd/tik-tok/
    * Twitter:          https://apkmirror.com/apk/twitter-inc/twitter/
    * WarnWetter:       https://apkmirror.com/apk/deutscher-wetterdienst/warnwetter/
    * YouTube:          https://apkmirror.com/apk/google-inc/youtube/
    * YouTube Music:    https://apkmirror.com/apk/google-inc/youtube-music/
    * Vanced microG:    https://apkmirror.com/apk/team-vanced/microg-youtube-vanced/

EOF

    revanced_download $RV_CLI jar
    revanced_download $RV_INTEGRATIONS apk
    revanced_download $RV_PATCHES jar

    printf "\nDiscovering apps\n\n"

    for i in ${APPS[@]}
    do
        FILE="$i.apk"
        if test -f "$CWD/$FILE"
        then
            echo "Found $FILE"
            revanced_execute $i
        else
            echo "Didn't find $FILE"
        fi
    done

    printf "\nDone\n\n"
}

revanced_download () {
    GH_REPO=$1
    FILE_EXT=$2
    DL_B64=$(curl -Ls "https://api.github.com/repos/$GH_REPO/releases/latest" | jq -r '.assets[].browser_download_url | @base64')
    for i in ${DL_B64[@]}
    do
        DL=$(base64 -d <<< $i)
        if [[ $DL =~ ^.*\.$FILE_EXT$ ]]
        then
            FILE_NAME=$(awk -F / '{ print $NF }' <<< $GH_REPO)
            FILE="$FILE_NAME.$FILE_EXT"
            echo "Downloading $FILE"
            curl -Lso "$CWD/$FILE" $DL
        fi
    done
}

revanced_execute () {
    APP=$1
    PATCHES_CLI=""
    revanced_patches $APP
    printf "\nPatching $APP\n\n"
    test -d revanced && mkdir revanced
    (
        set -x
        java -jar revanced-cli.jar \
            -a $APP.apk \
            -b revanced-patches.jar \
            -c \
            -m revanced-integrations.apk \
            -o revanced/revanced-$APP.apk \
            --exclusive \
            --experimental \
            $PATCHES_CLI
    )
    echo ""
}

revanced_patches () {
    APP=$1
    printf "\nParsing config for $APP\n"
    PATCHES=($(jq -r ".\"$APP\"[]" $CONFIG | tr '\n' ' '))

    for i in ${PATCHES[@]}
    do
        if (test "microg-support" = $i || test "music-microg-support" = $i) && test "true" = $ROOT
        then
            echo "Skipping microG patch"
            continue
        fi

        PATCHES_CLI="$PATCHES_CLI -i $i"
    done
}

main $@
