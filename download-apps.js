"use strict";

import { DOMParser } from "https://deno.land/x/deno_dom@v0.1.34-alpha/deno-dom-wasm.ts";

const parser = new DOMParser();
const parseErrorMsg = "An error occured while trying to parse the page";

let url, document;

url = "https://apkmirror.com/apk/google-inc/youtube/";
document = await getDocumentFromURL(url);

const generalContainerCollection = queryAll(
    document.body,
    "#primary > .listWidget.p-relative"
);
const versionContainer = getFirstContainerWithHeading(
    generalContainerCollection,
    "All versions"
);
const versionCollection = queryAll(
    versionContainer.parentElement,
    ".appRow .appRowTitle > a"
);

const versionsStable = Array.from(versionCollection)
    .filter((x) => x != null)
    .filter((x) => x.textContent.toLowerCase().includes("beta") === false);

if (versionsStable.length === 0) {
    throw new Error("NOT YET IMPLEMENTED");
}

url = versionsStable[0].href;
document = await getDocumentFromURL(url);

const specificContainerCollection = queryAll(
    document.body,
    "#content > .listWidget"
);
const downloadContainer = getFirstContainerWithHeading(
    specificContainerCollection,
    "Download"
);
const downloadCollection = queryAll(
    downloadContainer.parentElement.children[0],
    "a"
);

const downloadsNotBundle = Array.from(downloadCollection).filter();

function getFirstContainerWithHeading(htmlCollection, text) {
    const result = Array.from(htmlCollection).filter(
        (x) => x.children[0].textContent === text
    )[0];
    if (result == null) throw new Error(parseErrorMsg);
    return result;
}

function queryAll(element, selectors) {
    if (element == null) throw new Error(parseErrorMsg);
    const collection = element.querySelectorAll(selectors);
    if (collection == null || collection.length === 0)
        throw new Error(parseErrorMsg);
    return collection;
}

async function getDocumentFromURL(url) {
    const request = fetch(url);
    const response = await request;
    const text = await response.text();
    const root = parser.parseFromString(text, "text/html");
    if (root == null) throw new Error(parseErrorMsg);
    return root;
}

export {};
