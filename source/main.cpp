#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QGuiApplication>
#include <QQuickView>
#include <QStandardPaths>
#include <QtQml>
#include <QtNetwork>
#include <QQmlApplicationEngine>

#include "serverconn.h"

int main(int argc, char *argv[])
{
    ServerConn * pServerConn = new ServerConn;

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    engine.rootContext()->setContextProperty("_cppServerConn", pServerConn);

    return app.exec();
}
