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

/*

  TODO :

  reprendre la création d'un environneemnt de dev correct
  (cf video de Nekelesh)
  pour pouvoir tester sur emulateur

  changer le nom de l'application : Translate
  (voir les conséquences sur le store, faut-il refaire un projet ?)


  gérer les langues par leur Code, drapeau en option

  gérer les traductions


  voir comment enlever le contour arrondi des textes



  DONE

  pour gerer le pb de la correction automatique qui gene la recherche instantanée :
  file:///usr/share/ubuntu-ui-toolkit/doc/html/qml-ubuntu-components-textfield.html
  inputMethodHints :
- Qt.ImhNoPredictiveText - Do not use predictive text (i.e. dictionary lookup) while typing.


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


                    ListItem.Subtitled {
                         text : "7 selected languages : "
                         subText: "German, Greek, English, French, Italian, Portuguese, Spanish"
                         progression:true
                         onTriggered: {
                             pageStack.push(langPage)
                         }
                    }

                    ListItem.Header {
                        text : i18n.tr("General")
                    }

                    ListItem.SingleValue {
                        text : i18n.tr("About")
                        iconSource: Qt.resolvedUrl("./graphics/uTranslate_64.png")
                        progression:true
                        onTriggered: {
                            pageStack.push(aboutPage)
                        }
                    }

                    // for debug purpose
                    ListItem.SingleValue {
                        text : "locale : "+i18n.language
                    }

                }
            }
        }
        Component {
            id: langPage
            Page {
                title: i18n.tr("Languages")
                ListView {
                    anchors.fill: parent

                    model: langListModel

                    delegate: ListItem.Standard {
                        // Both "name" and "team" are taken from the model
                        text: i18n.tr(name)  +" ("+code+")"
                        iconSource: Qt.resolvedUrl(icon_path)
                        control: Switch {
                            checked: true
                            enabled: false
                            // onClicked: print("switch : "+parent.text+" Clicked")
                        }
                    }
                }
            }
            /*
            */
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
                        text: "uTranslate by Michel Renon<br>http://www.mr-consultant.net/blog/<br>version 0.3.0<br>GPLv3<br><br>Flags form Wikimedia Commons<br>http://commons.wikimedia.org/wiki/Drapeaux"
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

        ListModel {
            id: langListModel
            ListElement {
                code:"deu"
                name: "german"
                icon_path: "./graphics/ext/deu2.png"
            }
            ListElement {
                code:"ell"
                name: "greek"
                icon_path: "./graphics/ext/ell2.png"
            }
            ListElement {
                code:"eng"
                name: "english"
                icon_path: "./graphics/ext/eng2.png"
            }
            ListElement {
                code:"fra"
                name: "french"
                icon_path: "./graphics/ext/fra2.png"
            }
            ListElement {
                code:"ita"
                name: "italian"
                icon_path: "./graphics/ext/ita2.png"
            }
            ListElement {
                code:"por"
                name: "portugese"
                icon_path: "./graphics/ext/por2.png"
            }
            ListElement {
                code:"spa"
                name: "spanish"
                icon_path: "./graphics/ext/spa2.png"
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
