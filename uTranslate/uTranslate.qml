/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Layouts 0.1
import U1db 1.0 as U1db

import "ui"
import "controller.js" as Controller

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/



MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename 
    applicationName: "com.ubuntu.developer.mrenon.utranslate"
    
    // This property enables the application to change orientation
    //  when the device is rotated. The default is false.
    automaticOrientation: true

    // no more old toolbar, let's use new header !
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

    PageStack {
        id: pageStack

        Tabs {
            id: tabs
            property var searchContext : {'searchtext': '', 'lgsrc': 'fra', 'lgdest': 'eng', 'suggest': ''}

            property bool loaded: false

            TranslationTab {
                objectName: "translationTab"
            }

            DefinitionTab {
                objectName: "definitionTab"
            }

            onSelectedTabChanged: {
                if (tabs.loaded) {
                    console.debug ("onSelectedTabChanged="+tabs.selectedTab+" : "+tabs.selectedTab.objectName)
                    if (tabs.selectedTab.objectName != "configurationTab") {
                        tabs.selectedTab.updateTabContext(searchContext)
                    }
                }
            }

            onSelectedTabIndexChanged: {
                // index are 0-based
                // console.debug("onSelectedTabIndexChanged="+tabs.selectedTabIndex+", tabs="+tabs.__tabs)
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

        Component {
            id: settingsPage

            Page {
                title: i18n.tr("Settings")

                Column {
                    anchors.fill: parent
                    spacing: units.gu(2)

                    ListItem.Header {
                        text : i18n.tr("Providers")
                    }

                    ListItem.Standard {
                        text : 'The current data provider is Glosbe (<a href="http://glosbe.com">http://glosbe.com</a>)'
                     }

                    ListItem.Header {
                        text : i18n.tr("Languages")
                    }

                    ListItem.Subtitled {
                         text : "7 available languages : "
                         subText: "German, Greek, English, French, Italian, Portuguese, Spanish"
                         progression: false
                    }


                    ListItem.SingleValue {
                        text : i18n.tr("About")
                        progression:true
                        onTriggered: {
                            pageStack.push(aboutPage)
                        }
                    }
                }
                /*
                tools: ToolbarItems {
                    locked: true
                    opened: true // TODO : API change --> open()
                }
                */
            }
        }

        Component {
            id: aboutPage

            Page {
                title: i18n.tr("About")

                Item {
                    anchors.fill: parent

                    Image {
                        id: logo
                        source: "./graphics/uTranslate.png"
                        width: units.gu(16)
                        height: units.gu(16)
                        anchors.top: parent.top
                        anchors.topMargin: units.gu(5)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id:info
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: logo.bottom
                        anchors.topMargin: units.gu(2)
                        text: "uTranslate by Michel Renon<br>
http://www.mr-consultant.net/blog/<br>version 0.2.3<br>GPLv3<br><br>
Flags form Wikimedia Commons<br>
http://commons.wikimedia.org/wiki/Drapeaux"
                        textFormat : TextEdit.RichText
                        enabled: false
                        color: "#888"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                tools: ToolbarItems {
                    locked: true
                    opened: true // TODO : API change --> open()
                }
            }
        }

        onCurrentPageChanged: {
            // console.debug("current page="+pageStack.currentPage);
            if (pageStack.currentPage == tabs){
                tabs.selectedTab.checkBadFocus()
            }
        }

        Component.onCompleted:  {
            // console.debug("PAGESTACK completed")
            pageStack.push(tabs)

            // Load searchContext from previous usage.
            var params = dbContext.contents;

            // console.debug("onCompleted params="+Object.keys(params))
            // console.debug("onCompleted params="+params['lgsrc']+":"+params['lgdest'])
            tabs.setContext(params);
            tabs.selectedTab.updateTabContext(tabs.searchContext, true);
            tabs.loaded = true;
        }
    }
}
