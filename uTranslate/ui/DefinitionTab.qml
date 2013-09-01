/* This file is part of udefinition application.
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
    
    property bool canSuggest: false
    property string langSrc : 'fra'

    page: Page {

        tools: WorldTabTools {
            objectName: "worldTab_tools"
        }
        
        Button {
            id:definitionBtnLgSrc
            objectName: "LangSrc"
            anchors.left: parent.left
            width: units.gu(6)
            height: definitionSearchText.height
            text: ""
            iconSource: "../graphics/ext/fra.png"
            onClicked: PopupUtils.open(langSelector, definitionBtnLgSrc)
        }
        TextField {
            id: definitionSearchText
            anchors.left: definitionBtnLgSrc.right
            anchors.right: definitionBtnSearch.left
            anchors.top: definitionBtnLgSrc.top
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

            onFocusChanged: {
                // console.debug("onFocusChanged="+definitionSearchText.focus);
                if (definitionTab.canSuggest) {
                    if (definitionSearchText.focus)
                        rectViewSuggestion.expand()
                    else
                        rectViewSuggestion.reduce()
                }
            }
        }
        Button {
            id:definitionBtnSearch
            anchors.right: parent.right
            anchors.top: definitionBtnLgSrc.top
            width: units.gu(8)
            height: definitionSearchText.height
            text: "Search"
            onClicked: definitionTab.doDefine()
        }

        Rectangle {
            id: rectViewSuggestion
            z: 1
            anchors.top: definitionBtnLgSrc.bottom
            anchors.left: definitionSearchText.left
            anchors.right: parent.right // definitionSearchText.right
            height: units.gu(0) // ????
            border.color: "#aaaaaa"
            clip: true
            visible: false

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
                                return suggest.replace(definitionSearchText.text, "<b>"+definitionSearchText.text+"</b>")
                            else
                                return ""
                        }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                if (rectViewSuggestion.expanded) {
                                    // TODO : check if it'd be better to move next lines in a function
                                    definitionTab.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                    definitionSearchText.text = suggest
                                    tabs.updateContext({'searchtext':definitionSearchText.text})
                                    definitionTab.canSuggest = true

                                    // start search of defintion
                                    definitionTab.doDefine()
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
                    // rectViewSuggestion.height = units.gu(2)
                    animateReduce.start()
                    rectViewSuggestion.expanded = false
                }
            }

            function expand() {
                // console.debug("EXPAND() : rectViewSuggestion.expanded="+rectViewSuggestion.expanded+" visible="+rectViewSuggestion.visible);
                if (rectViewSuggestion.expanded != true) {
                    // rectViewSuggestion.height = units.gu(20)
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
                rectViewSuggestion.visible = (definitionSearchText.text != "")
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
            id: definitionRes
            placeholderText: "<i>Definition</i>"
            textFormat : TextEdit.RichText
            enabled: true
            // anchors.top: listViewSuggestion.bottom
            anchors.top: definitionBtnLgSrc.bottom
            anchors.topMargin: units.gu(2)
            anchors.bottom: parent.bottom
            width: parent.width
        }

        LangSelector {
            id: langSelector
        }
    }

    Component.onCompleted: definitionSearchText.forceActiveFocus()

    function updateTabContext(context, startup) {
        if (typeof(startup) === "undefined")
            startup = false;
        definitionTab.canSuggest = false
        definitionSearchText.text = context['searchtext'];
        definitionTab.canSuggest = true
        definitionTab.setLang(context['lgsrc'])
        // 'lgdest':unused
        Controller.updateSuggestionModel(suggestModel, context['suggest'])
        definitionTab.doDefine(false)

        // TODO :
        // c'est ok pour le démarrage,
        // mais pas ok lors du changement de tab
        if (startup) {
            definitionTab.canSuggest = false
            definitionSearchText.forceActiveFocus()
            definitionTab.canSuggest = true
        } else {
            definitionSearchText.forceActiveFocus()
        }
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
        // if (definitionSearchText.focus == false)
        definitionSearchText.forceActiveFocus()
        rectViewSuggestion.visible = (definitionSearchText.text != "")
        // console.debug("rectViewSuggestion.visible="+rectViewSuggestion.visible)
        rectViewSuggestion.expand()
        Controller.doSuggest(definitionSearchText.text, lg, suggestModel, tabs)
    }

    function doDefine(focusRes) {
        if(typeof(focusRes) === "undefined")
            focusRes = true;
        var lg = definitionTab.langSrc;
        rectViewSuggestion.reduce()
        if (definitionSearchText.text != "")
            Controller.doSearchDefintion(definitionSearchText.text, lg, function (res) {
                definitionTab.setResult(res, focusRes)
            });
        else
            definitionTab.setResult("", focusRes)
    }

    function setResult(resultText, focusRes) {
        // console.debug("appel de definitionTab.setResult()");
        if (resultText == "") {
            definitionRes.text = "<i>No Result</i>";
        } else {
            definitionRes.text = "<h1>Definition of '"+definitionSearchText.text+"'</h1>"+resultText;
        }
        if (focusRes)
            definitionRes.forceActiveFocus();
    }
}
