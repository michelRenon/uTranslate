import QtQuick.LocalStorage 2.0
import QtQuick 2.0
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
// import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Layouts 1.0
import U1db 1.0 as U1db
import QtQml 2.2 // for reading locale

import "components"

import "controller.js" as Controller
import "glosbe_lang.js" as GlosbeLang

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
    // useDeprecatedToolbar: false

    width: units.gu(48)
    height: units.gu(60)

    property var dbLang: null
    property bool firstStartMode : false

    function _initTables(){
        dbLang.transaction(function(tx){
            tx.executeSql('CREATE TABLE IF NOT EXISTS lang (name TEXT, code TEXT, used INTEGER, flag_code TEXT, name_ui TEXT)');
            var table1 = tx.executeSql("SELECT * FROM lang");
            // insert default values
            if (table1.rows.length === 0) {
                for(var i=0, l=GlosbeLang.glosbe_lang_array.length ; i < l; i++) {
                    var vlang = GlosbeLang.glosbe_lang_array[i];
                    tx.executeSql('INSERT INTO lang VALUES(?, ?, ?, ?, ?)', [vlang["name"], vlang["code"], 0, "", ""]);
                }
                // console.log('lang filled');
            };

            tx.executeSql('CREATE TABLE IF NOT EXISTS country (name TEXT, code TEXT)');
            var table2 = tx.executeSql("SELECT * FROM country");
            // insert default values
            if (table2.rows.length === 0) {
                for(var i=0, l=GlosbeLang.glosbe_country_array.length ; i < l; i++) {
                    var vcountry = GlosbeLang.glosbe_country_array[i];
                    tx.executeSql('INSERT INTO country VALUES(?, ?)', [vcountry["name"], vcountry["code"]]);
                }
                // console.log('country filled');
            };

        });
    }

    function openDB() {
        if(dbLang !== null) return;
        // object openDatabaseSync(string name, string version, string description, int estimated_size, jsobject callback(db))
        dbLang = LocalStorage.openDatabaseSync("sqlite-utranslate-app", "0.1", "uTranslate lang db", 100000);

        try {
            _initTables();
        } catch (err) {
            // console.log("Error creating table in database: " + err);
        };
    }

    function emptyDB() {
        openDB();

        dbLang.transaction(function(tx) {
            // Drop database tables
            var res = tx.executeSql('DROP TABLE lang');
            // console.debug("DROP TABLE lang : "+JSON.stringify(res));
            res = tx.executeSql('DROP TABLE country');
            // console.debug("DROP TABLE country : "+JSON.stringify(res));
        });
    }

    function resetDB() {
        openDB();

        dbLang.transaction(function(tx) {
            // Drop database tables
            var res = tx.executeSql('DROP TABLE lang');
            // console.debug("DROP TABLE lang : "+JSON.stringify(res));
            res = tx.executeSql('DROP TABLE country');
            // console.debug("DROP TABLE country : "+JSON.stringify(res));

            // console.debug("Debut _initTables()");
            _initTables();
            // console.debug("Fin _initTables()");

            // updates
            loadLangs();
            loadCountries();

            settingsPage.updateLangInfos();
        });
    }

    function initDBWithLocale(locale) {
        openDB();
        var res = false;
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('SELECT * FROM lang where code=?;', [locale]);
            if (rs.rows.length == 1) {
                var rs = tx.executeSql('UPDATE lang SET used=1 WHERE code=?;', [locale]);
                res = true;
            }
        });
        return res
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
        // console.log("countUsedLangs");
        // for (var prop in res){
        //     console.log(prop)
        //}
        // console.log("======");
        // console.log(res);
        // console.log(typeof(res));
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
                res = {'name' : 'no_lang', 'code' : 'no_lang', 'flag_code':'no_lang'};
        });
        return res;
    }

    function writeUsedLang(code_lang, used) {
        /*
         * code_lang: text
         * used : integer [0-1]
         */
        // console.debug("code_lang="+code_lang+", used="+used);
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE lang SET used=? WHERE code=?;', [used, code_lang]);
        });
    }

    function selectAllLangs() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE lang SET used=1 ;');
        });
    }

    function unselectAllLangs() {
        openDB();
        var res = "";
        dbLang.transaction(function(tx) {
            var rs = tx.executeSql('UPDATE lang SET used=0 ;');
        });
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
        id: firstStart
        database: utranslateDB
        docId: 'start'
        create: true
        defaults: { 'firststart': true}
    }
    /*
    U1db.Document {
        id: adoc
        database: utranslateDB
    }
    */
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
            // title: i18n.tr("Settings")
            header: PageHeader {
                title: i18n.tr("Settings")
            }
            visible: false

            Column {
                // anchors.fill: parent
                anchors {
                    top : parent.header.bottom
                    left : parent.left
                    right : parent.right
                    bottom: parent.bottom
                }
                spacing: units.gu(0)

                ListItem {
                    ListItemLayout {
                        title.text: i18n.tr("Providers")
                        title.textSize: Label.Large
                    }
                    /*
                    Label{
                        text : i18n.tr("Providers")
                        style: Text.Raised
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    */
                    onClicked: console.log("PROVIDERS")
                }
                ListItem {
                    // height : units.gu(3)
                    ListItemLayout {
                        title.text: i18n.tr("The current data provider is Glosbe")
                    }
                    /*
                    Label{
                        text : i18n.tr("The current data provider is Glosbe")
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    */
                    divider.opacity : 0
                }
                ListItem {
                    ListItemLayout {
                        title.text: ""
                        Button {
                            text: "http://glosbe.com"
                            width: units.gu(25)
                            SlotsLayout.position: SlotsLayout.Trailing

                            /*
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                verticalCenter: parent.verticalCenter
                            }
                            */
                            onClicked: Qt.openUrlExternally("http://glosbe.com")
                        }
                    }
                }
                ListItem {
                    id: langInfos
                    height: Math.max(middleVisuals.height, units.gu(6))

                    ListItemLayout {
                        title.text: settingsPage.getLangText()
                        subtitle.text: settingsPage.getLangSubtext()
                        Icon {
                            name: "next"
                            SlotsLayout.position: SlotsLayout.Trailing;
                            width: units.gu(2)
                        }
                    }





                    /*!
                      The list of strings that will be shown under the label text
                      \qmlproperty string subText
                     */
                    /*
                    property alias mainText: titleLabel.text
                    property alias subText: subLabel.text

                    Item  {
                        id: middleVisuals
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            right: langInfosIcon.left // parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        height: childrenRect.height + titleLabel.anchors.topMargin + subLabel.anchors.bottomMargin

                        Label {
                            id: titleLabel
                            text: settingsPage.getLangText()
                            // selected: subtitledListItem.selected
                            anchors {
                                top: parent.top
                                topMargin: units.gu(0.5)
                                left: parent.left
                                right: parent.right
                            }
                        }
                        Label {
                            id: subLabel
                            text: settingsPage.getLangSubtext()
                            // selected: subtitledListItem.selected
                            // secondary: true
                            color: Theme.palette.normal.backgroundText
                            anchors {

                                left: parent.left
                                right: parent.right
                                top: titleLabel.bottom
                                bottomMargin: units.gu(0.5)
                            }
                            fontSize: "small"
                            wrapMode: Text.Wrap
                            maximumLineCount: 5
                        }
                    }
                    ProgressionIcon {
                        id : langInfosIcon
                    }
                    */
                    onClicked: {
                        pageStack.push(langPage)
                     }
                }
                ListItem {
                    ListItemLayout {
                        title.text: i18n.tr("Debug")
                        title.textSize: Label.Large
                    }
                    /*
                    Label{
                        text : i18n.tr("Debug")
                        style: Text.Raised
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    */
                }
                ListItem {
                    ListItemLayout {
                        title.text: i18n.tr("Countries")
                        Icon {
                            name: "next"
                            SlotsLayout.position: SlotsLayout.Trailing;
                            width: units.gu(2)
                        }
                    }
                    /*
                    Label {
                        text : i18n.tr("Countries")
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    ProgressionIcon {}
                    */
                    onClicked: {
                        pageStack.push(countryPage)
                    }
                }
                ListItem {
                    ListItemLayout {
                        title.text: "Debug"
                        Icon {
                            name: "next"
                            SlotsLayout.position: SlotsLayout.Trailing;
                            width: units.gu(2)
                        }
                    }
                    /*
                    Label {
                        text : "Debug"
                        anchors {
                            left: parent.left
                            leftMargin: units.gu(2)
                            verticalCenter: parent.verticalCenter
                        }
                    }
                    ProgressionIcon {}
                    */
                    onClicked: {
                        pageStack.push(debugPage)
                    }
                }
            }

            function getLangText() {
                var nb = countUsedLangs();
                var s0 = i18n.tr("no selected language:");
                var s1 = i18n.tr("%n selected language:");
                var s2 = i18n.tr("%n selected languages:");
                var text = my_i18n(s0, s1, s2, nb);
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
                langInfos.mainText = settingsPage.getLangText();
                langInfos.subText = settingsPage.getLangSubtext();
                // langInfosMainText.text = settingsPage.getLangText()+"\n"+settingsPage.getLangSubtext();
            }
        }

        Page {
            id: aboutPage
            // title: i18n.tr("About")
            header : PageHeader {
                title: i18n.tr("About")
            }
            visible: false

            Column {
                // anchors.fill: parent
                anchors {
                    top : parent.header.bottom
                    left : parent.left
                    right : parent.right
                    bottom: parent.bottom
                }
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
                    text: i18n.tr("version ")+"0.7.7"
                    wrapMode: Text.WordWrap
                }
                Label {
                    id: info4
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "<a href='https://www.gnu.org/licenses/gpl.html'>GPLv3</a>"
                    wrapMode: Text.WordWrap
                    onLinkActivated: Qt.openUrlExternally(link)
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
                    text: i18n.tr("Flags form ")+"<a href='https://www.gosquared.com/resources/flag-icons/'>GoSquared</a>"
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
            // title: i18n.tr("Countries")
            header: PageHeader {
                title: i18n.tr("Countries")
            }
            visible: false

            ListView {
                // anchors.fill: parent
                anchors {
                    top : parent.header.bottom
                    left : parent.left
                    right : parent.right
                    bottom: parent.bottom
                }
                model: countryListModel

                /*
                delegate: ListItem.Standard {
                    text: i18n.tr(name) +" ("+code+")"
                    iconSource: Qt.resolvedUrl("graphics/flags-iso/"+code+".png")
                    fallbackIconSource: Qt.resolvedUrl("graphics/flags-iso/ZZ.png")
                }
                */
                delegate: ListItem {
                    ListItemLayout {
                        title.text: i18n.tr(name) +" ("+code+")"
                    }
                    /*
                    Label {
                        text: i18n.tr(name) +" ("+code+")"
                    }
                    */
                }
            }


        }
        Page {
            id: debugPage
            // title: "Debug"
            header: PageHeader {
                title: "Debug"
            }
            visible: false
            Column {
                anchors {
                    top : parent.header.bottom
                    left : parent.left
                    right : parent.right
                    bottom: parent.bottom
                }
                spacing: units.gu(1)

                Button {
                    text: "Empty DB"
                    onClicked: {
                        emptyDB();
                    }
                }
                Button {
                    text: "Reset DB"
                    onClicked: {
                        resetDB();
                    }
                }
                Label {
                    id: info7
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "Locale: "+Qt.locale().name
                    wrapMode: Text.WordWrap
                }

            }

        }


        onCurrentPageChanged: {
            console.debug("current page="+pageStack.currentPage);
            if (pageStack.currentPage == translationPage){
                if (firstStartMode === true) {
                    firstStart.contents = { 'firststart': false};
                    firstStartMode = false;
                }

                translationPage.checkBadFocus()
            } else if (pageStack.currentPage == langPage){
                // load ListModel with langs
                // No, it's done only at app startup
            }
        }

        Component.onCompleted:  {
            console.debug("PAGESTACK completed")
            pageStack.push(translationPage)

            var startParams = firstStart.contents;
            if (startParams['firststart'] === true) {
                // start "first start" mode
                firstStartMode = true;

                // search locale
                var locale = Qt.locale().name;
                console.debug("Locale="+locale);
                locale = locale.substring(0,2);
                console.debug("Locale="+locale);
                var foundLocale = initDBWithLocale(locale);
                console.debug("found Locale="+foundLocale);
                // Load datas
                loadLangs();
                loadCountries();
                if (foundLocale) {
                    translationPage.setLang(locale);
                    translationPage.setLangDest(locale);
                    langPage.updateTitle();

                    utApp.updateContext({'lgsrc': locale, 'lgdest': locale});
                }

                // show first start wizard
                var res = readLang(locale);
                var localeName = i18n.tr(res.name);
                translationPage.startWizard(localeName, foundLocale);

            } else {
                // Load datas
                loadLangs();
                loadCountries();

                // Load searchContext from previous usage.
                var params = dbContext.contents;

                // console.debug("onCompleted params="+Object.keys(params))
                // console.debug("onCompleted params="+params['lgsrc']+":"+params['lgdest'])
                utApp.setContext(params);
                translationPage.updateTabContext(utApp.searchContext, true);
            }
            // translationPage.startWizard();
            utApp.loaded = true;
        }

        ListModel {
            id: langListModel

            /*
            onDataChanged: {
                // console.debug("langListModel data changed:"); // " code="+code+" name="+name+" used="+used);
                // console.debug("item:"+item);
                // console.debug("object:"+object);
            }
            */
        }

        ListModel {
            id: countryListModel
        }
    }

    function _loadLangs(aModel, used) {
        aModel.clear();
        var langs;
        if (used)
            langs = readUsedLangs();
        else
            langs = readLangs();
        // Note : 'langs' is not a real list
        // console.log("langs="+JSON.stringify(langs)+"nb="+langs.length);

        // translate langs : use a temp list
        var lgs = [];
        for(var i=0, l=langs.length ; i < l; i++) {
            var elem = langs[i];
            elem['name'] = i18n.tr(elem['name']);
            lgs.push(elem);
        }
        // console.log("lgs="+JSON.stringify(lgs)+"nb="+lgs.length);

        // Sort lang list after translation
        lgs.sort(function(a,b){return a['name'].localeCompare(b['name'])});
        // console.log("lgs sorted="+JSON.stringify(lgs)+"nb="+lgs.length);

        // fill model
        for(var i=0, l=lgs.length ; i < l; i++) {
            aModel.append(lgs[i]);
        }
    }

    function loadLangs() {
        _loadLangs(langListModel, false);
    }

    function loadUsedLangs(usedModel) {
        var aModel = langListModel;
        if (typeof usedModel !== "undefined")
            aModel=usedModel;
        _loadLangs(aModel, true);
    }

    function loadCountries() {
        countryListModel.clear();
        var countries = readCountries();

        // Note : 'countries' is not a real list
        // console.log("langs="+JSON.stringify(langs)+"nb="+langs.length);

        // translate countries : use a temp list
        var cts = [];
        for(var i=0, l=countries.length ; i < l; i++) {
            var elem = countries[i];
            elem['name'] = i18n.tr(elem['name']);
            cts.push(elem);
        }
        // console.log("cts="+JSON.stringify(cts)+"nb="+cts.length);

        // Sort country list after translation
        cts.sort(function(a,b){return a['name'].localeCompare(b['name'])});
        // console.log("cts sorted="+JSON.stringify(cts)+"nb="+cts.length);

        // fill model
        for(var i=0, l=cts.length ; i < l; i++) {
            countryListModel.append(cts[i]);
        }
    }

    function updateContext(params) {
        setContext(params);
        // store params in db
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

        // res = i18n.tr(src);
        // translation has to be done outside, for i18n.tr() to be
        // listed in .pot file.
        res = src;
        res = res.replace("%n", nb)
        return res;
    }
}

