import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Layouts 0.1
import U1db 1.0 as U1db

// import "ui"
import "controller.js" as Controller


/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    id:utApp

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "utranslate.mrenon"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(48)
    height: units.gu(60)

    U1db.Database {
        id: utranslateDB
        path: "utranslate.db"
    }

    U1db.Document {
        id: dbContext
        database: utranslateDB
        docId: 'context'
        create: true
        defaults: { 'lgsrc': 'eng', 'lgdest': 'deu'}
    }

    U1db.Document {
        id: adoc
        database: utranslateDB
    }

    property var pageStack: pageStack

    property var searchContext : {'searchtext': '', 'lgsrc': 'fra', 'lgdest': 'eng', 'suggest': ''}

    property bool loaded: false


    PageStack {
        id: pageStack

        TranslationPage{
            id: translationPage
            visible: false
        }

        Page {
            id: settingsPage
            title: i18n.tr("Settings")
            visible: false

            Column {
                anchors.fill: parent
                spacing: units.gu(0)

                ListItem.Header {
                    text : i18n.tr("Providers")
                }

                ListItem.Subtitled {
                    text : 'The current data provider is Glosbe'
                    subText: '(<a href="http://glosbe.com">http://glosbe.com</a>)'
                    showDivider: false
                    highlightWhenPressed: false
                    // TODO : onTrigerred : open url with browser through contentHub
                 }

                ListItem.Subtitled {
                     text : "7 available languages : "
                     subText: "German, Greek, English, French, Italian, Portuguese, Spanish"
                     showDivider: false
                     progression: false
                     highlightWhenPressed: false
                }

                ListItem.Empty{
                    showDivider: false
                    highlightWhenPressed: false
                }

                ListItem.Header {
                    text : i18n.tr("General")
                }

                ListItem.Standard {
                    text : i18n.tr("About")
                    iconSource: Qt.resolvedUrl("graphics/uTranslate_64.png")
                    progression:true
                    // showDivider: false
                    onTriggered: {
                        pageStack.push(aboutPage)
                    }
                }

                ListItem.Standard {
                    text : i18n.tr("TEST")
                    progression:true
                    // showDivider: false
                    onTriggered: {
                        pageStack.push(testPage)
                    }
                }
            }
        }

        Page {
            id: aboutPage
            title: i18n.tr("About")
            visible: false

            Item {
                anchors.fill: parent

                Image {
                    id: logo
                    source: Qt.resolvedUrl("graphics/uTranslate.png")
                    // width: units.gu(16)
                    // height: units.gu(16)
                    anchors.top: parent.top
                    anchors.topMargin: units.gu(5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    // antialiasing: true
                }
                Text {
                    id:info
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: logo.bottom
                    anchors.topMargin: units.gu(2)
                    text: "uTranslate by Michel Renon<br>
http://www.mr-consultant.net/blog/<br>version 0.3<br>GPLv3<br>
https://github.com/michelRenon/uTranslate<br><br>
Flags form Wikimedia Commons<br>
http://commons.wikimedia.org/wiki/Drapeaux"
                    textFormat : TextEdit.RichText
                    enabled: false
                    color: "#888"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Page {
            id: testPage
            title: i18n.tr("TEST")
            visible: false

            ListModel {
                id:countryModel

                ListElement {
                    code:"lg1"
                    name:"lang1"
                    flag: "graphics/ext/deu2.png"

                }
                ListElement {
                    code:"lg2"
                    name:"lang2"
                    flag: "graphics/ext/ell2.png"
                }
                ListElement {
                    code:"lg3"
                    name:"lang3"
                    flag: "graphics/ext/eng2.png"
                }
                ListElement {
                    code:"lg4"
                    name:"lang4"
                    flag: "graphics/ext/fra2.png"
                }
                ListElement {
                    code:"lg5"
                    name:"lang5"
                    flag: "graphics/ext/ita2.png"
                }
                ListElement {
                    code:"lg6"
                    name:"lang6"
                    flag: "graphics/ext/por2.png"
                }
                ListElement {
                    code:"lg7"
                    name:"lang7"
                    flag: "graphics/ext/spa2.png"
                }
                ListElement {
                    code:"lg8"
                    name:"lang8"
                    flag: "graphics/ext/usa2.png"
                }
            }

            GridView {
                id: testGrid
                anchors.fill: parent
                cellWidth: parent.width / 6

                model:countryModel

                delegate: Column {
                    width: testGrid.cellWidth
                    height: testGrid.cellHeight

                    Image {
                        width: units.gu(5)
                        height: units.gu(5)
                        source: Qt.resolvedUrl(flag)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: name
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        onCurrentPageChanged: {
            // console.debug("current page="+pageStack.currentPage);
            if (pageStack.currentPage == translationPage){
                translationPage.checkBadFocus()
            }
        }

        Component.onCompleted:  {
            // console.debug("PAGESTACK completed")
            pageStack.push(translationPage)

            // Load searchContext from previous usage.
            var params = dbContext.contents;

            // console.debug("onCompleted params="+Object.keys(params))
            // console.debug("onCompleted params="+params['lgsrc']+":"+params['lgdest'])
            utApp.setContext(params);
            translationPage.updateTabContext(utApp.searchContext, true);
            utApp.loaded = true;
        }
    }


    function updateContext(params) {
        setContext(params);
        // store some params in u1db
        saveDb();
    }

    function setContext(params) {
        // console.debug("TABS : new params="+params)
        for (var param in params) {
            searchContext[param] = params[param]
            // console.debug("p:"+param+" = "+params[param])
        }
    }

    function saveDb() {
        var temp = {};
        temp['lgsrc'] = searchContext['lgsrc'];
        temp['lgdest'] = searchContext['lgdest'];
        dbContext.contents = temp;
    }
}

