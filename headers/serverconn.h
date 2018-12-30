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
    float progress;
    int authErrorCount;

    ReturnData_t senddata(QUrl serviceUrl, QUrlQuery postData);

private slots:
    void updateProgress(qint64 read, qint64 total);

    void setState(QString state);

public:
    explicit ServerConn(QObject *parent = nullptr);
    ~ServerConn();

public slots:
    Q_INVOKABLE int login(QString username, QString password, bool permanent);
    Q_INVOKABLE int logout();
    Q_INVOKABLE QString getDay(QString day);
    Q_INVOKABLE int checkConn();
    Q_INVOKABLE float getProgress();
    Q_INVOKABLE int getFoodPlan();
    Q_INVOKABLE int getEvents(QString day);

    Q_INVOKABLE QString getState();

signals:
    void stateChanged(QString newState);

public:
    QList<QList<QString>> m_weekplan;
    QList<QStringList> m_events;
    QStringList m_eventHeader;


};
extern ServerConn * pGlobalServConn;

#endif // SERVERCONN_H
