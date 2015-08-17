import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Layouts 0.1
import U1db 1.0 as U1db

// import "ui"
import "controller.js" as Controller

// import ListModelJson 1.0
import "glosbe_lang.js" as GlosbeLang

/*!
    \brief MainView with Tabs element.
           First Tab has a single Label and
           second Tab has a single ToolbarAction.
*/

MainView {
    id:utApp

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "utranslate.mrenon"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    useDeprecatedToolbar: false

    width: units.gu(48)
    height: units.gu(60)

    property var dbLang: null

    function openDB() {
        if(dbLang !== null) return;
        // object openDatabaseSync(string name, string version, string description, int estimated_size, jsobject callback(db))
        dbLang = LocalStorage.openDatabaseSync("sqlite-utranslate-app", "0.1", "uTranslate lang db", 100000);

        try {
            dbLang.transaction(function(tx){
                tx.executeSql('CREATE TABLE IF NOT EXISTS lang (name TEXT, code TEXT, used INTEGER, flag_code TEXT)');
                var table1 = tx.executeSql("SELECT * FROM lang");
                // insert default values
                if (table1.rows.length === 0) {
                    for(var i=0, l=GlosbeLang.glosbe_lang_array.length ; i < l; i++) {
                        var vlang = GlosbeLang.glosbe_lang_array[i];
                        tx.executeSql('INSERT INTO lang VALUES(?, ?, ?, ?)', [vlang["name"], vlang["code"], 0, ""]);
                    }
                    console.log('lang filled');
                };

                tx.executeSql('CREATE TABLE IF NOT EXISTS country (name TEXT, code TEXT)');
                var table2 = tx.executeSql("SELECT * FROM country");
                // insert default values
                if (table2.rows.length === 0) {
                    for(var i=0, l=GlosbeLang.glosbe_country_array.length ; i < l; i++) {
                        var vcountry = GlosbeLang.glosbe_country_array[i];
                        tx.executeSql('INSERT INTO country VALUES(?, ?)', [vcountry["name"], vcountry["code"]]);
                    }
                    console.log('country filled');
                };

            });
        } catch (err) {
            console.log("Error creating table in database: " + err);
        };
    }

    function readLangs() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM lang ;', []);
            res = rs.rows;
        });
        return res;
    }

    function readUsedLangs() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM lang WHERE used=1;', []);
            res = rs.rows;
        });
        return res;
    }

    function countUsedLangs() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT count(*) FROM lang WHERE used=1;', []);
            res = rs.rows[0];
            res = parseInt(res['count(*)']); // force integer
        });
        console.log("countUsedLangs");
        // for (var prop in res){
        //     console.log(prop)
        //}
        // console.log("======");
        console.log(res);
        console.log(typeof(res));
        return res;
    }

    function readNameUsedLangs() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT name FROM lang WHERE used=1;', []);
            res = rs.rows;
        });
        return res;
    }

    function readLang(code) {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM lang WHERE code=?;', [code]);
            if (rs.rows.length == 1)
                res = rs.rows[0];
            else
                res = {};
        });
        return res;
    }

    function writeUsedLang(code_lang, used) {
        /*
         * code_lang: text
         * used : integer [0-1]
         */
        console.debug("code_lang="+code_lang+", used="+used);
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE lang SET used=? WHERE code=?;', [used, code_lang]);
            // res = rs.rows;
        });
        // return res;
    }

    function readCountries() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM country ;', []);
            res = rs.rows;
        });
        return res;
    }

    U1db.Database {
        id: utranslateDB
        path: "utranslate.db"
    }

    U1db.Document {
        id: dbContext
        database: utranslateDB
        docId: 'context'
        create: true
        defaults: { 'lgsrc': 'eng', 'lgdest': 'deu'}
    }

    U1db.Document {
        id: adoc
        database: utranslateDB
    }

    property var pageStack: pageStack

    property var searchContext : {'searchtext': '', 'lgsrc': 'fra', 'lgdest': 'eng', 'suggest': []}

    property bool loaded: false


    PageStack {
        id: pageStack

        TranslationPage{
            id: translationPage
            visible: false
        }

        Page {
            id: settingsPage
            title: i18n.tr("Settings")
            visible: false

            Column {
                anchors.fill: parent
                spacing: units.gu(0)

                ListItem.Header {
                    text : i18n.tr("Providers")
                }

                ListItem.Subtitled {
                    text : 'The current data provider is Glosbe'
                    subText: '(<a href="http://glosbe.com">http://glosbe.com</a>)'
                    showDivider: false
                    highlightWhenPressed: true
                    progression: true
                    onTriggered: Qt.openUrlExternally("http://glosbe.com")
                 }

                ListItem.Subtitled {
                    id: langInfos
                    text : settingsPage.getLangText()
                    subText: settingsPage.getLangSubtext()
                    showDivider: false
                    progression: true
                    highlightWhenPressed: true
                    onTriggered: {
                        pageStack.push(langPage)
                     }
                }
                /*
                ListItem.Subtitled {
                     text : "Countries"
                     // subText: "German, Greek, English, French, Italian, Portuguese, Spanish"
                     showDivider: false
                     progression: true
                     highlightWhenPressed: true
                     onTriggered: {
                        pageStack.push(countryPage)
                     }
                }

                ListItem.Empty{
                    showDivider: false
                    highlightWhenPressed: false
                }
                */
                /*
                ListItem.Header {
                    text : i18n.tr("General")
                }

                ListItem.Standard {
                    text : i18n.tr("About")
                    iconName: "info"
                    // iconSource: Qt.resolvedUrl("graphics/uTranslate_64.png")
                    progression:true
                    // showDivider: false
                    onTriggered: {
                        pageStack.push(aboutPage)
                    }
                }
                */
            }

            function getLangText() {
                var nb = countUsedLangs();
                var text = my_i18n("no selected language:", "%n selected language:", "%n selected languages:", nb);
                return text;
            }
            function getLangSubtext() {
                var langs = readNameUsedLangs();
                var text = "";
                for(var i=0, l=langs.length ; i < l; i++) {
                    text += i18n.tr(langs[i].name)+", ";
                }
                return text;
            }
            function updateLangInfos() {
                langInfos.text = settingsPage.getLangText();
                langInfos.subText = settingsPage.getLangSubtext();
            }
        }

        Page {
            id: aboutPage
            title: i18n.tr("About")
            visible: false

            // Item {
            Column {
                anchors.fill: parent
                spacing: units.gu(1)
                anchors.topMargin: units.gu(5)

                UbuntuShape {
                    width: units.gu(12)
                    height: units.gu(12)
                    anchors.horizontalCenter: parent.horizontalCenter
                    image: Image {
                        id: logo
                        source: Qt.resolvedUrl("graphics/uTranslate.png")
                        anchors.horizontalCenter: parent.horizontalCenter
                        // antialiasing: true
                    }
                }
                Label {
                    id: info1
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("uTranslate, a translation app")
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info2
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("by ")+"<a href='http://www.mr-consultant.net/blog/'>Michel Renon</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    id: info3
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("version ")+"0.4"
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info4
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "GPLv3"
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info5
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Project website: ")+"<br><a href='https://github.com/michelRenon/uTranslate'>https://github.com/michelRenon/uTranslate</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    id: info6
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Flags form ")+"<a href='http://commons.wikimedia.org/wiki/Drapeaux'>Wikimedia Commons</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        }

        LangPage{
            id: langPage
            visible: false
        }

        Page {
            id: countryPage
            title: i18n.tr("Countries")
            visible: false

            ListView {
                anchors.fill: parent
                model: countryListModel

                delegate: ListItem.Standard {
                    // Both "name" and "team" are taken from the model
                    text: i18n.tr(name) +" ("+code+")"
                    // iconSource: Qt.resolvedUrl(icon_path)
                    // fallbackIconSource: Qt.resolvedUrl("graphics/uTranslate.png")
                }
            }


        }

        onCurrentPageChanged: {
            // console.debug("current page="+pageStack.currentPage);
            if (pageStack.currentPage == translationPage){
                translationPage.checkBadFocus()
            } else if (pageStack.currentPage == langPage){
                // load ListModel with langs
                // No, it's done only at app startup
            }
        }

        Component.onCompleted:  {
            loadLangs();
            loadCountries();

            // console.debug("PAGESTACK completed")
            pageStack.push(translationPage)

            // Load searchContext from previous usage.
            var params = dbContext.contents;

            // console.debug("onCompleted params="+Object.keys(params))
            // console.debug("onCompleted params="+params['lgsrc']+":"+params['lgdest'])
            utApp.setContext(params);
            translationPage.updateTabContext(utApp.searchContext, true);
            utApp.loaded = true;

            // console.debug("GlosbeLang="+GlosbeLang.glosbe_lang_array);

            console.log("debug i18n");
            for (var i = 0 ; i < 10 ; ++i) {
                // lp#1204141
                // var text = i18n.tr("valeur = %n","valeurs = %n", i).arg(i);
                var text = my_i18n("valeur nulle = %n", "valeur = %n","valeurs = %n", i);
                console.log(text);
            }
        }
        ListModel {
            id: langListModel

            onDataChanged: {
                console.debug("langListModel data changed:"); // " code="+code+" name="+name+" used="+used);
                // console.debug("item:"+item);
                // console.debug("object:"+object);
            }


            /*
            ListElement {
                code:"deu"
                name: "german"
                icon_path: "graphics/ext/deu2.png"
            }
            ListElement {
                code:"ell"
                name: "greek"
                icon_path: "graphics/ext/ell2.png"
            }
            ListElement {
                code:"eng"
                name: "english"
                icon_path: "graphics/ext/eng2.png"
            }
            ListElement {
                code:"fra"
                name: "french"
                icon_path: "graphics/ext/fra2.png"
            }
            ListElement {
                code:"ita"
                name: "italian"
                icon_path: "graphics/ext/ita2.png"
            }
            ListElement {
                code:"por"
                name: "portugese"
                icon_path: "graphics/ext/por2.png"
            }
            ListElement {
                code:"spa"
                name: "spanish"
                icon_path: "graphics/ext/spa2.png"
            }
            */
        }
        ListModel {
            id: countryListModel
        }
    }



    function loadLangs() {
        langListModel.clear();
        var langs = readLangs();
        for(var i=0, l=langs.length ; i < l; i++) {
            langListModel.append(langs[i]);
        }
    }

    function loadCountries() {
        countryListModel.clear();
        var countries = readCountries();
        for(var i=0, l=countries.length ; i < l; i++) {
            countryListModel.append(countries[i]);
        }
    }

    function updateContext(params) {
        setContext(params);
        // store some params in u1db
        saveDb();
    }

    function setContext(params) {
        // console.debug("TABS : new params="+params)
        for (var param in params) {
            searchContext[param] = params[param]
            // console.debug("p:"+param+" = "+params[param])
        }
    }

    function saveDb() {
        var temp = {};
        temp['lgsrc'] = searchContext['lgsrc'];
        temp['lgdest'] = searchContext['lgdest'];
        dbContext.contents = temp;
    }

    function my_i18n(zero, singular, plural, nb) {
        var res = "";
        var src = "";
        if (nb == 0)
            src = zero;
        else if (nb == 1)
            src = singular;
        else
            src = plural;

        res = i18n.tr(src);
        res = res.replace("%n", nb)
        return res;
    }
}

