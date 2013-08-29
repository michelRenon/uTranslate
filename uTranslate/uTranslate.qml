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
    
    width: units.gu(100)
    height: units.gu(75)
    
    Tabs {
        id: tabs
        property var searchContext : {'searchtext': '', 'lgsrc': '', 'lgdest':'', 'suggest':''}

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
            console.debug ("onSelectedTabChanged="+tabs.selectedTab+" : "+tabs.selectedTab.objectName)
            if (tabs.selectedTab.objectName != "configurationTab") {
                tabs.selectedTab.setContext(searchContext)
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
    }
}
