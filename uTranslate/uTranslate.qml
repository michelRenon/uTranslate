/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
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

        ConfigurationTab {
            objectName: "configurationTab"
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
            // console.debug("TABS : new params="+params)
            for (var param in params) {
                searchContext[param] = params[param]
                // console.debug("p:"+param+" = "+params[param])
            }
        }

        Component.onCompleted: {
            // TODO : load searchContext from previous usage
            console.debug("tabs onCompleted")
            tabs.selectedTab.updateTabContext(searchContext, true);
            tabs.loaded = true;
        }
    }
}
