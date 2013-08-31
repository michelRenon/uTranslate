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
    
    property bool canSuggest: true
    property string langSrc : 'fra'
    property string langDest : 'eng'

    page: Page {

        tools: WorldTabTools {
            objectName: "worldTab_tools"
        }

        Column {
            spacing: units.gu(2)
            anchors.fill: parent

            Row {
                spacing: units.gu(2)

                Button {
                    id:translateBtnLgSrc
                    objectName: "LangSrc"
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/fra.png"
                    onClicked: PopupUtils.open(langSelector, translateBtnLgSrc)
                }

                TextField {
                    id: translateSearchText
                    // width: parent.width
                    placeholderText: "enter text to translate"
                    hasClearButton: true

                    onAccepted: {
                        // console.debug("onAccepted:'"+translateSearchText.text+"'")
                        tabs.updateContext({'searchtext':translateSearchText.text})
                        translationTab.doTranslate()
                    }

                    onTextChanged: {
                        // console.debug("text changed='"+translateSearchText.text+"'")
                        if (translationTab.canSuggest) {
                            tabs.updateContext({'searchtext':translateSearchText.text})
                            translationTab.doSuggest()
                        }
                    }
                }
                Button {
                    id:translateBtnLgDest
                    objectName: "LangDest"
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/eng.png"
                    onClicked: PopupUtils.open(langSelector, translateBtnLgDest)
                }

                Button {
                    id:translateBtnSearch
                    width: units.gu(10)
                    text: "Search"
                    onClicked: translationTab.doTranslate()
                }

                Button {
                    id:translateBtnSwitchLg
                    width: units.gu(10)
                    text: "<-->"
                    onClicked: translationTab.doSwitchLg()
                }
            }


            ListView {
                width: parent.width/2
                height: 100
                // anchors.fill: parent
                model: suggestModel
                // delegate: suggestDelegate

                delegate: Row {
                    Text {
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
                                // TODO : check if it'd be better to move next lines in a function
                                translationTab.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                translateSearchText.text = suggest
                                tabs.updateContext({'searchtext':translateSearchText.text})
                                translationTab.canSuggest = true

                                // start translation
                                translationTab.doTranslate()
                            }
                        }
                    }
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
                width: parent.width
                height: 200
            }

         }

        LangSelector {
            id: langSelector
        }

    }

    Component.onCompleted: translateSearchText.forceActiveFocus()

    function updateTabContext(context) {
        translationTab.canSuggest = false
        translateSearchText.text = context['searchtext'];
        translationTab.canSuggest = true
        translationTab.setLang(context['lgsrc'])
        translationTab.setLangDest(context['lgdest'])

        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        translationTab.doTranslate()

        translateSearchText.forceActiveFocus()
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
        Controller.doSuggest(translateSearchText.text, lgSrc, suggestModel, tabs)
    }

    function doTranslate() {
        var lgSrc = translationTab.langSrc;
        var lgDest = translationTab.langDest;
        if (translateSearchText.text != "")
            Controller.doSearchTranslation(translateSearchText.text, lgSrc, lgDest, translationTab.setResult);
        else
            translationTab.setResult("");
    }

    function setResult(resultText) {
        // console.debug("appel de translationTab.setResult()");
        if (resultText == "") {
            translateRes.text = "<i>No Result</i>";
        } else {
            translateRes.text = "<h1>Translation of '"+translateSearchText.text+"'</h1>"+resultText;
        }
    }

    function doSwitchLg() {
        var lgSrc = translationTab.langSrc;
        var lgDest = translationTab.langDest;
        translationTab.setLang(lgDest)
        tabs.updateContext({'lgsrc': lgDest})

        translationTab.setLangDest(lgSrc)
        tabs.updateContext({'lgdest': lgSrc})

        translationTab.doSuggest()
        translationTab.doTranslate()
    }
}
