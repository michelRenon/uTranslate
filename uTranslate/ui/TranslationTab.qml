import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"
import "../controller.js" as Controller

Tab {
    id: translationTab
    title: i18n.tr("Translate")
    
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
                        tabs.updateContext({'searchtext':translateSearchText.text})
                        Controller.doSuggest(translateSearchText.text, 'fra', suggestModel)
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
                    onClicked: Controller.doSwitchLg()
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
                                // TODO : set mode pour ne pas recharger les suggestions

                                translateSearchText.text = suggest
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

    function setContext(context) {
        translateSearchText.text = context['searchtext'];
    }

    function doTranslate() {
        var lgSrc = 'fra'; // TODO
        var lgDest = 'eng'; // TODO
        Controller.doSearchTranslation(translateSearchText.text, lgSrc, lgDest, translateRes)

    }
}
