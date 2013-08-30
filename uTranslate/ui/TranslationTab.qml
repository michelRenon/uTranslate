import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"
import "../controller.js" as Controller

Tab {
    id: translationTab
    title: i18n.tr("Translate")
    
    property bool canSuggest: true

    page: Page {
        Column {
            spacing: units.gu(2)
            anchors.fill: parent

            Row {
                spacing: units.gu(2)

                Button {
                    id:translatebtnlgsrc
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/fra.png"
                }

                TextField {
                    id: translateSearchText
                    // width: parent.width
                    placeholderText: "enter text to translate"
                    hasClearButton: true

                    onAccepted: {
                        console.debug("onAccepted"+translateSearchText.text)
                        tabs.updateContext({'searchtext':translateSearchText.text})
                        translationTab.doTranslate()
                    }

                    onTextChanged: {
                        console.debug("text changed="+translateSearchText.text)
                        if (translationTab.canSuggest) {
                            tabs.updateContext({'searchtext':translateSearchText.text})
                            translationTab.doSuggest()
                        }
                    }
                }
                Button {
                    id:translateBtnLgDest
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/eng.png"
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
                        text: suggest.replace(translateSearchText.text, "<b>"+translateSearchText.text+"</b>")
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                translationTab.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                translateSearchText.text = suggest
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
                    suggest: "suggestions"
                }
            }

            TextArea {
                id: translateRes
                placeholderText: ""
                enabled: true
                width: parent.width
                height: 200
            }
        }
    }

    function updateTabContext(context) {
        translationTab.canSuggest = false
        translateSearchText.text = context['searchtext'];
        translationTab.canSuggest = true
        // 'lgsrc': TODO
        // 'lgdest':TODO
        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        translationTab.doTranslate()
    }

    function doSuggest() {
        var lgSrc = 'fra'; // TODO
        Controller.doSuggest(translateSearchText.text, lgSrc, suggestModel, tabs)
    }

    function doTranslate() {
        var lgSrc = 'fra'; // TODO
        var lgDest = 'eng'; // TODO
        if (translateSearchText.text != "")
            Controller.doSearchTranslation(translateSearchText.text, lgSrc, lgDest, translateRes)

    }


    function doSwitchLg() {
        // TODO
    }
}
