/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    // id: langPage
    title: langPage.getTitle()

    head {
        actions : [
            Action {
                id : switchAction
                iconName: "select"
                text: i18n.tr("Show selected")
                onTriggered: {
                    console.debug("show selected")
                    // TODO
                }
            }
        ]
    }

    ListView {
        /*
        ListModelJson {
            liste: GlosbeLang.glosbe_lang_array
            id: langListModel
        }
        */
        anchors.fill: parent

        // model: langListModel.model
        model: langListModel

        delegate: ListItem.Standard {
            // Both "name" and "team" are taken from the model
            text: i18n.tr(name) +" ("+code+")"
            // iconSource: Qt.resolvedUrl(icon_path)
            // fallbackIconSource: Qt.resolvedUrl("graphics/uTranslate.png")

            // TODO : handle flag
            // progression: (code === 'fr') ? true : false;
            // iconSource: Qt.resolvedUrl("graphics/uTranslate.png")
            // onClicked: console.debug("listItem clicked")

            control: Switch {
                checked: (used == 1)? true : false; // int2bool
                // text: "Click me"
                // width: units.gu(19)

                onClicked: {
                    console.debug("switch : "+code+" Clicked, value="+checked)
                    var val = (checked)? 1 : 0; // bool2int
                    console.debug("valDB="+val);
                    // update of Model
                    langListModel.setProperty(index, "used", val);
                    // console.debug("Model used="+used);

                    // update of db  (directly from the view ??? shouldn't it  be done from the listModel ?)
                    writeUsedLang(code, val);

                    // update other parts of UI
                    // the current page
                    langPage.updateTitle();
                    // the settings page
                    settingsPage.updateLangInfos();
                }
            }
        }
    }

    function getTitle() {
        var nb = countUsedLangs();
        var text = my_i18n("Languages, no selected", "Languages, %n selected", "Languages, %n selected", nb);
        return text;
    }

    function updateTitle() {
        langPage.title = langPage.getTitle();
    }
}
