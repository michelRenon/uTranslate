import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"
import "../controller.js" as Controller

Tab {
    title: i18n.tr("Translate")
    
    page: Page {
        Column {
            spacing: units.gu(2)
            anchors.fill: parent

            Row {
                spacing: units.gu(2)

                Button {
                    id:definitionbtnlgsrc
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/fra.png"
                }

                TextField {
                    id: translatesearchtext
                    // width: parent.width
                    placeholderText: "enter text to translate"
                    hasClearButton: true

                    onAccepted: {
                        console.debug("onAccepted"+translatesearchtext.text)
                        tabs.updateContext({'searchtext':translatesearchtext.text})
                        Controller.doSearchTranslation(translatesearchtext.text, 'fra', 'eng', translateres)
                    }

                    onTextChanged: {
                        console.debug("text changed="+translatesearchtext.text)
                        tabs.updateContext({'searchtext':translatesearchtext.text})
                        Controller.doSuggest(translatesearchtext.text, 'fra', suggestModel)
                    }
                }
                Button {
                    id:definitionbtnlgdest
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/eng.png"
                }

                Button {
                    id:definitionbtnsearch
                    width: units.gu(10)
                    text: "Search"
                    // TODO : provide a parameter-less call : the controller should prepare parameters himself
                    onClicked: Controller.doSearchTranslation(translatesearchtext.text, 'fra', 'eng', translateres)
                }

                Button {
                    id:definitionbtnswitchlg
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
                        text: suggest.replace(translatesearchtext.text, "<b>"+translatesearchtext.text+"</b>")
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                // TODO : set mode pour ne pas recharger les suggestions

                                translatesearchtext.text = suggest
                                // TODO : lancer la recherche
                                Controller.doSearchTranslation(translatesearchtext.text, 'fra', 'eng', translateres)
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
                id: translateres
                placeholderText: ""
                enabled: true
                width: parent.width
                height: 200
            }
        }
    }

    function setContext(context) {
        translatesearchtext.text = context['searchtext'];
    }

}
