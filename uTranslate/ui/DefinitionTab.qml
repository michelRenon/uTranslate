import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"
import "../controller.js" as Controller

Tab {
    title: i18n.tr("Definition")
    
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
                    id:definitionbtnlgsrc
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/fra.png"

                }
                TextField {
                    id: definitionsearchtext
                    focus: true
                    // width: units.gu(60)

                    placeholderText: "Enter text"
                    hasClearButton: true

                    onAccepted: {
                        console.debug("onAccepted"+definitionsearchtext.text)
                        tabs.updateContext({'searchtext':definitionsearchtext.text})
                        Controller.doSearchDefintion(definitionsearchtext.text, 'fra', definitionres)
                    }

                    onTextChanged: {
                        console.debug("text changed="+definitionsearchtext.text)
                        tabs.updateContext({'searchtext':definitionsearchtext.text})
                        Controller.doSuggest(definitionsearchtext.text, 'fra', suggestModel)
                    }
                }
                Button {
                    id:definitionbtnsearch
                    width: units.gu(10)
                    text: "Search"
                    // TODO : provide a parameter-less call : the controller should prepare parameters himself
                    onClicked: Controller.doSearchDefintion(definitionsearchtext.text, 'fra', definitionres)
                }
            }
            ListView {
                /*
                x: definitionsearchtext.left
                y: definitionsearchtext.bottom
                z: 10
                */
                width: definitionsearchtext.width // parent.width/2
                height: 100
                // anchors.fill: parent
                model: suggestModel
                // delegate: suggestDelegate

                delegate: Row {
                    Text {
                        // Ajouter du style pour surligner les lettres correspondantes.
                        // TODO : mieux gérer les remplacement : maj/minuscules, caracteres proches (eéè...)
                        // TODO : voir si les perfs sont OK (mettre en cache le search text ?)
                        text: suggest.replace(definitionsearchtext.text, "<b>"+definitionsearchtext.text+"</b>")
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                // TODO : set mode pour ne pas recharger les suggestions

                                definitionsearchtext.text = suggest
                                // TODO : lancer la recherche
                                Controller.doSearchDefintion(definitionsearchtext.text, 'fra', definitionres)
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
                id: definitionres
                placeholderText: "Resultats"
                enabled: true
                width: parent.width
                height: 200
            }
        }
    }

    function setContext(context) {
        definitionsearchtext.text = context['searchtext'];
    }

}
