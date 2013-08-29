import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"
import "../controller.js" as Controller

Tab {
    id: definitionTab
    title: i18n.tr("Definition")
    
    property bool canSuggest: true

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
                    id: definitionSearchText
                    focus: true
                    // width: units.gu(60)

                    placeholderText: "Enter text"
                    hasClearButton: true

                    onAccepted: {
                        console.debug("onAccepted"+definitionSearchText.text)
                        tabs.updateContext({'searchtext':definitionSearchText.text})
                        definitionTab.doDefine()
                    }

                    onTextChanged: {
                        console.debug("text changed="+definitionSearchText.text)
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
                        text: suggest.replace(definitionSearchText.text, "<b>"+definitionSearchText.text+"</b>")
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                definitionTab.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                definitionSearchText.text = suggest
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
                    suggest: "suggestions"
                }
            }
            TextArea {
                id: definitionRes
                placeholderText: "Resultats"
                enabled: true
                width: parent.width
                height: 200
            }
        }
    }

    function setContext(context) {
        definitionTab.canSuggest = false
        definitionSearchText.text = context['searchtext'];
        definitionTab.canSuggest = true
        // 'lgsrc': TODO
        // 'lgdest':TODO
        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        definitionTab.doDefine()
    }

    function doSuggest() {
        var lg = 'fra'; // TODO
        Controller.doSuggest(definitionSearchText.text, lg, suggestModel, tabs)
    }

    function doDefine() {
        var lg = 'fra'; // TODO : get selected lang
        if (definitionSearchText.text != "")
            Controller.doSearchDefintion(definitionSearchText.text, lg, definitionRes)
    }
}
