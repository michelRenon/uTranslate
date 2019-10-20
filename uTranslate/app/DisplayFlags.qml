
import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
// import Ubuntu.Components.ListItems 1.3 as ListItem

Dialog {
    id: root
    /*
    objectName: "displayLanguageDialog"

    property string initialLanguage

    signal languageChanged (int newLanguage, int oldLanguage)
    */
    modal: true
    title: i18n.tr("Display flags")

    contentWidth: parent.width
    contentHeight: parent.height
    // anchors.fill: parent

    Component.onCompleted: {
        /* initialLanguage = i18n.language */
    }

    ListView {
        id: flagList
        objectName: "flagList"
        clip: true

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: divider.top

        contentHeight: contentItem.childrenRect.height
        boundsBehavior: contentHeight > root.height ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
        /* Set the direction to workaround https://bugreports.qt-project.org/browse/QTBUG-31905
           otherwise the UI might end up in a situation where scrolling doesn't work */
        flickableDirection: Flickable.VerticalFlick

        /* currentIndex: plugin.currentLanguage */

        model: countryListModel

        delegate: ListItem {
            ListItemLayout {
                title.text: i18n.tr(name) +" ("+code+")"

                Image {
                    id: flaglang
                    // visible: (name == "French")
                    source: Qt.resolvedUrl("graphics/flags-iso/"+code+".png")
                    SlotsLayout.position: SlotsLayout.Leading
                }
            }
            onClicked: console.log("select drapeau "+name+":"+code)
        }
        /*
        delegate: ListItem {
            objectName: "languageName" + index
            ListItemLayout {
                title.text: i18n.tr(name) +" ("+code+")"
            }
            / * selected: index == languageList.currentIndex * /

            onClicked: {
                / * languageList.currentIndex = index; * /
            }
        }
        */

        onCurrentIndexChanged: {
            /* i18n.language = plugin.languageCodes[currentIndex] */
        }
    }

    ListItem {
        id: divider
        height:units.gu(1)
        color: "#ccc"
    }


    /*
    ListItem.ThinDivider {
        id: divider

        anchors.bottom: buttonRectangle.top
    }
    */

    Item {
        id: buttonRectangle

        height: cancelButton.height + units.gu(2)

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Button {
            id: cancelButton
            objectName: "cancelChangeLanguage"
            text: i18n.tr("Cancel")

            anchors.left: parent.left
            anchors.right: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.topMargin: units.gu(1)
            anchors.leftMargin: units.gu(2)
            anchors.rightMargin: units.gu(1)
            anchors.bottomMargin: units.gu(1)

            onClicked: {
                /* i18n.language = initialLanguage */
                PopupUtils.close(root)
            }
        }

        Button {
            id: confirmButton
            objectName: "confirmChangeLanguage"
            text: i18n.tr("Confirm")
            enabled: true /* languageList.currentIndex != plugin.currentLanguage */

            anchors.left: parent.horizontalCenter
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: units.gu(1)
            anchors.leftMargin: units.gu(1)
            anchors.rightMargin: units.gu(2)
            anchors.bottomMargin: units.gu(1)

            onClicked: {
                /*
                var oldLang = plugin.currentLanguage;
                var newLang = languageList.currentIndex;
                languageChanged(newLang, oldLang);
                plugin.currentLanguage = newLang; */
                PopupUtils.close(root);
            }
        }
    }
}
