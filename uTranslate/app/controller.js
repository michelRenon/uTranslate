/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
function doSuggest(sgText, sgLg, sgModel, sgTabs, sgCB) {

    // http://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-qmlglobalobject.html#xmlhttprequest

    var url = "https://glosbe.com/ajax/phrasesAutosuggest?from="+sgLg+"&dest="+sgLg+"&phrase="+sgText

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            /*
            showRequestInfo("Headers RECEIVED");
            showRequestInfo("Headers -->");
            showRequestInfo(doc.getAllResponseHeaders ());
            showRequestInfo("Last modified -->");
            showRequestInfo(doc.getResponseHeader ("Last-Modified"));
            */
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            // showRequestInfo("DONE");
            if ( doc.status == 200 ) {
                showRequestInfo("DONE : "+doc.responseText);
                var jsonObj = JSON.parse(doc.responseText);

                updateSuggestionModel(sgModel, jsonObj) ;
               // update the general context with
                sgTabs.updateContext({'suggest':jsonObj})

             } else {
                showRequestInfo("ERROR SUGGEST");
            }
            // callBack
            sgCB();
        }
    }
    doc.open("GET", url);
    doc.send();
}

function doSearchDefintion(dfText, dfLg, dfCB) {

    doSearchTranslation(dfText, dfLg, dfLg, dfCB);
}

function doSearchTranslation(trText, trLgSrc, trLgDest, trCB) {
    /*
    XMLHttpRequest.OPENED : 1
    XMLHttpRequest.HEADERS_RECEIVED : 2
    XMLHttpRequest.LOADING : 3
    XMLHttpRequest.DONE : 4

    XMLHttpRequest.UNSENT : 0
    */
    var url = "https://glosbe.com/gapi/translate?from="+trLgSrc+"&dest="+trLgDest+"&format=json&pretty=true&phrase="+trText

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            /*
            showRequestInfo("Headers RECEIVED");
            showRequestInfo("Headers -->");
            showRequestInfo(doc.getAllResponseHeaders ());
            showRequestInfo("Last modified -->");
            showRequestInfo(doc.getResponseHeader ("Last-Modified"));
            */
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            if ( doc.status == 200 ) {
                // showRequestInfo("DONE : "+doc.responseText);

                // raw
                // trCB(doc.responseText);

                var jsonObj = JSON.parse(doc.responseText);

                // rendering of results
                var templateT1 = '<p><big><strong>%1</strong></big>&nbsp;&nbsp;&nbsp;<i><small>(%2)</small></i></p>';
                var templateT2 = "<blockquote>%1</blockquote>";
                var tempText = "";
                var authors = jsonObj['authors'];
                var tucs = jsonObj['tuc'];
                // console.debug("tucs="+typeof(tucs));
                if (typeof(tucs) !== "undefined") {
                    if (tucs.length > 0) {
                        for (var ti=0,tl=tucs.length ; ti < tl ; ti++) {
                            var phrase = tucs[ti]['phrase'];
                            if (typeof(phrase) !== "undefined") {
                                var auth = authors[tucs[ti]['authors'][0]];
                                var t1 = templateT1.replace("%1", phrase['text']);
                                t1 = t1.replace("%2", auth["N"])
                                tempText += t1;
                            }

                            var meanings = tucs[ti]['meanings'];
                            if (typeof(meanings) !== "undefined") {
                                for (var mi=0,ml=meanings.length ; mi < ml ; mi++) {
                                    tempText += templateT2.replace("%1", meanings[mi]['text']);
                                }
                            }
                        }
                    } else {
                        tempText = "";
                    }
                } else {
                    tempText = "";
                }

                // callBack with no error
                trCB(tempText, 0);

            } else {
                // console.debug("ERROR TRANSLATE"+doc.status+":"+doc.statusText);

                // Show error to the user : callback with error.
                // 400 : bad request
                // 404 : not found
                var error = 1;
                if (doc.status != 0)
                    error = doc.status
                trCB("", error)
            }
        }
    }
    doc.open("GET", url);
    doc.send();
}

function updateSuggestionModel(sgModel, datas) {
    sgModel.clear();
    for (var i=0,l=datas.length ; i < l ; i++)
        sgModel.append({"suggest": datas[i] })
}


function showRequestInfo(text) {
    // log.text = log.text + "\n" + text
    console.log(text)
}
