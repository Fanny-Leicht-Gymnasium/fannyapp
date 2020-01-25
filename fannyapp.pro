QT += qml quick quickcontrols2 widgets
CONFIG += c++11

VERSION = 1.0.2

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

SOURCES += \
    sources/filehelper.cpp \
    sources/serverconn.cpp \
    sources/main.cpp \
    sources/appsettings.cpp \
    sources/foodplanmodel.cpp \
    sources/eventmodel.cpp \
    sources/filtermodel.cpp \
    sources/appstyle.cpp

HEADERS += \
    headers/filehelper.h \
    headers/serverconn.h \
    headers/appsettings.h \
    headers/foodplanmodel.h \
    headers/eventmodel.h \
    headers/filtermodel.h \
    headers/appstyle.h

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
    include($$PWD/android_openssl-master/openssl.pri)
}

win {
    RC_ICONS = shared/graphics/favicon.ico
    LIBS += "$$PWD/windows-libs/libeay32.dll"
    LIBS += "$$PWD/windows-libs/ssleay32.dll"
}

ios {
    QMAKE_ASSET_CATALOGS += shared/Assets.xcassets
    xcode_product_bundle_identifier_setting.value = "de.itsblue.fannyapp"

    QMAKE_IOS_DEPLOYMENT_TARGET=9.0

    OBJECTIVE_SOURCES += \
        sources/ios/docviewcontroller.mm \
        sources/ios/notch.mm \
        sources/ios/iosshareutils.mm

    HEADERS += \
        headers/ios/docviewcontroller.hpp \
        headers/ios/notch.h \
        headers/ios/iosshareutils.hpp

 QT += gui-private
}

osx {

ICON = shared/graphics/favicon.icns
}

DISTFILES += \
    android-sources/AndroidManifest.xml \
    android-sources/build.gradle \
    CHANGELOG.md \
    android-sources/src/de/itsblue/fannyapp/MainActivity.java \
    android-sources/src/org/ekkescorner/utils/QShareUtils.java
