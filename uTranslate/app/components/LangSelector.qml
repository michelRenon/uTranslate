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
            delegate: ListItem.Standard {
                // text: i18n.tr(name)
                text: name

                // TODO : voir comment afficher différemment le lien vers la page de langues
                // avec le nouveau ListItem, Ubuntu.Components 1.2, framework 15.04
                // http://developer.ubuntu.com/api/apps/qml/sdk-15.04/Ubuntu.Components.ListItem/

                selected: caller.flag === code
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
            // console.debug("doSelectLang()"+lg)
            // We suppose that caller is a FlagButton, with 'flag' property.
            // But...
            // we need to delay the callback calling
            // and wait the popover's destruction.
            // This will prevent the popover to disturb any focus changes
            // on other widgets.
            // So the line (caller.flag = ...) is moved in onDestruction()
            popLangSelector.lang = lg;
            PopupUtils.close(popLangSelector);
            // popLangSelector.caller.flag = lg;
        }

        ListModel {
            id:langUsedModel
        }

        Component.onCompleted: {
            console.debug("popLangSelector onCompleted");
            // console.debug(popLangSelector.caller);
            // console.debug(caller);
            // popLangSelector.lang = popLangSelector.caller.flag;
            loadUsedLangs(langUsedModel);

            langUsedModel.append({name:i18n.tr("Language settings..."), code:'settings', flag:'--'});
        }

        Component.onDestruction: {
            // console.debug("popover destroyed");
            // console.debug(popLangSelector.caller);
            if (popLangSelector.lang !== '--') {
                // console.debug("change lang:"+popLangSelector.lang);
                popLangSelector.caller.flag = popLangSelector.lang;
            }
        }
    }
}
