import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Layouts 0.1
import U1db 1.0 as U1db

// import "ui"
import "controller.js" as Controller

// import ListModelJson 1.0
import "glosbe_lang.js" as GlosbeLang

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

    property var searchContext : {'searchtext': '', 'lgsrc': 'fra', 'lgdest': 'eng', 'suggest': []}

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
                    highlightWhenPressed: true
                    progression: true
                    onTriggered: Qt.openUrlExternally("http://glosbe.com")
                 }

                ListItem.Subtitled {
                     text : "7 available languages : "
                     subText: "German, Greek, English, French, Italian, Portuguese, Spanish"
                     showDivider: false
                     progression: true
                     highlightWhenPressed: true
                     onTriggered: {
                        pageStack.push(langPage)
                     }
                }

                ListItem.Empty{
                    showDivider: false
                    highlightWhenPressed: false
                }
                /*
                ListItem.Header {
                    text : i18n.tr("General")
                }

                ListItem.Standard {
                    text : i18n.tr("About")
                    iconName: "info"
                    // iconSource: Qt.resolvedUrl("graphics/uTranslate_64.png")
                    progression:true
                    // showDivider: false
                    onTriggered: {
                        pageStack.push(aboutPage)
                    }
                }
                */
            }
        }

        Page {
            id: aboutPage
            title: i18n.tr("About")
            visible: false

            // Item {
            Column {
                anchors.fill: parent
                spacing: units.gu(1)
                anchors.topMargin: units.gu(5)

                Image {
                    id: logo
                    source: Qt.resolvedUrl("graphics/uTranslate.png")
                    anchors.horizontalCenter: parent.horizontalCenter
                    // antialiasing: true
                }
                Label {
                    id: info1
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("uTranslate, a translation app")
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info2
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("by ")+"<a href='http://www.mr-consultant.net/blog/'>Michel Renon</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    id: info3
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("version ")+"0.4"
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info4
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "GPLv3"
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info5
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Project website: ")+"<br><a href='https://github.com/michelRenon/uTranslate'>https://github.com/michelRenon/uTranslate</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    id: info6
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Flags form ")+"<a href='http://commons.wikimedia.org/wiki/Drapeaux'>Wikimedia Commons</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }

            }
        }

        Page {
            id: langPage
            title: i18n.tr("Languages")
            visible: false

            ListView {

                ListModelJson {
                    liste: GlosbeLang.glosbe_lang_array
                    id: langListModel
                }

                anchors.fill: parent

                model: langListModel.model

                delegate: ListItem.Standard {
                    // Both "name" and "team" are taken from the model
                    text: i18n.tr(name) +" ("+code+")"
                    // iconSource: Qt.resolvedUrl(icon_path)
                    // fallbackIconSource: Qt.resolvedUrl("graphics/uTranslate.png")
                    control: Switch {
                        checked: false
                        // text: "Click me"
                        // width: units.gu(19)
                        onClicked: print("switch : "+code+" Clicked")
                    }
                    onClicked: console.debug("listItem clicked")

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

            console.debug("GlosbeLang="+GlosbeLang.glosbe_lang_array);
        }
        /*
        ListModel {
            id: langListModel
            ListElement {
                code:"deu"
                name: "german"
                icon_path: "graphics/ext/deu2.png"
            }
            ListElement {
                code:"ell"
                name: "greek"
                icon_path: "graphics/ext/ell2.png"
            }
            ListElement {
                code:"eng"
                name: "english"
                icon_path: "graphics/ext/eng2.png"
            }
            ListElement {
                code:"fra"
                name: "french"
                icon_path: "graphics/ext/fra2.png"
            }
            ListElement {
                code:"ita"
                name: "italian"
                icon_path: "graphics/ext/ita2.png"
            }
            ListElement {
                code:"por"
                name: "portugese"
                icon_path: "graphics/ext/por2.png"
            }
            ListElement {
                code:"spa"
                name: "spanish"
                icon_path: "graphics/ext/spa2.png"
            }
        }
        */
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

