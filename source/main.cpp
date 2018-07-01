#include <QMessageBox>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QQuickView>
#include <QQuickStyle>
#include <QStandardPaths>
#include <QtQml>
#include <QtNetwork>
#include <QQmlApplicationEngine>
#include <QFile>
#include <QDesktopServices>

#include "headers/serverconn.h"
#include "headers/appsettings.h"

int main(int argc, char *argv[])
{
    ServerConn * pServerConn = new ServerConn;
    AppSettings * pAppSettings = new AppSettings();
    pGlobalAppSettings = pAppSettings;


    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    engine.rootContext()->setContextProperty("_cppServerConn", pServerConn);
    engine.rootContext()->setContextProperty("_cppAppSettings", pAppSettings);

    int ret;
    ret = app.exec();

    delete pServerConn;
    delete pAppSettings;
    return(ret);
}
