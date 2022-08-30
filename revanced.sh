#!/usr/bin/env bash

main () {
    CWD=$(dirname $(realpath $0))

    RV_CLI="revanced/revanced-cli"
    RV_INTEGRATIONS="revanced/revanced-integrations"
    RV_PATCHES="revanced/revanced-patches"

    APP_REDDIT="reddit"
    APP_TWITTER="twitter"
    APP_YOUTUBE="youtube"
    APP_YOUTUBE_MUSIC="youtube-music"

    if ! command -v java &> /dev/null
    then
        cat << 'EOF'

You need to install Java 17+ (e.g. OpenJDK)
You can install it with: sudo apt install openjdk-17-jre

EOF
        return 1
    fi

    cat << EOF

Following apps can be patched:
      App                  File                 Package
    * Reddit               $APP_REDDIT.apk           com.reddit.frontpage
    * Twitter              $APP_TWITTER.apk          com.twitter.android
    * YouTube (*)          $APP_YOUTUBE.apk          com.google.android.youtube
    * YouTube Music (*)    $APP_YOUTUBE_MUSIC.apk    com.google.android.apps.youtube.music

In order to patch an app you need to place the apk (not bundled) in the same directory
this script is and name it like shown above

With (*) marked apps will need microG and the corresponding patch to work on non-rooted devices

and you can get the list of available patches from https://github.com/revanced/revanced-patches
You can download apps from the following sources:
    * Reddit:           https://apkmirror.com/apk/redditinc/reddit
    * Twitter:          https://apkmirror.com/apk/twitter-inc/twitter
    * YouTube:          https://apkmirror.com/apk/google-inc/youtube
    * YouTube Music:    https://apkmirror.com/apk/google-inc/youtube-music
    * Vanced microG:    https://apkmirror.com/apk/team-vanced/microg-youtube-vanced

EOF

    revanced_download $RV_CLI jar
    revanced_download $RV_INTEGRATIONS apk
    revanced_download $RV_PATCHES jar

    if test -f "$CWD/$APP_REDDIT.apk"
    then
        revanced_execute $APP_REDDIT
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
    PATCHES_CLI=""
    PATCHES=()
    case $APP in
        $APP_REDDIT)
            PATCHES=(general-reddit-ads)
            ;;
        $APP_TWITTER)
            PATCHES=(timeline-ads)
            ;;
        $APP_YOUTUBE)
            PATCHES=($(tr '\n' ' ' < $APP_YOUTUBE.config))
            ;;
        $APP_YOUTUBE_MUSIC)
            PATCHES=($(tr '\n' ' ' < $APP_YOUTUBE_MUSIC.config))
            ;;
    esac

    for i in ${PATCHES[@]}
    do
        PATCHES_CLI="$PATCHES_CLI -i $i"
    done
}

main $@
