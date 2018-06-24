#ifndef SERVERCONN_H
#define SERVERCONN_H

#include <QObject>
#include <QDir>
#include <QUrl>
#include <QtNetwork>
#include <QAuthenticator>
#include <QDesktopServices>
#include <QXmlNamespaceSupport>

#include "headers/appsettings.h"


typedef struct strReturnData{
    int status_code;
    QString text;
}ReturnData_t;

class ServerConn : public QObject
{
    Q_OBJECT

public:
    QString username;
    QString password;
    QNetworkAccessManager *networkManager;
    QNetworkAccessManager *refreshNetworkManager;
    float progress;
public:
    explicit ServerConn(QObject *parent = nullptr);
    ~ServerConn();
    Q_INVOKABLE QString login(QString username, QString password, bool permanent);
    Q_INVOKABLE int logout();
    Q_INVOKABLE QString getDay(QString day);
    Q_INVOKABLE int checkConn();
    Q_INVOKABLE float getProgress();
    Q_INVOKABLE QString getFoodPlan();
    Q_INVOKABLE QVariantMap getFoodPlanData(int index);
    ReturnData_t senddata(QUrl serviceUrl, QUrlQuery postData);

signals:

public slots:
    void updateProgress(qint64 read, qint64 total);

private:

struct Day
{
    QString Cookteam;
    QString Date;
    QString Main;
    QString Main_veg;
    QString Salad;
    QString Dessert;
};

QList<QList<QString>> m_weekplan;

};

#endif // SERVERCONN_H
