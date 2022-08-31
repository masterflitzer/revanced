# ReVanced

## Build locally

### Android

This will use [ReVanced Builder by reisxd](https://github.com/reisxd/revanced-builder.git) and is basically a simple wrapper script

-   Get Termux from [F-Droid](https://f-droid.org/packages/com.termux/) ([NOT Google Play](https://github.com/termux/termux-app#google-play-store-deprecated)) and then run the script with the following command:

```bash
curl -fLsS https://raw.githubusercontent.com/masterflitzer/revanced/main/revanced-builder.sh --proto =https --tlsv1.2 | bash
```

### Linux/WSL

-   Download the configuration:

```bash
curl -fLOsS https://raw.githubusercontent.com/masterflitzer/revanced/main/revanced.json --proto =https --tlsv1.2
```

-   Change the downloaded config file as you wish (you can find the list of patches [here](https://github.com/revanced/revanced-patches))
-   Install `java` (17+) and `jq` (e.g. `sudo apt install openjdk-17-jre jq` on Ubuntu) \
    and then run the script with the following command:

```bash
curl -fLsS https://raw.githubusercontent.com/masterflitzer/revanced/main/revanced.sh --proto =https --tlsv1.2 | bash
```

## Build on GitHub

**_Coming soon_**
