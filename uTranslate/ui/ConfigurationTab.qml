/* This file is part of uTranslate application.
 *
 * Author: 2013 Michel Renon <renon@mr-consultant.net>.
 * License: GPLv3, check LICENSE file.
 */
import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Layouts 0.1

import "../components"

Tab {
    title: i18n.tr("Test")

    page: Page {
        tools: WorldTabTools {
            objectName: "worldTab_tools"
        }

        onWidthChanged: {

            console.debug("page layouts.currentLayout="+layouts.currentLayout)
            // console.debug("1="+bouton1.width)
        }


        Component.onCompleted: console.debug("gu(30)="+units.gu(30)+"  gu(50)="+units.gu(50))

        Layouts {
            id: layouts
            anchors.fill: parent


            // onWidthChanged: console.debug("layouts layout.width="+layouts.width)

            layouts: [
                ConditionalLayout {
                    name: "column"
                    when: layouts.width > units.gu(80)

                    Item {
                        anchors.fill: parent

                        ItemLayout {
                            id: search
                            item: "itemSearch"
                            width: parent.width / 3
                            anchors {
                                top: parent.top
                                left: parent.left
                                bottom: parent.bottom
                            }
                        }
                        ItemLayout {
                            item: "itemRes"
                            anchors {
                                top: parent.top
                                left: search.right
                                bottom: parent.bottom
                                right: parent.right
                            }
                        }
                    }
                }
            ]


            // default layout

            Rectangle {
                id: search
                Layouts.item: "itemSearch"
                height: units.gu(10)
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                color: "red"
            }

            Rectangle {
                id: res
                Layouts.item: "itemRes"
                anchors {
                    top: search.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }
                color: "green"
            }

        }
    }
}
