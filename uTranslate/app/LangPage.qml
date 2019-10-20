/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

import "components"

Page {
    // id: langPage

    property bool doSelect: false // show only selected langs ?

    header: PageHeader {
        id: headerLangPage
        title: i18n.tr("Languages")
        subtitle: langPage.getTitle()

        trailingActionBar {
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
    }


    Component {
        id: displayFlags

        DisplayFlags {
            /* onLanguageChanged: {            } */
        }
    }
    ListView {
        id: langList

        // anchors.fill: parent
        anchors {
            top : parent.header.bottom
            left : parent.left
            right : parent.right
            bottom: parent.bottom
            rightMargin: fastScroll.width - units.gu(1)
        }

        clip: true
        currentIndex: -1

        model: langListModel

        function getSectionText(index) {
            return langListModel.get(index).name.substring(0,1)
        }

        delegate: ListItem {
            ListItemLayout {
                id: layout
                title.text: i18n.tr(name) +" ("+code+")"

                Switch {
                    id: switchLang
                    SlotsLayout.position: SlotsLayout.Trailing
                    checked: (used == 1)? true : false; // int2bool

                    onClicked: {
                        // console.debug("switch : "+code+" Clicked, value="+checked)
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

                Image {
                    id: flaglang
                    // visible: (name == "French")
                    source: (name == "French") ? Qt.resolvedUrl("graphics/flags-iso/FR.png") : Qt.resolvedUrl("graphics/flags-iso/ZZ_Z.png")
                    SlotsLayout.position: SlotsLayout.Leading
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("click drapeau "+name+":"+code);
                            PopupUtils.open(displayFlags);
                        }
                    }
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
        var s0 = i18n.tr("no selected");
        var s1 = i18n.tr("one selected");
        var s2 = i18n.tr("%n selected");
        var text = my_i18n(s0, s1, s2, nb);
        return text;
    }

    function updateTitle() {
        langPage.header.subtitle = langPage.getTitle();
    }
}
