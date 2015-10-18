/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 0.1 as ListItem

import "components"

Page {
    // id: langPage
    title: langPage.getTitle()

    property bool doSelect: false // show only selected langs ?

    head {
        actions : [
            Action {
                id : switchAction
                iconName: langPage.doSelect == true ? "zoom-out" : "zoom-in"
                text: i18n.tr("Show selected")
                onTriggered: {
                    langPage.doSelect = !langPage.doSelect
                    // console.debug("show selected"+langPage.doSelect)
                    langPage.reloadLangs();
                }
            },

            Action {
                id : selectAllAction
                iconName: "select"
                text: i18n.tr("select all")
                onTriggered: {
                    // update of db  (directly from the view ??? shouldn't it  be done from the listModel ?)
                    selectAllLangs();
                    // the selection
                    langPage.reloadLangs();

                    translationPage.updateSelectedLangs();
                }
            },
            Action {
                id : selectNoneAction
                iconName: "select-none"
                text: i18n.tr("select none")
                onTriggered: {
                    // update of db  (directly from the view ??? shouldn't it  be done from the listModel ?)
                    unselectAllLangs();
                    // the selection
                    langPage.reloadLangs();

                    translationPage.updateSelectedLangs();
                }
            }
        ]
    }

    ListView {
        id: langList

        anchors.fill: parent
        // anchors.rightMargin: fastScroll.showing ? fastScroll.width - units.gu(1) : 0
        anchors.rightMargin: fastScroll.width - units.gu(1)
        clip: true
        currentIndex: -1

        model: langListModel

        function getSectionText(index) {
            return langListModel.get(index).name.substring(0,1)
        }

        delegate: ListItem.Standard {
            text: i18n.tr(name) +" ("+code+")"
            // iconSource: Qt.resolvedUrl(icon_path)
            // fallbackIconSource: Qt.resolvedUrl("graphics/flags-iso/ZZ.png")

            // TODO : handle flag
            // progression: (code === 'fr') ? true : false;
            // iconSource: Qt.resolvedUrl("graphics/uTranslate.png")
            // onClicked: console.debug("listItem clicked")

            iconSource: Qt.resolvedUrl("graphics/flags-iso/"+code.toUpperCase()+".png")
            onTriggered: {
                console.debug("listItem triggered")
               pageStack.push(countryPage)
            }
            onClicked: {
                console.debug("listItem clicked")

            }

            control: Switch {
                checked: (used == 1)? true : false; // int2bool

                onClicked: {
                    console.debug("switch : "+code+" Clicked, value="+checked)
                    var val = (checked)? 1 : 0; // bool2int
                    // console.debug("valDB="+val);
                    // update of Model
                    langListModel.setProperty(index, "used", val);
                    // console.debug("Model used="+used);

                    // update of db  (directly from the view ??? shouldn't it  be done from the listModel ?)
                    writeUsedLang(code, val);
                    // the selection
                    if (langPage.doSelect)
                        loadUsedLangs()

                    translationPage.updateSelectedLangs();
                }
            }
        }

        section {
            property: "name"
            criteria: ViewSection.FirstCharacter
            labelPositioning: ViewSection.InlineLabels
            delegate: SectionDelegate {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                text: section != "" ? section : "#"
            }
        }
    }

    FastScroll {
        id: fastScroll
        listView: langList
        enabled: true
        visible: true
        anchors {
            // top: langList.top
            // bottom: langList.bottom
            verticalCenter: parent.verticalCenter
            right: parent.right
        }
    }

    Component.onCompleted:  {
        // langPage.reloadLangs(); already done in pageStack.onCompleted()
    }

    function reloadLangs(){
        if (langPage.doSelect)
            loadUsedLangs()
        else
            loadLangs();
    }

    function getTitle() {
        var nb = countUsedLangs();
        var s0 = i18n.tr("Languages, no selected");
        var s1 = i18n.tr("Languages, one selected");
        var s2 = i18n.tr("Languages, %n selected");
        var text = my_i18n(s0, s1, s2, nb);
        return text;
    }

    function updateTitle() {
        langPage.title = langPage.getTitle();
    }
}
