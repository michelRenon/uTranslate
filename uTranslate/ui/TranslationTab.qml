/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

import "../components"
import "../controller.js" as Controller

Tab {
    id: translationTab
    title: i18n.tr("Translate")
    
    property bool canSuggest: false
    property string langSrc : 'fra'
    property string langDest : 'eng'

    page: Page {

        tools: WorldTabTools {
            objectName: "worldTab_tools"
        }

        Button {
            id:translateBtnLgSrc
            objectName: "LangSrc"
            anchors.left : parent.left
            anchors.top: parent.top
            anchors.margins: units.gu(1)
            width: units.gu(6)
            height: translateSearchText.height
            text: ""
            iconSource: "../graphics/ext/fra.png"
            onClicked: PopupUtils.open(langSelector, translateBtnLgSrc)
        }
        TextField {
            id: translateSearchText
            anchors.left: translateBtnLgSrc.right
            anchors.right: translateBtnLgDest.left
            anchors.top: parent.top
            anchors.margins: units.gu(1)
            placeholderText: "enter text to translate"
            hasClearButton: true

            onAccepted: {
                // console.debug("onAccepted:'"+translateSearchText.text+"'")
                tabs.updateContext({'searchtext':translateSearchText.text})
                translationTab.doTranslate()
            }

            onTextChanged: {
                // console.debug("text changed='"+translateSearchText.text+"', "+translationTab.canSuggest)
                if (translationTab.canSuggest) {
                    tabs.updateContext({'searchtext':translateSearchText.text})
                    translationTab.doSuggest()
                }
            }

            onFocusChanged: {
                // console.debug("onFocusChanged="+translateSearchText.focus);
                translateSearchText.updateSuggestList();
            }

            function updateSuggestList() {
                var test = translationTab.canSuggest;
                test = test && translateSearchText.focus;
                test = test && translateSearchText.text != "";
                // console.debug("translateSearchText.updateSuggestList test="+test+", visible="+rectViewSuggestion.visible);
                if (test)
                    rectViewSuggestion.expand()
                else
                    rectViewSuggestion.reduce()
            }
        }
        Button {
            id:translateBtnLgDest
            objectName: "LangDest"
            anchors.right: translateBtnSearch.left
            anchors.top: parent.top
            anchors.margins: units.gu(1)
            width: units.gu(6)
            height: translateSearchText.height
            text: ""
            iconSource: "../graphics/ext/eng.png"
            onClicked: PopupUtils.open(langSelector, translateBtnLgDest)
        }
        Button {
            id:translateBtnSearch
            anchors.right: translateBtnSwitchLg.left
            anchors.top: parent.top
            anchors.margins: units.gu(1)
            width: units.gu(8)
            height: translateSearchText.height
            text: "Search"
            onClicked: translationTab.doTranslate()
        }
        Button {
            id:translateBtnSwitchLg
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: units.gu(1)
            width: units.gu(6)
            height: translateSearchText.height
            text: "<-->"
            onClicked: translationTab.doSwitchLg()
        }


        Rectangle {
            id: rectViewSuggestion
            z: 1
            anchors.top: translateBtnLgSrc.bottom
            anchors.left: translateSearchText.left
            anchors.right: parent.right // translateSearchText.right
            height: units.gu(0) // ????
            border.color: "#aaaaaa"
            clip: true
            visible: true

            property bool expanded: false

            ListView {
                id: listViewSuggestion
                anchors.fill: parent
                model: suggestModel
                // delegate: suggestDelegate

                delegate: Rectangle {
                    width: ListView.view.width
                    height: units.gu(3)
                    Text {
                        anchors.fill: parent

                        // Ajouter du style pour surligner les lettres correspondantes.
                        // TODO : mieux gérer les remplacement : maj/minuscules, caracteres proches (eéè...)
                        // TODO : voir si les perfs sont OK (mettre en cache le search text ?)
                        text: {
                            if (suggest)
                                return suggest.replace(translateSearchText.text, "<b>"+translateSearchText.text+"</b>")
                            else
                                return ""
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if (rectViewSuggestion.expanded) {
                                    // TODO : check if it'd be better to move next lines in a function
                                    translationTab.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                    translateSearchText.text = suggest
                                    tabs.updateContext({'searchtext':translateSearchText.text})
                                    translationTab.canSuggest = true


                                    // start translation
                                    translationTab.doTranslate()
                                } else {
                                    rectViewSuggestion.expand()
                                }
                            }
                        }
                    }
                }
            }
            Scrollbar {
                flickableItem: listViewSuggestion
            }

            function reduce() {
                if (rectViewSuggestion.expanded != false) {
                    animateReduce.start()
                    rectViewSuggestion.expanded = false
                }
            }

            function expand() {
                // console.debug("EXPAND() : rectViewSuggestion.expanded="+rectViewSuggestion.expanded+" visible="+rectViewSuggestion.visible);
                if (rectViewSuggestion.expanded != true) {
                    animateExpand.start()
                    rectViewSuggestion.expanded = true
                }
            }

            NumberAnimation {
                id: animateReduce
                target: rectViewSuggestion
                properties: "height"
                from: units.gu(20)
                to: units.gu(0)
                duration: 100
            }

            NumberAnimation {
                id: animateExpand
                target: rectViewSuggestion
                properties: "height"
                from: units.gu(0)
                to: units.gu(20)
                duration: 100
            }

            Component.onCompleted: {
                rectViewSuggestion.reduce()
            }
        }

        ListModel {
            id: suggestModel

            ListElement {
                suggest: ""
            }
        }
        TextArea {
            id: translateRes
            placeholderText: "<i>Translations</i>"
            textFormat : TextEdit.RichText
            enabled: true
            // anchors.top: rectViewSuggestion.bottom
            anchors.top: translateBtnLgSrc.bottom
            anchors.topMargin: units.gu(1)
            anchors.bottom: parent.bottom
            width: parent.width

            // onActiveFocusChanged: rectViewSuggestion.reduce()

        }

        LangSelector {
            id: langSelector
        }

    }

    Component.onCompleted: translateSearchText.forceActiveFocus()

    function updateTabContext(context, startup) {
        if (typeof(startup) === "undefined")
            startup = false;
        // console.debug("updateTabContext")
        translationTab.canSuggest = false
        translateSearchText.text = context['searchtext'];
        translationTab.canSuggest = true
        translationTab.setLang(context['lgsrc'])
        translationTab.setLangDest(context['lgdest'])

        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        if (startup) {
            /*
            // version :
            // - focus on search text,
            // - suggestion list is shown
            // - translation id done
            */
            translationTab.doTranslate(false);
            translateSearchText.forceActiveFocus();
            translateSearchText.updateSuggestList();

        } else {
            // *
            // version : focus on translation
            translationTab.doTranslate(true)
            // */
        }
    }

    function setLang(lg) {
        translationTab.langSrc = lg
        translateBtnLgSrc.iconSource = "../graphics/ext/"+lg+".png"
    }

    function updateLang(lg) {
        translationTab.setLang(lg)
        tabs.updateContext({'lgsrc': lg})
        translationTab.doSuggest()
        // TODO : empty res ?
    }

    function setLangDest(lg) {
        translationTab.langDest = lg
        translateBtnLgDest.iconSource = "../graphics/ext/"+lg+".png"
    }

    function updateLangDest(lg) {
        translationTab.setLangDest(lg)
        tabs.updateContext({'lgdest': lg})
        translationTab.doTranslate()
        // TODO : suggest or translate ??
    }

    function doSuggest() {
        var lgSrc = translationTab.langSrc;
        translateSearchText.forceActiveFocus()
        rectViewSuggestion.expand()
        Controller.doSuggest(translateSearchText.text, lgSrc, suggestModel, tabs)
    }

    function doTranslate(focusRes) {
        // console.debug("focusRes="+typeof(focusRes));
        if(typeof(focusRes) === "undefined")
            focusRes = true;
        var lgSrc = translationTab.langSrc;
        var lgDest = translationTab.langDest;
        rectViewSuggestion.reduce()
        if (translateSearchText.text != "")
            Controller.doSearchTranslation(translateSearchText.text, lgSrc, lgDest, function(res) {
                translationTab.setResult(res, focusRes)
            });
        else
            translationTab.setResult("", focusRes);
    }

    function setResult(resultText, focusRes) {
        // console.debug("appel de translationTab.setResult()");
        if (resultText == "") {
            translateRes.text = "<i>No Result</i>";
        } else {
            translateRes.text = "<h1>Translation of '"+translateSearchText.text+"'</h1>"+resultText;
        }
        if (focusRes)
            translateRes.forceActiveFocus();
    }

    function doSwitchLg() {
        var lgSrc = translationTab.langSrc;
        var lgDest = translationTab.langDest;
        translationTab.setLang(lgDest)
        tabs.updateContext({'lgsrc': lgDest})

        translationTab.setLangDest(lgSrc)
        tabs.updateContext({'lgdest': lgSrc})

        translationTab.doSuggest()
        // translationTab.doTranslate()
    }
}
