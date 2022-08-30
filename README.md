# ReVanced

## Build locally

### Android

-   Get Termux from [F-Droid](https://f-droid.org/packages/com.termux/) ([NOT Google Play](https://github.com/termux/termux-app#google-play-store-deprecated)) and then run the script with the following command:

```bash
curl -fLsS --proto =https --tlsv1.2 https://raw.githubusercontent.com/masterflitzer/revanced/main/revanced-builder.sh | bash
```

### Linux/WSL

-   Download the configuration:

```bash
curl -fLOsS --proto =https --tlsv1.2 https://raw.githubusercontent.com/masterflitzer/revanced/main/revanced.json
```

-   Change the downloaded config file as you wish (you can find the list of patches [here](https://github.com/revanced/revanced-patches))
-   Install `java` (17+) and `jq` and then run the script with the following command:

```bash
curl -fLsS --proto =https --tlsv1.2 https://raw.githubusercontent.com/masterflitzer/revanced/main/revanced.sh | bash
```

## Build on GitHub

**_Coming soon_**
