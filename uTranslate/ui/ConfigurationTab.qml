import QtQuick 2.0
import Ubuntu.Components 0.1
import "../components"

Tab {
    title: i18n.tr("Configuration")

    page: Page {
        tools: WorldTabTools {
            objectName: "worldTab_tools"
        }

        Column {

            Label {
                text : "To Be Defined"
            }

            Label {
                text : 'The current data provider is Glosbe (<a href="http://glosbe.com">http://glosbe.com</a>)'
            }

        }
    }
}
