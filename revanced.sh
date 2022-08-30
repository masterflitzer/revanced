#!/usr/bin/env bash

main () {
    CWD=$(dirname $(realpath $0))
    CONFIG="$CWD/revanced.json"
    ROOT="false"

    RV_CLI="revanced/revanced-cli"
    RV_INTEGRATIONS="revanced/revanced-integrations"
    RV_PATCHES="revanced/revanced-patches"

    APP_REDDIT="reddit"
    APP_TIKTOK="tiktok"
    APP_TWITTER="twitter"
    APP_YOUTUBE="youtube"
    APP_YOUTUBE_MUSIC="youtube-music"

    if test "-r" = $1
    then
        ROOT="true"
    fi

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
      App                  File                 Package
    * Reddit               $APP_REDDIT.apk           com.reddit.frontpage
    * TikTok               $APP_TIKTOK.apk           com.ss.android.ugc.trill
    * Twitter              $APP_TWITTER.apk          com.twitter.android
    * YouTube (*)          $APP_YOUTUBE.apk          com.google.android.youtube
    * YouTube Music (*)    $APP_YOUTUBE_MUSIC.apk    com.google.android.apps.youtube.music

With (*) marked apps need microG to work on non-rooted devices
The microg patch will automatically be ignored if you specify the '-r' option for a root build

Here you can get the list of available patches: https://github.com/revanced/revanced-patches

In order to patch an app you need to put the apk (not bundled) in the same directory as this script is and name it as shown above

You can download apk files from the following sources:
    * Reddit:           https://apkmirror.com/apk/redditinc/reddit/
    * TikTok:           https://apkmirror.com/apk/tiktok-pte-ltd/tik-tok/
    * Twitter:          https://apkmirror.com/apk/twitter-inc/twitter/
    * YouTube:          https://apkmirror.com/apk/google-inc/youtube/
    * YouTube Music:    https://apkmirror.com/apk/google-inc/youtube-music/
    * Vanced microG:    https://apkmirror.com/apk/team-vanced/microg-youtube-vanced/

EOF

    revanced_download $RV_CLI jar
    revanced_download $RV_INTEGRATIONS apk
    revanced_download $RV_PATCHES jar

    if test -f "$CWD/$APP_REDDIT.apk"
    then
        revanced_execute $APP_REDDIT
    fi

    if test -f "$CWD/$APP_TIKTOK.apk"
    then
        revanced_execute $APP_TIKTOK
    fi

    if test -f "$CWD/$APP_TWITTER.apk"
    then
        revanced_execute $APP_TWITTER
    fi

    if test -f "$CWD/$APP_YOUTUBE.apk"
    then
        revanced_execute $APP_YOUTUBE
    fi

    if test -f "$CWD/$APP_YOUTUBE_MUSIC.apk"
    then
        revanced_execute $APP_YOUTUBE_MUSIC
    fi
}

revanced_download () {
    GH_REPO=$1
    FILE_EXT=$2
    for i in $(curl -Ls "https://api.github.com/repos/$GH_REPO/releases/latest" | jq -r '.assets[].browser_download_url | @base64')
    do
        DL=$(base64 -d <<< $i)
        if [[ $DL =~ ^.*\.$FILE_EXT$ ]]
        then
            FILE=$(awk -F / '{ print $NF }' <<< $GH_REPO)
            curl -Lso "$CWD/$FILE.$FILE_EXT" $DL
        fi
    done
}

revanced_execute () {
    APP=$1
    PATCHES_CLI=""
    revanced_patches $APP
    java -jar revanced-cli.jar \
         -a $APP.apk \
         -b revanced-patches.jar \
         -c \
         -m revanced-integrations.apk \
         -o $APP-revanced.apk \
         --exclusive \
         --experimental \
         $PATCHES_CLI
}

revanced_patches () {
    APP=$1
    PATCHES=()
    case $APP in
        $APP_REDDIT)
            PATCHES=($(jq -r ".$APP_REDDIT[]" $CONFIG | tr '\n' ' '))
            ;;
        $APP_TIKTOK)
            PATCHES=($(jq -r ".$APP_TIKTOK[]" $CONFIG | tr '\n' ' '))
            ;;
        $APP_TWITTER)
            PATCHES=($(jq -r ".$APP_TWITTER[]" $CONFIG | tr '\n' ' '))
            ;;
        $APP_YOUTUBE)
            PATCHES=($(jq -r ".$APP_YOUTUBE[]" $CONFIG | tr '\n' ' '))
            ;;
        $APP_YOUTUBE_MUSIC)
            PATCHES=($(jq -r ".$APP_YOUTUBE_MUSIC[]" $CONFIG | tr '\n' ' '))
            ;;
    esac

    for i in ${PATCHES[@]}
    do
        if (test "microg-support" = $i || test "music-microg-support" = $i) && test "true" = $ROOT
        then
            continue
        fi

        PATCHES_CLI="$PATCHES_CLI -i $i"
    done
}

main $@
