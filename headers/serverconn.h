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

#ifndef SERVERCONN_H
#define SERVERCONN_H

#include <QObject>
#include <QDir>
#include <QUrl>
#include <QtXml>
#include <QTimer>

#include <QtNetwork>
#include <QAuthenticator>
#include <QDesktopServices>
#include <QXmlNamespaceSupport>

#include "headers/appsettings.h"

#ifdef Q_OS_ANDROID
#include <QtAndroidExtras>
#endif


typedef struct strReturnData{
    int status_code;
    QString text;
}ReturnData_t;

class ServerConn : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString state READ getState NOTIFY stateChanged)

private:
    QString state;
        // can be: loggedIn ; notLoggedIn
    QString username;
    QString password;
    QNetworkAccessManager *networkManager;
    QNetworkAccessManager *refreshNetworkManager;
    QTimer *checkConnTimer;
    int authErrorCount;

    ReturnData_t senddata(QUrl serviceUrl, QUrlQuery postData);

    QList<int> apiVersion = {0,2,1};

private slots:

    void setState(QString state);

public:
    explicit ServerConn(QObject *parent = nullptr);
    ~ServerConn();

public slots:
    Q_INVOKABLE int login(QString username, QString password, bool permanent);
    Q_INVOKABLE int logout();
    Q_INVOKABLE int checkConn();
    Q_INVOKABLE int getFoodPlan();
    Q_INVOKABLE int getEvents(QString day);

    Q_INVOKABLE QString getState();

signals:
    void stateChanged(QString newState);

public:
    QList<QStringList> m_weekplan;
    QList<QStringList> m_events;

};
extern ServerConn * pGlobalServConn;

#endif // SERVERCONN_H
