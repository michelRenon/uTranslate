
function doSuggest(sgText, sgLg, sgModel) {

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
                // var jsonObject = JSON.parse(xhr.responseText);
                showRequestInfo("DONE : "+doc.responseText);

                // TODO : use a real JSON parser
                var jsonObj = eval(doc.responseText);


                /*
                // definitionsuggest.text = doc.responseText;
                definitionsuggest.text = "";
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    definitionsuggest.text += jsonObj[i]+"\n";
                */
                sgModel.clear();
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    sgModel.append({"suggest": jsonObj[i] })

                /*
                showRequestInfo(doc.responseXML);
                if (doc.responseXML != null) {
                    var a = doc.responseXML.documentElement;
                    for (var ii = 0; ii < a.childNodes.length; ++ii) {
                        showRequestInfo(a.childNodes[ii].nodeName);
                    }
                }
                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));
                */
            } else {
                showRequestInfo("ERROR");
            }
        }
    }

    doc.open("GET", url);
    doc.send();

}



function doSearchDefintion(dfText, dfLg, dfRes) {

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
            */
        } else if (doc.readyState == XMLHttpRequest.DONE) {
            // showRequestInfo("DONE");
            if ( doc.status == 200 ) {
                // var jsonObject = JSON.parse(xhr.responseText);
                showRequestInfo("DONE : "+doc.responseText);

                dfRes.text = doc.responseText;

                // TODO : use a real JSON parser
                /*
                var jsonObj = eval(doc.responseText);

                definitionres.text = "";
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    definitionres.text += jsonObj[i]+"\n";
                */
            } else {
                showRequestInfo("ERROR");
            }
        }
    }

    doc.open("GET", url);
    doc.send();

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
                // var jsonObject = JSON.parse(xhr.responseText);
                showRequestInfo("DONE : "+doc.responseText);

                trRes.text = doc.responseText;

                // TODO : use a real JSON parser
                /*
                var jsonObj = eval(doc.responseText);

                hellores.text = "";
                for (var i=0,l=jsonObj.length ; i < l ; i++)
                    hellores.text += jsonObj[i]+"\n";
                */
            } else {
                showRequestInfo("ERROR");
            }
        }
    }

    doc.open("GET", url);
    doc.send();

}


function showRequestInfo(text) {
    // log.text = log.text + "\n" + text
    console.log(text)
}
