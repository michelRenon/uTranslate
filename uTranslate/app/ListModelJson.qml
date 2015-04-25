import QtQuick 2.0

/*
 * based on code from :
 * JSONListModel - a QML ListModel with JSON and JSONPath support
 *
 * Copyright (c) 2012 Romain Pokrzywka (KDAB) (romain@kdab.com)
 * Licensed under the MIT licence (http://opensource.org/licenses/mit-license.php)
 */

Item {
    property string json: ""
    property variant liste : []

    property ListModel model : ListModel {
        id: jsonModel
    }
    property alias count: jsonModel.count

    onJsonChanged: updateJSONModel()
    onListeChanged: updateArrayModel()

    function updateJSONModel() {
        console.debug("ListJsonModel start update");
        jsonModel.clear();

        if (json === "")
            return;

        var objectArray = JSON.parse(json);
        for (var key in objectArray) {
            var jo = objectArray[key];
            jsonModel.append(jo);
        }
        console.debug("ListJsonModel updated");
        console.debug(json);
    }

    function updateArrayModel() {
        console.debug("ListJsonModel start array update");
        jsonModel.clear();

        if (liste.length === 0)
            return;

        for(var i=0, l=liste.length ; i < l; i++) {
            jsonModel.append(liste[i]);
        }

        console.debug("ListJsonModel updated");
        console.debug(json);
    }

}
