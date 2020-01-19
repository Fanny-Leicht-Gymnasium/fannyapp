/*
    Fannyapp - Application to view the cover plan of the Fanny-Leicht-Gymnasium ins Stuttgart Vaihingen, Germany
    Copyright (C) 2019  Itsblue Development <development@itsblue.de>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

#include <QQuickStyle>
#include <QStandardPaths>
#include <QtNetwork>
#include <QQmlApplicationEngine>
#include <QFile>
#include <QDesktopServices>

#include <QIcon>
#include <QStyleFactory>

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
#include "headers/appstyle.h"

int main(int argc, char *argv[])
{
    AppSettings * pAppSettings = new AppSettings();
    // ServerConn * pServerConn = new ServerConn();

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication::setAttribute(Qt::AA_UseHighDpiPixmaps);

    QGuiApplication app(argc, argv);

    qmlRegisterType<FoodPlanModel>("Backend", 1, 0, "FoodPlanModel");
    qmlRegisterType<EventModel>("Backend", 1, 0, "EventModel");
    qmlRegisterType<FilterModel>("Backend", 1, 0, "FilterModel");
    qmlRegisterType<ServerConn>("Backend", 1, 0, "ServerConn");
    qmlRegisterType<AppStyle>("Backend", 1, 0, "AppStyle");

    QQuickStyle::setStyle("Material");

#if (QT_VERSION >= QT_VERSION_CHECK(5, 11, 0) )
    QIcon::setFallbackSearchPaths(QIcon::fallbackSearchPaths() << ":/shared/icons");
    QIcon::setThemeName("ibmaterial");
#endif

    QQmlApplicationEngine engine;

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("_cppAppSettings", pAppSettings);
    context->setContextProperty("QtCompatiblityMode",
                            #if (QT_VERSION >= QT_VERSION_CHECK(5, 11, 0) )
                                false
                            #else
                                true
                            #endif
                                );
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    int ret;
    ret = app.exec();

    // delete pServerConn;
    delete pAppSettings;
    return(ret);
}
