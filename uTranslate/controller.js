
function doSuggest(sgText, sgLg, sgModel, sgTabs) {

    // http://qt-project.org/doc/qt-5.0/qtqml/qtqml-javascript-qmlglobalobject.html#xmlhttprequest

    var url = "http://glosbe.com/ajax/phrasesAutosuggest?from="+sgLg+"&dest="+sgLg+"&phrase="+sgText

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
                // showRequestInfo("DONE : "+doc.responseText);
                var jsonObj = JSON.parse(doc.responseText);

                /*
                // definitionsuggest.text = doc.responseText;
                definitionsuggest.text = "";
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    definitionsuggest.text += jsonObj[i]+"\n";
                */
                sgModel.clear();
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    sgModel.append({"suggest": jsonObj[i] })

                // update the general context with
                sgTabs.updateContext({'suggest':jsonObj})

             } else {
                showRequestInfo("ERROR");
            }
        }
    }

    doc.open("GET", url);
    doc.send();

}



function doSearchDefintion(dfText, dfLg, dfRes) {

    doSearchTranslation(dfText, dfLg, dfLg, dfRes);
    /*
    var url = "http://glosbe.com/gapi/translate?from="+dfLg+"&dest="+dfLg+"&format=json&pretty=true&phrase="+dfText

    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            /*
            showRequestInfo("Headers RECEIVED");
            showRequestInfo("Headers -->");
            showRequestInfo(doc.getAllResponseHeaders ());
            showRequestInfo("Last modified -->");
            showRequestInfo(doc.getResponseHeader ("Last-Modified"));
            * /
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            // showRequestInfo("DONE");
            if ( doc.status == 200 ) {
                // var jsonObject = JSON.parse(xhr.responseText);
                // showRequestInfo("DONE : "+doc.responseText);

                dfRes.text = doc.responseText;

                // TODO : use a real JSON parser
                /*
                var jsonObj = eval(doc.responseText);

                definitionres.text = "";
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    definitionres.text += jsonObj[i]+"\n";
                * /
            } else {
                showRequestInfo("ERROR");
            }
        }
    }

    doc.open("GET", url);
    doc.send();
    */
}

function doSearchTranslation(trText, trLgSrc, trLgDest, trRes) {

    var url = "http://glosbe.com/gapi/translate?from="+trLgSrc+"&dest="+trLgDest+"&format=json&pretty=true&phrase="+trText

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
                // showRequestInfo("DONE : "+doc.responseText);

                // raw
                // trRes.text = doc.responseText;

                var templateT1 = '<p><big><strong>%1</strong></big>&nbsp;&nbsp;&nbsp;<i><small>(%2)</small></i></p>';
                var templateT2 = "<blockquote>%1</blockquote>";

                var jsonObj = JSON.parse(doc.responseText);
                var authors = jsonObj['authors'];
                var tucs = jsonObj['tuc'];
                trRes.text = "";
                var tempText = "";
                for (var ti=0,tl=tucs.length ; ti < tl ; ti++) {
                    if (tucs[ti]['phrase']) {
                        var auth = authors[tucs[ti]['authors'][0]];
                        // tempText += "<h1>"+tucs[ti]['phrase']['text'];
                        // tempText += "&nbsp;<i>("+ auth["N"]+")</i></h1>";
                        // // tempText += "\n";
                        var t1 = templateT1.replace("%1", tucs[ti]['phrase']['text']);
                        t1 = t1.replace("%2", auth["N"])
                        tempText += t1;


                        if (tucs[ti]['meanings']) {
                            var meanings = tucs[ti]['meanings'];
                            for (var mi=0,ml=meanings.length ; mi < ml ; mi++) {
                                // tempText += "<blockquote>"+meanings[mi]['text']+"</blockquote>";
                                tempText += templateT2.replace("%1", meanings[mi]['text']);
                            }
                        }
                    }
                }
                trRes.text = tempText;

            } else {
                showRequestInfo("ERROR");
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
