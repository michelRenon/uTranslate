/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 0.1
import Ubuntu.Layouts 0.1

import "components"
import "controller.js" as Controller


Page {
    // id: translationPage
    // title: i18n.tr("uTranslate")

    property bool startupMode: false
    property bool canSuggest: true
    property string langSrc : 'fra'
    property string langDest : 'eng'
    property int searchMode


    header: PageHeader {
        title: i18n.tr("uTranslate")

        leadingActionBar.actions: []

        trailingActionBar {
            actions : [
                Action {
                    id : switchAction
                    iconName: "switch"
                    text: i18n.tr("Switch")
                    enabled: (startupMode == false)
                    onTriggered: {
                        translationPage.doSwitchLg();
                    }
                },
                Action {
                    iconName: "settings"
                    text: i18n.tr("Settings")
                    enabled: (startupMode == false)
                    onTriggered: {
                        pageStack.push(settingsPage);
                    }
                },
                Action {
                    iconName: "info"
                    text: i18n.tr("About")
                    enabled: (startupMode == false)
                    onTriggered: {
                        pageStack.push(aboutPage);
                    }
                }
            ]
        }

        extension: Sections {
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                right: parent.right
                bottom: parent.bottom
            }
            enabled: (startupMode == false)

            model:[i18n.tr("Translation"), i18n.tr("Definition")]
            onSelectedIndexChanged: {
                // console.debug("DEBUG onSelectedIndexChanged : "+translationPage.head.sections.selectedIndex);
                // searchMode = translationPage.head.sections.selectedIndex;
                console.debug("DEBUG this onSelectedIndexChanged : "+this.selectedIndex);
                searchMode = this.selectedIndex;
            }
        }
    }




    /*
    head {

        actions : [
            Action {
                id : switchAction
                iconName: "switch"
                text: i18n.tr("Switch")
                enabled: (startupMode == false)
                onTriggered: {
                    translationPage.doSwitchLg();
                }
            },
            Action {
                iconName: "settings"
                text: i18n.tr("Settings")
                enabled: (startupMode == false)
                onTriggered: {
                    pageStack.push(settingsPage);
                }
            },
            Action {
                iconName: "info"
                text: i18n.tr("About")
                enabled: (startupMode == false)
                onTriggered: {
                    pageStack.push(aboutPage);
                }
            }
        ]

        sections {
            enabled: (startupMode == false)

            model:[i18n.tr("Translation"), i18n.tr("Definition")]
            onSelectedIndexChanged: {
                // console.debug("DEBUG onSelectedIndexChanged : "+translationPage.head.sections.selectedIndex);
                searchMode = translationPage.head.sections.selectedIndex;
            }
        }

    }
    */

    onWidthChanged: {
        // console.debug("Page layout.width="+layouts.width)
        // workaround because 'onLayoutsChanged' notification is not available
        translationPage.checkBadFocus();
    }

    onStartupModeChanged: {
        translationSearchBar.visible = !startupMode;
        startWizard.visible = startupMode;

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
            //
            // version :
            // - focus on search text,
            // - suggestion list is shown
            // - translation id done
            translationPage.doTranslate(false);
            translateSearchText.forceActiveFocus();
            translateSearchText.updateSuggestList();

        } else {
            //
            // version : focus on translation
            translationPage.doTranslate(true);
        }
    }

    Layouts {
        id: layouts
        // anchors.fill: parent
        anchors {
            top : parent.header.bottom
            left : parent.left
            right : parent.right
            bottom: parent.bottom
        }

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
                        item: "itemProgress"
                        width: parent.width / 2
                        height: units.dp(3)
                        anchors {
                            top: parent.top
                            left: parent.left
                        }
                        // anchors.margins: units.gu(1)
                        visible: true
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
                        visible: true
                    }
                    ItemLayout {
                        item: "itemRes"
                        width: parent.width /2 - units.gu(2)
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                            right: parent.right
                        }
                        anchors.margins: units.gu(1)
                        visible: true
                    }

                    ItemLayout {
                        item: "itemEmptyRes"
                        width: parent.width /2 - units.gu(2)
                        anchors {
                            right: parent.right

                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: units.gu(-15)
                        }
                        anchors.margins: units.gu(1)
                    }

                }
            }
        ]

        // default layout
        TaskProgressBar {
            id: idprogress
            Layouts.item: "itemProgress"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            // height: units.gu(0.5)
            visible: false
        }
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
            visible:true

            LangButton {
                id:translateBtnLgSrc
                objectName: "LangSrc"
                anchors.left: parent.left
                height: translateSearchText.height

                onLangChanged: {
                    console.debug("src.onFlagChanged");
                    console.debug("canSuggest="+translationPage.canSuggest+"   canNotify="+translateBtnLgSrc.canNotify);
                    if (translationPage.canSuggest && translateBtnLgSrc.canNotify)
                        translationPage.updateLang(lang)
                }

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
                inputMethodHints: Qt.ImhNoPredictiveText+Qt.ImhNoAutoUppercase


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
                    if (translationPage.canSuggest)
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
                    else {
                        rectViewSuggestion.reduceIfExpanded(force);
                    }
                }
            }
            LangButton {
                id:translateBtnLgDest
                objectName: "LangDest"
                anchors.right: parent.right
                anchors.top: parent.top
                height: translateSearchText.height

                onLangChanged:{
                    console.debug("dest.onFlagChanged")
                    if (translationPage.canSuggest && translateBtnLgDest.canNotify)
                        translationPage.updateLangDest(lang)
                }
            }
        }
        Rectangle {
            id: rectViewSuggestion
            Layouts.item: "itemSuggestion"
            z: layouts.currentLayout == "2columns" ? 0 : 1
            anchors.top: translationSearchBar.bottom
            anchors.left: translationSearchBar.left
            anchors.right: parent.right
            anchors.rightMargin: units.gu(1)
            anchors.leftMargin: units.gu(7)
            height: units.gu(0)
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

                    Label {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter

                        // fontSize: "medium"

                        // Add style to show searched letters
                        // TODO : enhance replace : case insensitive, nearby letters (eéèë...)
                        // TODO : check if perfs are ok ?
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

            function reduceIfExpanded(force) {
                if (rectViewSuggestion.expanded)
                    rectViewSuggestion.reduce(force);
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
            visible: true
        }
        EmptyState {
            id: emptyRes
            Layouts.item: "itemEmptyRes"
            iconName: "alarm-clock"
            title: ""
            subTitle: ""
            // anchors.centerIn: parent
            // anchors.top : parent.top
            // anchors.topMargin: units.gu(10)
            anchors.horizontalCenter: translateRes.horizontalCenter
            anchors.verticalCenter: translateRes.verticalCenter
            anchors.verticalCenterOffset: units.gu(-10)
            visible: false
        }
        /*
        TextArea {
            id: noResults
            // Layouts.item: "itemRes"
            placeholderText: "No results"
            textFormat : TextEdit.RichText
            readOnly: true
            anchors.top: translationSearchBar.bottom
            anchors.topMargin: units.gu(1)
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            visible: false
            z: 2
        }
        */
        Rectangle {
            id: startWizard
            Layouts.item: "no-item"
            visible: false
            color: "#dddddd"
            opacity: 1.0
            border.color: UbuntuColors.lightGrey // "#aaaaaa" // TODO : choose a Theme color

            anchors.fill: parent
            z: 3
            MouseArea {
                anchors.fill: parent

                onClicked: {
                    // Nothing.
                }
            }
            Icon {
                id: startWizardIcon
                anchors.top: parent.top
                anchors.topMargin: units.gu(5)
                anchors.horizontalCenter: parent.horizontalCenter
                height: units.gu(10)
                width: height
                color: "#BBBBBB"
                source: Qt.resolvedUrl("graphics/ext/welcome.png")
            }
            TextArea {
                id: startWizardText
                // Layouts.item: "itemRes"
                textFormat : TextEdit.RichText
                readOnly: true
                activeFocusOnPress:false
                anchors.top: startWizardIcon.bottom
                anchors.topMargin: units.gu(1)
                anchors.horizontalCenter: parent.horizontalCenter
                width : parent.width - units.gu(6)
                autoSize: true
                maximumLineCount:0
            }
            Button {
                text: i18n.tr("Language settings...")

                anchors.top: startWizardText.bottom
                anchors.topMargin: units.gu(3)
                width : parent.width - units.gu(6)
                anchors.horizontalCenter: parent.horizontalCenter

                iconName: "next"
                iconPosition: "right"
                onClicked: {
                    pageStack.push(langPage);
                    startupMode = false;
                }
            }
        }
        LangSelector {
            id: langSelectorComponent
        }
    }


    Component.onCompleted: translateSearchText.forceActiveFocus()

    function startWizard(localeName, foundLocale) {
        console.log("startWizard()")
        startupMode = true;

        // TRANSLATORS: it is a complete rich text like this : "Welcome!<br><br>uTranslate allows you to translate between 126 languages!<br>Please select those that you pefer to use by clicking on the next button."
        startWizardText.text = i18n.tr("welcome");

        // add a text to indicate the default lg selectec
        var temp = "";
        if (foundLocale === true) {
            // TRANSLATORS: it is a complete rich text like this : "The current langage is already selected : %1"
            temp = i18n.tr("locale_found");
        } else {
            // found no locale.
            // TRANSLATORS: it is a complete rich text like this : "Unfortunately, the phone's langage (%1) is not handled by our providers."
            startWizardText.text += i18n.tr("no_locale");
        }
        temp = temp.replace("%1", localeName);
        startWizardText.text += "<br><br>"+temp;
    }

    function updateTabContext(context, startup) {
        if (typeof(startup) === "undefined")
            startup = false;
        // console.debug("updateTabContext")
        translationPage.canSuggest = false;
        translateSearchText.text = context['searchtext'];
        translationPage.canSuggest = true;
        translationPage.setLang(context['lgsrc']);
        translationPage.setLangDest(context['lgdest']);

        if (startup || translateSearchText.text === "") {
            //
            // version :
            // - focus on search text,
            // - suggestion list is shown
            // - translation id done
            translationPage.doTranslate(false);
            translateSearchText.forceActiveFocus();
            translateSearchText.updateSuggestList();

        } else {
            //
            // version : focus on translation
            translationPage.doTranslate(true);
        }
    }

    function setLang(lg) {
        // console.debug("setLang:"+lg);
        translationPage.langSrc = lg;
        translateBtnLgSrc.setSource(lg);
    }

    function updateLang(lg) {
        console.debug("updateLang:"+lg);
        translationPage.setLang(lg);
        utApp.updateContext({'lgsrc': lg});
        translationPage.doSuggest();
        // console.debug("doSuggest DONE");

        // TODO : empty res ?
    }

    function setLangDest(lg) {
        // console.debug("setLangDest:"+lg);
        translationPage.langDest = lg;
        translateBtnLgDest.setSource(lg);
    }

    function updateLangDest(lg) {
        console.debug("updateLangdest:"+lg);
        translationPage.setLangDest(lg);
        utApp.updateContext({'lgdest': lg});
        translationPage.doTranslate();
        // TODO : suggest or translate ??
    }

    function updateSelectedLangs() {

        // update other parts of UI
        langPage.updateTitle();
        // the settings page
        settingsPage.updateLangInfos();

        // check if each langButton use a selected lang
        var langs = readUsedLangs();
        checkLang(langs, translationPage.langSrc, function(lg) {
            translationPage.setLang(lg);
            utApp.updateContext({'lgsrc': lg});

        });
        checkLang(langs, translationPage.langDest, function(lg) {
            translationPage.setLangDest(lg);
            utApp.updateContext({'lgdest': lg});
        });

    }

    function checkLang(langs, lang, cb) {
        // var found = langs.indexOf(lang);
        // 'langs' is not a real list

        var found = false;
        for(var i=0, l=langs.length ; i < l; i++) {
            if (langs[i]['code'] === lang)
                found = true;
        }

        if (found === false){
            // change the current lang to a selected one
            console.log("MUST CHANGE LANG "+lang);
            var newLang = "";
            if (langs.length > 0) {
                // change to the first selected lang
                newLang = langs[0]['code'];
            } else {
                newLang = "no_lang"; // No lang !
            }
            cb(newLang);
        }
    }

    function doSuggest() {
        idprogress.visible = true;
        var lgSrc = translationPage.langSrc;
        translateSearchText.forceActiveFocus();
        translateSearchText.updateSuggestList();
        Controller.doSuggest(translateSearchText.text, lgSrc, suggestModel, utApp, function() {idprogress.visible = false;});
    }

    function doTranslate(focusRes) {
        // console.debug("focusRes="+typeof(focusRes));
        if(typeof(focusRes) === "undefined")
            focusRes = true;
        var lgSrc = translationPage.langSrc;
        var lgDest = translationPage.langDest;
        var searchText = translateSearchText.text;
        rectViewSuggestion.reduceIfExpanded();
        if (searchText != "") {
            // console.debug("search Mode="+translationPage.searchMode);
            idprogress.visible = true;
            switch (translationPage.searchMode) {
                case 0: {
                    Controller.doSearchTranslation(translateSearchText.text, lgSrc, lgDest, function(res, error) {
                        translationPage.setResult(res, error, focusRes, searchText);
                    });
                    break;
                }

                case 1: {
                    Controller.doSearchDefintion(translateSearchText.text, lgSrc, function(res, error) {
                        translationPage.setResult(res, error, focusRes, searchText);
                    });
                    break;
                }
            }
        } else {
            translateSearchText.forceActiveFocus();
            focusRes = false;
            translationPage.setResult("", 0, focusRes, searchText);
        }
    }

    function setResult(resultText, error, focusRes, searchText) {
        // console.debug("appel de translationPage.setResult()"+error);
        var content = "";
        var showEmpty = false;
        var emptyIconName = "";
        var emptyTitle = ""
        var emptySubTitle = "";

        idprogress.visible = false;
        if (error == 0) {
            if (resultText == "") {
                // content = "<i>"+i18n.tr("No Result")+"</i>";
                if (searchText == "") {
                    showEmpty = true;
                    emptyIconName = "edit";
                    emptyTitle = i18n.tr("Enter text");
                    emptySubTitle = ""; // i18n.tr("");
                } else {
                    showEmpty = true;
                    emptyIconName = "dialog-question-symbolic";
                    emptyTitle = i18n.tr("No Result for '%1'").replace("%1", searchText);
                    emptySubTitle = i18n.tr("The provider doesn't know the word you entered");
                }
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
                message = message.replace("%1", searchText);
                content = "<h3>"+message+"</h3>"+resultText;
            }
        } else {
            // content = i18n.tr("A network error occured.");
            showEmpty = true;
            emptyIconName = "dialog-warning-symbolic";
            emptyTitle = i18n.tr("A network error occured.");
            emptySubTitle = i18n.tr("please check your network settings");
        }


        if (showEmpty){
            translateRes.visible = false;
            emptyRes.visible = true;
            emptyRes.iconName = emptyIconName;
            emptyRes.title = emptyTitle;
            emptyRes.subTitle = emptySubTitle;

        } else {
            translateRes.visible = true;
            emptyRes.visible = false;
            translateRes.text = content;
        }

        if (focusRes)
            translateRes.forceActiveFocus();
    }

    function doSwitchLg() {
        var lgSrc = translationPage.langSrc;
        var lgDest = translationPage.langDest;
        translationPage.canSuggest = false;

        translationPage.setLang(lgDest);
        utApp.updateContext({'lgsrc': lgDest});

        translationPage.setLangDest(lgSrc);
        utApp.updateContext({'lgdest': lgSrc});

        translationPage.canSuggest = true;

        // Update suggestions only in 2 colums layout.
        if (layouts.currentLayout == "2columns")
            translationPage.doSuggest();

        // Update results only if something to search.
        if (translateSearchText.text !== "")
            translationPage.doTranslate();
    }

    function checkBadFocus() {
        // TODO : check with layouts.currentLayout != "2columns"   ???
        if (layouts.width <= units.gu(80) && utApp.loaded) {
            if (translateSearchText.focus == false && translateRes.focus==false && translateSearchText.text === "") {
                // console.debug("CORRECTING FOCUS PB")
                translateSearchText.forceActiveFocus();
            }
        }
    }
}

