#ifndef SERVERCONN_H
#define SERVERCONN_H

#include <QObject>
#include <QtNetwork>
#include <QAuthenticator>

typedef struct strReturnData{
    int status_code;
    QString text;
}ReturnData_t;

class ServerConn : public QObject
{
    Q_OBJECT
public:
    QNetworkAccessManager *networkManager;
    explicit ServerConn(QObject *parent = nullptr);
    Q_INVOKABLE QString login();
    ReturnData_t senddata(QUrl serviceUrl, QUrlQuery postData);

signals:

public slots:
};

#endif // SERVERCONN_H
