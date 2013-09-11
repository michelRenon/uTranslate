/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
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
    applicationName: "uTranslate"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(48)
    height: units.gu(60)
    // anchors.fill: parent
    
    U1db.Database {
        id: utranslateDB
        path: "utranslateDB"
    }

    U1db.Document {
        id: dbContext
        database: utranslateDB
        docId: 'context'
        create: true
        defaults: { 'lgsrc': 'eng', 'lgdest': 'deu'}
    }

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
        /*
        ConfigurationTab {
            objectName: "configurationTab"
        }
        */
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

        Component.onCompleted: {
            // console.debug("tabs onCompleted")
            // Load searchContext from previous usage.
            var params = dbContext.contents;
            // console.debug("params="+Object.keys(params))
            setContext(params);
            tabs.selectedTab.updateTabContext(searchContext, true);
            tabs.loaded = true;
        }
    }

    Component {
        id: configSheetComponent
        DefaultSheet {
            id: configSheet
            title: i18n.tr("Settings")
            doneButton: true

            Column {

                Label {
                    text : "To Be Defined"
                }

                Label {
                    text : 'The current data provider is Glosbe (<a href="http://glosbe.com">http://glosbe.com</a>)'
                }
            }
            onDoneClicked: PopupUtils.close(configSheet)
        }
    }
}
