QT += qml quick quickcontrols2 xml
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

TEMPLATE = app
TARGET = fannyapp

ICON = favicon.icns
RC_ICONS = shared/favicon.ico

SOURCES += \
    sources/serverconn.cpp \
    sources/main.cpp \
    sources/appsettings.cpp \
    sources/foodplanmodel.cpp \
    sources/eventmodel.cpp \
    sources/filtermodel.cpp

HEADERS += \
    headers/serverconn.h \
    headers/appsettings.h \
    headers/foodplanmodel.h \
    headers/eventmodel.h \
    headers/filtermodel.h

RESOURCES += \
    shared/shared.qrc \
    qml/qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

android {
    QT += androidextras
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android-sources
}

DISTFILES += \
    favicon.png \
    android-sources/AndroidManifest.xml \
    android-sources/src/com/itsblue/flgvertretung/MainActivity.java \
    android-sources/res/drawable-hdpi/icon.png \
    android-sources/res/drawable-ldpi/icon.png \
    android-sources/res/drawable-mdpi/icon.png \
    android-sources/res/xml/provider_paths.xml \
    CHANGELOG.md

