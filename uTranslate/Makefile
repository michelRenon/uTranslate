# More information: https://wiki.ubuntu.com/Touch/Testing
#
# Notes for autopilot tests:
# -----------------------------------------------------------
# In order to run autopilot tests:
# sudo apt-add-repository ppa:autopilot/ppa
# sudo apt-get update
# sudo apt-get install python-autopilot autopilot-qt
#############################################################

all:

autopilot:
	chmod +x tests/autopilot/run
	tests/autopilot/run

check:
	qmltestrunner -input tests/unit

run:
	/usr/bin/qmlscene $@ uTranslate.qml


pot: uTranslate.qml ui/TranslationTab.qml ui/DefinitionTab.qml ui/ConfigurationTab.qml components/FlagButton.qml components/LangSelector.qml
	xgettext -s -j -o po/translate.pot \
	--from-code=UTF-8 --c++ --qt \
	--add-comments=/ \
	--keyword=tr \
	--package-name='Translate' \
	--copyright-holder='MR Consultant' \
	uTranslate.qml \
	ui/TranslationTab.qml ui/DefinitionTab.qml ui/ConfigurationTab.qml \
	components/FlagButton.qml components/LangSelector.qml

# to create a new po file :
# msginit -i po/translate.pot -o po/XX.po --no-translator


# to update po files :
# echo '' > messages.po # xgettext needs that file, and we need it empty
# find . -type f -iname "*.py" | xgettext -j -f -     ?????
# msgmerge -N existing.po messages.po > new.po
# mv new.po existing.po
# rm messages.po


# roman@roman-ubuntu:~/QtCreator/OwnDictionary$ mkdir locale
# roman@roman-ubuntu:~/QtCreator/OwnDictionary$ xgettext -C --qt --keyword=tr --add-comments=TRANSLATORS OwnDictionary.qml -p locale -o messages.pot
# roman@roman-ubuntu:~/QtCreator/OwnDictionary$ ls locale
# messages.pot
# roman@roman-ubuntu:~/QtCreator/OwnDictionary$ cd locale/
# roman@roman-ubuntu:~/QtCreator/OwnDictionary/locale$ msginit -i messages.pot -o sk.po
# -- I edited here the sk.po to add Slovak translation
# roman@roman-ubuntu:~/QtCreator/OwnDictionary/locale$ msgmerge -U sk.po messages.pot
# roman@roman-ubuntu:~/QtCreator/OwnDictionary/locale$ mkdir -p sk/LC_MESSAGES
# -- in manifest.json I found such line :     "name": 
# "com.ubuntu.developer.username.owndictionary", so I executed this :
# roman@roman-ubuntu:~/QtCreator/OwnDictionary/locale$ msgfmt sk.po -o sk/LC_MESSAGES/com.ubuntu.developer.username.owndictionary.mo








# Quick summary
# 
    # You need to bind the text domain before using gettext. In C++ you can do it like this:
# 
    # bindtextdomain("domainname", "somedir");
    # textdomain("domainname");
# 
    # In Qml you can probably do something like this:
# 
    # i18n.bindtextdomain("domainname", "somedir");
    # i18n.domain = "domainname";
# 
    # Be sure to do that before 18n.tr is used.
# 
    # To generate .pot template and source .po files, use these commands:
# 
    # xgettext -C --qt --keyword=tr -p somedir -o messages.pot
    # msginit -i somedir/messages.pot -o somedir/somelanguage.po
# 
    # (replace somedir with the directory your domain is bound to, and somelanguage with the language you want to translate to).
# 
    # To generate .mo files from source .po files, use msgfmt po-file -o mo-file command.
# 
    # Compiled .mo files should be placed inside a directory you bound the text domain to, more specifically in
# 
    # somedir/somelanguage/LC_MESSAGES/domainname.mo
# 
    # (replace somedir, somelanguage and domainname with your values).
