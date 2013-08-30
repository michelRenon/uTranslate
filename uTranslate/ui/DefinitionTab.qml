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
                    width: units.gu(10)
                    text: ""
                    iconSource: "../graphics/ext/fra.png"
                    onClicked: PopupUtils.open(popoverComponent, definitionBtnLgSrc)
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

        Component {
            id: popoverComponent

            Popover {
                id: popover
                Column {
                    id: containerLayout
                    anchors {
                        left: parent.left
                        top: parent.top
                        right: parent.right
                    }

                    ListItem.Standard {
                        text: i18n.tr("german")
                        icon: Qt.resolvedUrl("../graphics/ext/deu.png")
                        onClicked: {
                            definitionTab.updateLang('deu')
                            PopupUtils.close(popover)
                        }

                    }
                    ListItem.Standard {
                        text: i18n.tr("greek")
                        icon: Qt.resolvedUrl("../graphics/ext/ell.png")
                        onClicked: {
                            definitionTab.updateLang('ell')
                            PopupUtils.close(popover)
                        }

                    }
                    ListItem.Standard {
                        text: i18n.tr("english")
                        icon: Qt.resolvedUrl("../graphics/ext/eng.png")
                        onClicked: {
                            definitionTab.updateLang('eng')
                            PopupUtils.close(popover)
                        }
                    }
                    ListItem.Standard {
                        text: i18n.tr("french")
                        icon: Qt.resolvedUrl("../graphics/ext/fra.png")
                        onClicked: {
                            definitionTab.updateLang('fra')
                            PopupUtils.close(popover)
                        }

                    }
                    ListItem.Standard {
                        text: i18n.tr("italian")
                        icon: Qt.resolvedUrl("../graphics/ext/ita.png")
                        onClicked: {
                            definitionTab.updateLang('ita')
                            PopupUtils.close(popover)
                        }

                    }
                    ListItem.Standard {
                        text: i18n.tr("portugese")
                        icon: Qt.resolvedUrl("../graphics/ext/por.png")
                        onClicked: {
                            definitionTab.updateLang('por')
                            PopupUtils.close(popover)
                        }

                    }
                    ListItem.Standard {
                        text: i18n.tr("spanish")
                        icon: Qt.resolvedUrl("../graphics/ext/spa.png")
                        onClicked: {
                            definitionTab.updateLang('spa')
                            PopupUtils.close(popover)
                        }

                    }

                }
            }
        }
    }

    function updateTabContext(context) {
        definitionTab.canSuggest = false
        definitionSearchText.text = context['searchtext'];
        definitionTab.canSuggest = true
        definitionTab.setLang(context['lgsrc'])
        // 'lgdest':unused
        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        definitionTab.doDefine()
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
            Controller.doSearchDefintion(definitionSearchText.text, lg, definitionRes)
    }
}
