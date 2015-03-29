/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Layouts 0.1

import "../components"
import "../controller.js" as Controller


Page {
    // id: translationPage
    title: i18n.tr("uTranslate")

    property bool canSuggest: false
    property string langSrc : 'fra'
    property string langDest : 'eng'
    property int searchMode : 0 // translation

    head {
        actions : [
            Action {
                id : switchAction
                iconSource: Qt.resolvedUrl("../graphics/switch.png")
                text: i18n.tr("Switch")
                onTriggered: {
                    translationPage.doSwitchLg();
                }
            },
            Action {
                iconSource: Qt.resolvedUrl("../graphics/settings.png")
                text: i18n.tr("Settings")
                onTriggered: {
                    pageStack.push(settingsPage);
                }
            }
        ]

        sections {
            model:[i18n.tr("Translation"), i18n.tr("Definition")]
            // onSelectedIndexChanged: console.log("DEBUG onSelectedIndexChanged : "+translatePage.head.sections.selectedIndex)
            onSelectedIndexChanged: {
                console.debug("DEBUG onSelectedIndexChanged : "+translationPage.head.sections.selectedIndex);
                searchMode = translationPage.head.sections.selectedIndex;
            }
        }

    }

    onWidthChanged: {
        // console.debug("Page layout.width="+layouts.width)
        // workaround because 'onLayoutsChanged' notification is not available
        translationPage.checkBadFocus();
    }

    onSearchModeChanged: {
        // UI updates
        switch (translationPage.searchMode) {
            case 0: {
                // show switch icon
                switchAction.visible = true;
                // show lgDest button
                translateBtnLgDest.visible = true;
                break;
            }

            case 1: {
                // hide switch icon
                switchAction.visible = false;
                // hide lgDest button
                translateBtnLgDest.visible = false;

                break;
            }
        }

        if (translateSearchText.text === "") {
            /*
            // version :
            // - focus on search text,
            // - suggestion list is shown
            // - translation id done
            */
            translationPage.doTranslate(false);
            translateSearchText.forceActiveFocus();
            translateSearchText.updateSuggestList();

        } else {
            // *
            // version : focus on translation
            translationPage.doTranslate(true);
            // */
        }
    }

    Layouts {
        id: layouts
        anchors.fill: parent

        // TODO : handle focus change after layout change.
        // But today, 'onLayoutsChanged' generates an error in qmlscene.
        // onLayoutsChanged: console.debug("TR LAYOUT changed="+currentLayout)

        layouts: [
            ConditionalLayout {
                name: "2columns"
                when: layouts.width > units.gu(80)

                // onLayoutChanged: console.debug("TR LAYOUT changed="+layouts.currentLayout)

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
                        width: parent.width /2
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
            id:translationSearchBar
            Layouts.item: "itemSearchBar"
            anchors {
                top: parent.top
                left : parent.left
                right: parent.right
            }
            height: translateSearchText.height
            anchors.margins: units.gu(1)
            /*
            Rectangle {
                anchors.fill: parent
                color: "#cc5555"
            }
            */


            FlagButton {
                id:translateBtnLgSrc
                objectName: "LangSrc"
                anchors.left: parent.left
                height: translateSearchText.height

                onFlagChanged:
                    translationPage.updateLang(flag)

            }
            TextField {
                id: translateSearchText
                anchors.left: translateBtnLgSrc.right
                anchors.right: translateBtnLgDest.left
                anchors.top: parent.top
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                placeholderText: i18n.tr("Enter text to translate")
                hasClearButton: true
                inputMethodHints: Qt.ImhNoPredictiveText

                onAccepted: {
                    // console.debug("onAccepted:'"+translateSearchText.text+"'")
                    utApp.updateContext({'searchtext':translateSearchText.text})
                    translationPage.doTranslate()
                }

                onTextChanged: {
                    // console.debug("text changed='"+translateSearchText.text+"', "+translationPage.canSuggest)
                    if (translationPage.canSuggest) {
                        utApp.updateContext({'searchtext':translateSearchText.text})
                        translationPage.doSuggest()
                    }
                }

                onFocusChanged: {
                    // console.debug("onFocusChanged="+translateSearchText.focus);
                    translateSearchText.updateSuggestList();
                }

                function updateSuggestList(force) {
                    if (typeof(force) === "undefined")
                        force = false
                    var test = translationPage.canSuggest;
                    test = test && translateSearchText.focus;
                    test = test && translateSearchText.text != "";
                    // console.debug("translateSearchText.updateSuggestList test="+test+", visible="+rectViewSuggestion.visible);
                    if (test)
                        rectViewSuggestion.expand(force)
                    else
                        rectViewSuggestion.reduce(force)
                }
            }
            FlagButton {
                id:translateBtnLgDest
                objectName: "LangDest"
                anchors.right: parent.right
                anchors.top: parent.top
                height: translateSearchText.height

                onFlagChanged:
                    translationPage.updateLangDest(flag)

            }
        }
        Rectangle {
            id: rectViewSuggestion
            Layouts.item: "itemSuggestion"
            z: layouts.currentLayout == "2columns" ? 0 : 1
            anchors.top: translationSearchBar.bottom
            anchors.left: translationSearchBar.left
            anchors.right: parent.right // definitionSearchText.right
            anchors.rightMargin: units.gu(1)
            anchors.leftMargin: units.gu(7) // 6+1
            height: units.gu(0) // ????
            border.color: "#aaaaaa" // TODO : choose a Theme color
            clip: true
            visible: true

            property bool expanded: false
            property int reducedHeight: 0
            property int expandedHeight:30

            ListView {
                id: listViewSuggestion
                anchors.fill: parent
                anchors.margins: units.gu(1)
                model: suggestModel
                clip: true

                delegate: Rectangle {
                    id:bgColor
                    width: ListView.view.width
                    height: units.gu(3)
                    // border.color: "#888"
                    // border.width: 1

                    Label {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter

                        // fontSize: "medium"

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

                            onPressed:{
                                // console.debug("PRESS")
                                // bgColor.color = Theme.palette.selected.fieldText
                                bgColor.color = UbuntuColors.orange
                                parent.color = Theme.palette.selected.foregroundText
                            }

                            onCanceled: {
                                // console.debug("CANCELED")
                                bgColor.color = "white"
                                parent.color = Theme.palette.normal.baseText
                            }

                            onReleased: {
                                // console.debug("RELEASE")
                                // bgColor.color = Theme.palette.normal.fieldText
                                bgColor.color = "white"
                                parent.color = Theme.palette.normal.baseText
                            }

                            onClicked: {
                                if (rectViewSuggestion.expanded || layouts.currentLayout == "2columns") {
                                    // TODO : check if it'd be better to move next lines in a function
                                    translationPage.canSuggest = false // TODO : aks users if it'd be better to update list of suggestions
                                    translateSearchText.text = suggest
                                    utApp.updateContext({'searchtext':translateSearchText.text})
                                    translationPage.canSuggest = true


                                    // start translation
                                    translationPage.doTranslate()
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

            function reduce(force) {
                if (typeof(force) === "undefined")
                    force = false
                if (layouts.currentLayout != "2columns" ) {
                    if (rectViewSuggestion.expanded != false || force) {
                        animateReduce.start()
                        rectViewSuggestion.expanded = false
                    }
                }
            }

            function expand(force) {
                if (typeof(force) === "undefined")
                    force = false
                // console.debug("EXPAND() : rectViewSuggestion.expanded="+rectViewSuggestion.expanded+" visible="+rectViewSuggestion.visible);
                if (layouts.currentLayout != "2columns" ) {
                    if (rectViewSuggestion.expanded != true || force) {
                        animateExpand.start()
                        rectViewSuggestion.expanded = true
                    }
                }
            }

            NumberAnimation {
                id: animateReduce
                target: rectViewSuggestion
                properties: "height"
                from: units.gu(rectViewSuggestion.expandedHeight)
                to: units.gu(rectViewSuggestion.reducedHeight)
                duration: UbuntuAnimation.FastDuration
            }

            NumberAnimation {
                id: animateExpand
                target: rectViewSuggestion
                properties: "height"
                from: units.gu(rectViewSuggestion.reducedHeight)
                to: units.gu(rectViewSuggestion.expandedHeight)
                duration: UbuntuAnimation.FastDuration
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
            id: translateRes
            Layouts.item: "itemRes"
            placeholderText: "<i>Translations</i>"
            textFormat : TextEdit.RichText
            readOnly: true
            anchors.top: translationSearchBar.bottom
            anchors.topMargin: units.gu(1)
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
        }

        LangSelector {
            id: langSelectorComponent
        }
    }


    Component.onCompleted: translateSearchText.forceActiveFocus()

    function updateTabContext(context, startup) {
        if (typeof(startup) === "undefined")
            startup = false;
        // console.debug("updateTabContext")
        translationPage.canSuggest = false;
        translateSearchText.text = context['searchtext'];
        translationPage.canSuggest = true;
        translationPage.setLang(context['lgsrc']);
        translationPage.setLangDest(context['lgdest']);

        // TODO : a garder ????
        Controller.updateSuggestionModel(suggestModel, context['suggest']);
        if (startup || translateSearchText.text === "") {
            /*
            // version :
            // - focus on search text,
            // - suggestion list is shown
            // - translation id done
            */
            translationPage.doTranslate(false);
            translateSearchText.forceActiveFocus();
            translateSearchText.updateSuggestList();

        } else {
            // *
            // version : focus on translation
            translationPage.doTranslate(true);
            // */
        }
    }

    function setLang(lg) {
        translationPage.langSrc = lg;
        translateBtnLgSrc.setSource("../graphics/ext/"+lg+".png");
    }

    function updateLang(lg) {
        translationPage.setLang(lg);
        utApp.updateContext({'lgsrc': lg});
        translationPage.doSuggest();
        // TODO : empty res ?
    }

    function setLangDest(lg) {
        translationPage.langDest = lg;
        translateBtnLgDest.setSource("../graphics/ext/"+lg+".png");
    }

    function updateLangDest(lg) {
        translationPage.setLangDest(lg);
        utApp.updateContext({'lgdest': lg});
        translationPage.doTranslate();
        // TODO : suggest or translate ??
    }

    function doSuggest() {
        var lgSrc = translationPage.langSrc;
        translateSearchText.forceActiveFocus();
        translateSearchText.updateSuggestList();
        Controller.doSuggest(translateSearchText.text, lgSrc, suggestModel, utApp);
    }

    function doTranslate(focusRes) {
        // console.debug("focusRes="+typeof(focusRes));
        if(typeof(focusRes) === "undefined")
            focusRes = true;
        var lgSrc = translationPage.langSrc;
        var lgDest = translationPage.langDest;
        rectViewSuggestion.reduce();
        if (translateSearchText.text != "") {
            console.debug("search Mode="+translationPage.searchMode);
            switch (translationPage.searchMode) {
                case 0: {
                    Controller.doSearchTranslation(translateSearchText.text, lgSrc, lgDest, function(res, error) {
                        translationPage.setResult(res, error, focusRes);
                    });
                    break;
                }

                case 1: {
                    Controller.doSearchDefintion(translateSearchText.text, lgSrc, function(res, error) {
                        translationPage.setResult(res, error, focusRes);
                    });
                    break;
                }
            }
        } else
            translationPage.setResult("", 0, focusRes);
    }

    function setResult(resultText, error, focusRes) {
        // console.debug("appel de translationPage.setResult()"+error);
        var content = "";
        if (error == 0) {
            if (resultText == "") {
                content = "<i>"+i18n.tr("No Result")+"</i>";
            } else {
                var message = "";
                switch (translationPage.searchMode) {
                    case 0: {
                        message = i18n.tr("Translation of '%1'");
                        break;
                    }
                    case 1:{
                        message = i18n.tr("Definition of '%1'");
                        break;
                    }
                }
                message = message.replace("%1", translateSearchText.text);
                content = "<h3>"+message+"</h3>"+resultText;
            }
        } else {
            content = i18n.tr("A network error occured.");
        }
        translateRes.text = content;

        if (focusRes)
            translateRes.forceActiveFocus();
    }

    function doSwitchLg() {
        var lgSrc = translationPage.langSrc;
        var lgDest = translationPage.langDest;
        translationPage.setLang(lgDest);
        utApp.updateContext({'lgsrc': lgDest});

        translationPage.setLangDest(lgSrc);
        utApp.updateContext({'lgdest': lgSrc});

        translationPage.doSuggest();
        // translationPage.doTranslate();
    }

    function checkBadFocus() {
        if (layouts.width <= units.gu(80) && utApp.loaded) {
            if (translateSearchText.focus == false && translateRes.focus==false) {
                // console.debug("CORRECTING FOCUS PB")
                translateSearchText.forceActiveFocus();
                translateSearchText.updateSuggestList(true);
            }
        }
    }
}

