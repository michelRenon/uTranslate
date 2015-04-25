/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem


Component {

    Popover {
        id: popLangSelector
        // mandatory with child listView
        contentHeight: langListView.height
        contentWidth: units.gu(30)
        focus: true

        property string lang :''

        ListView {
            id: langListView
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            height: units.gu(40)
            model: langUsedModel
            delegate: ListItem.Standard {
                text: i18n.tr(name)
                selected: caller.flag == code
                // iconSource: Qt.resolvedUrl("../graphics/ext/deu2.png")
                onClicked: {
                    popLangSelector.doSelectLang(code)
                }

            }
        }

        function doSelectLang(lg) {
            // console.debug("doSelectLang()"+lg)
            // We suppose that caller is a FlagButton, with 'flag' property.
            // But...
            // we need to delay the callback calling
            // and wait the popover's destruction.
            // This will prevent the popover to disturb any focus changes
            // on other widgets.
            // So the line (caller.flag = ...) is moved in onDestruction()
            popLangSelector.lang = lg;
            PopupUtils.close(popLangSelector)
            // popLangSelector.caller.flag = lg;
        }

        function loadUsedLangs() {
            console.debug("loadUsedLangs()");
            langUsedModel.clear();
            var langs = readUsedLangs();
            for(var i=0, l=langs.length ; i < l; i++) {
                langUsedModel.append(langs[i]);
                console.debug("loadUsedLangs   appended "+langs[i].name);
            }
        }

        ListModel {
            id:langUsedModel
        }

        Component.onCompleted: {
            loadUsedLangs()
        }

        Component.onDestruction: {
            console.debug("popover destroyed");
            popLangSelector.caller.flag = popLangSelector.lang;
        }
    }


}
