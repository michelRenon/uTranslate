/* This file is part of udefinition application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Ubuntu.Layouts 0.1

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
        
        Layouts {
            id: layouts
            anchors.fill: parent

            // onWidthChanged: console.debug("layouts layout.width="+layouts.width)

            layouts: [
                ConditionalLayout {
                    name: "2columns"
                    when: layouts.width > units.gu(80)

                    Item {
                        anchors.fill: parent

                        ItemLayout {
                            item: "itemSearchBar"
                            width: parent.width / 2 - units.gu(2)
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                left: parent.left
                            }
                            anchors.margins: units.gu(1)
                        }
                        ItemLayout {
                            item: "itemRes"
                            width: parent.width / 2
                            anchors {
                                top: parent.top
                                bottom: parent.bottom
                                right: parent.right
                            }
                        }
                        ItemLayout {
                            item: "itemSuggestion"
                            anchors {
                                top: parent.top
                                topMargin: units.gu(5)
                                left: parent.left
                                leftMargin: units.gu(8)
                                bottom: parent.bottom
                                bottomMargin: units.gu(1)
                            }
                            width: (parent.width / 2) - units.gu(9) // 8 from left, 1 from right
                        }
                    }
                }
            ]

            // default layout
            Item {
                id:definitionSearchBar
                Layouts.item: "itemSearchBar"
                anchors {
                    top: parent.top
                    left : parent.left
                    right: parent.right
                }
                height: definitionSearchText.height
                anchors.margins: units.gu(1)
                /*
                Rectangle {
                    anchors.fill: parent
                    color: "#cc5555"
                }
                */

                Button {
                    id:definitionBtnLgSrc
                    objectName: "LangSrc"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    width: units.gu(6)
                    height: definitionSearchText.height
                    text: ""
                    iconSource: "../graphics/ext/fra.png"
                    onClicked: PopupUtils.open(langSelectorComponent, definitionBtnLgSrc)
                }
                TextField {
                    id: definitionSearchText
                    anchors.left: definitionBtnLgSrc.right
                    anchors.right: definitionBtnSearch.left
                    anchors.top: parent.top
                    anchors.leftMargin: units.gu(1)
                    anchors.rightMargin: units.gu(1)
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
                        // console.debug("definitionSearchText.onFocusChanged="+definitionSearchText.focus);
                        definitionSearchText.updateSuggestList()
                    }

                    function updateSuggestList() {
                        var test = definitionTab.canSuggest;
                        test = test && definitionSearchText.focus;
                        test = test && definitionSearchText.text != "";
                        // console.debug("definitionSearchText.updateSuggestList test="+test+", visible="+rectViewSuggestion.visible);
                        if (test)
                            rectViewSuggestion.expand()
                        else
                            rectViewSuggestion.reduce()
                    }
                }
                Button {
                    id:definitionBtnSearch
                    // Layouts.item: "itemBtnSearch"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    // anchors.margins: units.gu(1)
                    width: units.gu(8)
                    height: definitionSearchText.height
                    text: "Search"
                    onClicked: definitionTab.doDefine()
                }


            }


            Rectangle {
                id: rectViewSuggestion
                Layouts.item: "itemSuggestion"
                z: layouts.currentLayout == "2columns" ? 0 : 1
                anchors.top: definitionSearchBar.bottom
                anchors.left: definitionSearchBar.left
                anchors.right: parent.right // definitionSearchText.right
                anchors.rightMargin: units.gu(1)
                anchors.leftMargin: units.gu(7) // 6+1
                height: units.gu(0) // ????
                border.color: "#aaaaaa"
                clip: true
                visible: true

                property bool expanded: false

                ListView {
                    id: listViewSuggestion
                    anchors.fill: parent
                    anchors.margins: units.gu(1)
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
                                    if (rectViewSuggestion.expanded || layouts.currentLayout == "2columns") {
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
                    if (layouts.currentLayout != "2columns" ) {
                        if (rectViewSuggestion.expanded != false) {
                            animateReduce.start()
                            rectViewSuggestion.expanded = false
                        }
                    }
                }

                function expand() {
                    // console.debug("EXPAND() : rectViewSuggestion.expanded="+rectViewSuggestion.expanded+" visible="+rectViewSuggestion.visible);
                    if (layouts.currentLayout != "2columns" ) {
                        if (rectViewSuggestion.expanded != true) {
                            animateExpand.start()
                            rectViewSuggestion.expanded = true
                        }
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
                id: definitionRes
                Layouts.item: "itemRes"
                placeholderText: "<i>Definition</i>"
                textFormat : TextEdit.RichText
                enabled: true
                anchors.top: definitionSearchBar.bottom
                anchors.topMargin: units.gu(1)
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }

            LangSelector {
                id: langSelectorComponent
            }

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
        if (startup || definitionSearchText.text === "") {
            /*
            // version :
            // - focus on search text,
            // - suggestion list is shown
            // - defintion search is done
            */
            definitionTab.doDefine(false);
            definitionSearchText.forceActiveFocus();
            definitionSearchText.updateSuggestList();

        } else {
            //*
            // version : focus on defintion
            definitionTab.doDefine(true)
            //*/
        }
    }

    function setLang(lg) {
        definitionTab.langSrc = lg;
        definitionBtnLgSrc.iconSource = "../graphics/ext/"+lg+".png";
    }

    function updateLang(lg) {
        definitionTab.setLang(lg);
        tabs.updateContext({'lgsrc': lg});
        definitionTab.doSuggest();
        // TODO : empty res ?
    }

    function doSuggest() {
        var lg = definitionTab.langSrc;
        definitionSearchText.forceActiveFocus();
        definitionSearchText.updateSuggestList()
        Controller.doSuggest(definitionSearchText.text, lg, suggestModel, tabs);
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
