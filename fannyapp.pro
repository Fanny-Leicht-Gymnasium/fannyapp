QT += qml quick quickcontrols2
CONFIG += c++11

VERSION = 1.0.1

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

ICON = shared/graphics/favicon.icns
RC_ICONS = shared/graphics/favicon.ico

SOURCES += \
    sources/serverconn.cpp \
    sources/main.cpp \
    sources/appsettings.cpp \
    sources/foodplanmodel.cpp \
    sources/eventmodel.cpp \
    sources/filtermodel.cpp \
    sources/appstyle.cpp

HEADERS += \
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
    LIBS += "$$PWD/android-sources/libs/armeabi-v7a/libssl.a"
    LIBS += "$$PWD/android-sources/libs/armeabi-v7a/libcrypto.a"
}
win {
    LIBS += "$$PWD/windows-libs/libeay32.dll"
    LIBS += "$$PWD/windows-libs/ssleay32.dll"
}

ios {
    QMAKE_ASSET_CATALOGS += shared/Assets.xcassets
}

DISTFILES += \
    android-sources/AndroidManifest.xml \
    CHANGELOG.md

