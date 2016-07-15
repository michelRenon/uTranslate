/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
// import Ubuntu.Components.ListItems 0.1 as ListItem


Component {

    Popover {
        id: popLangSelector
        // mandatory with child listView
        contentHeight: langListView.height
        contentWidth: units.gu(30)
        focus: true

        property string lang :'--'

        ListView {
            id: langListView
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }

            height: units.gu(40)
            model: langUsedModel
            delegate: ListItem {
                ListItemLayout {
                    id: layout
                    title.text: name
                }
                /*
                Label {
                    text: name
                    anchors {
                        left: parent.left
                        leftMargin: units.gu(1)
                        verticalCenter: parent.verticalCenter
                    }
                    // style: (code == 'settings') ? Text.Outline : Text.Normal

                }
                */

                // TODO : change style of link to lang settings.
                // Can be done only with new ListItem, Ubuntu.Components 1.2, framework 15.04
                // http://developer.ubuntu.com/api/apps/qml/sdk-15.04/Ubuntu.Components.ListItem/

                selected: caller.flag === code

                // TODO : show optionnal flag as icon
                // iconSource: Qt.resolvedUrl("../graphics/ext/deu2.png")

                onClicked: {
                    if (code === 'settings') {
                        PopupUtils.close(popLangSelector);
                        pageStack.push(langPage);
                    } else
                        popLangSelector.doSelectLang(code);
                }

            }
        }

        function doSelectLang(lg) {
            console.debug("doSelectLang()"+lg)
            // We suppose that caller is a FlagButton, with 'flag' property.
            // But...
            // we need to delay the callback calling
            // and wait the popover's destruction.
            // This will prevent the popover to disturb any focus changes
            // on other widgets.
            // So the line (caller.lang = ...) is moved in onDestruction()
            popLangSelector.lang = lg;
            PopupUtils.close(popLangSelector);
            // popLangSelector.caller.lang = lg;
        }

        ListModel {
            id:langUsedModel
        }

        Component.onCompleted: {
            // console.debug("popLangSelector onCompleted");
            loadUsedLangs(langUsedModel);
            langUsedModel.append({name:i18n.tr("Language settings..."), code:'settings', flag:'--'});
        }

        Component.onDestruction: {
            console.debug("popover destroyed");
            // console.debug(popLangSelector.caller);
            if (popLangSelector.lang !== '--') {
                console.debug("change lang:"+popLangSelector.lang);
                popLangSelector.caller.lang = popLangSelector.lang;
            }
        }
    }
}
