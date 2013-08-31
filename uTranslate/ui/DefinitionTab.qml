/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1

import "../components"
import "../controller.js" as Controller

Tab {
    id: definitionTab
    title: i18n.tr("Definition")
    
    property bool canSuggest: true
    property string langSrc : 'fra'

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
                    id:definitionBtnLgSrc
                    objectName: "LangSrc"
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/fra.png"
                    onClicked: PopupUtils.open(langSelector, definitionBtnLgSrc)
                }
                TextField {
                    id: definitionSearchText
                    focus: true
                    // width: units.gu(60)

                    placeholderText: "Enter text"
                    hasClearButton: true

                    onAccepted: {
                        // console.debug("onAccepted='"+definitionSearchText.text+"'")
                        tabs.updateContext({'searchtext':definitionSearchText.text})
                        definitionTab.doDefine()
                    }

                    onTextChanged: {
                        // console.debug("text changed='"+definitionSearchText.text+"'")
                        if (definitionTab.canSuggest) {
                            tabs.updateContext({'searchtext':definitionSearchText.text})
                            definitionTab.doSuggest()
                        }
                    }
                }
                Button {
                    id:definitionbtnsearch
                    width: units.gu(10)
                    text: "Search"
                    onClicked: definitionTab.doDefine()
                }
            }
            ListView {
                /*
                x: definitionSearchText.left
                y: definitionSearchText.bottom
                z: 10
                */
                width: definitionSearchText.width // parent.width/2
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
                                return suggest.replace(definitionSearchText.text, "<b>"+definitionSearchText.text+"</b>")
                            else
                                return ""
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                // TODO : check if it'd be better to move next lines in a function
                                definitionTab.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                definitionSearchText.text = suggest
                                tabs.updateContext({'searchtext':definitionSearchText.text})
                                definitionTab.canSuggest = true

                                // start search of defintion
                                definitionTab.doDefine()
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
                id: definitionRes
                textFormat : TextEdit.RichText
                placeholderText: "<i>Definition</i>"
                enabled: true
                width: parent.width
                height: 200
            }
        }

        LangSelector {
            id: langSelector
        }
    }

    Component.onCompleted: definitionSearchText.forceActiveFocus()

    function updateTabContext(context) {
        definitionTab.canSuggest = false
        definitionSearchText.text = context['searchtext'];
        definitionTab.canSuggest = true
        definitionTab.setLang(context['lgsrc'])
        // 'lgdest':unused
        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        definitionTab.doDefine()

        definitionSearchText.forceActiveFocus()
    }

    function setLang(lg) {
        definitionTab.langSrc = lg
        definitionBtnLgSrc.iconSource = "../graphics/ext/"+lg+".png"
    }

    function updateLang(lg) {
        definitionTab.setLang(lg)
        tabs.updateContext({'lgsrc': lg})
        definitionTab.doSuggest()
        // TODO : empty res ?
    }

    function doSuggest() {
        var lg = definitionTab.langSrc;
        Controller.doSuggest(definitionSearchText.text, lg, suggestModel, tabs)
    }

    function doDefine() {
        var lg = definitionTab.langSrc;
        if (definitionSearchText.text != "")
            Controller.doSearchDefintion(definitionSearchText.text, lg, definitionTab.setResult)
    }

    function setResult(resultText) {
        // console.debug("appel de definitionTab.setResult()");
        if (resultText == "") {
            definitionRes.text = "<i>No Result</i>";
        } else {
            definitionRes.text = "<h1>Definition of '"+definitionSearchText.text+"'</h1>"+resultText;
        }
    }
}
