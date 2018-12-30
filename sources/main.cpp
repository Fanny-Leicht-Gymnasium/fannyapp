#include <QQuickStyle>
#include <QStandardPaths>
#include <QtNetwork>
#include <QQmlApplicationEngine>
#include <QFile>
#include <QDesktopServices>

#include <QtCore/QUrl>
#include <QtCore/QCommandLineOption>
#include <QtCore/QCommandLineParser>
#include <QGuiApplication>
#include <QStyleHints>
#include <QScreen>
#include <QQmlApplicationEngine>
#include <QtQml/QQmlContext>
#include "headers/serverconn.h"
#include "headers/appsettings.h"
#include "headers/foodplanmodel.h"
#include "headers/eventmodel.h"
#include "headers/filtermodel.h"

int main(int argc, char *argv[])
{
    AppSettings * pAppSettings = new AppSettings();
    // ServerConn * pServerConn = new ServerConn();

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<FoodPlanModel>("Backend", 1, 0, "FoodPlanModel");
    qmlRegisterType<EventModel>("Backend", 1, 0, "EventModel");
    qmlRegisterType<FilterModel>("Backend", 1, 0, "FilterModel");
    qmlRegisterType<ServerConn>("Backend", 1, 0, "ServerConn");

    QQuickStyle::setStyle("Material");
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    QQmlContext *context = engine.rootContext();

    // context->setContextProperty("_cppServerConn", pServerConn);
    context->setContextProperty("_cppAppSettings", pAppSettings);
    if (engine.rootObjects().isEmpty())
        return -1;

    int ret;
    ret = app.exec();

    // delete pServerConn;
    delete pAppSettings;
    return(ret);
}
