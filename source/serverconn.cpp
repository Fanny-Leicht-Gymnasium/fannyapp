#include "serverconn.h"

ServerConn::ServerConn(QObject *parent) : QObject(parent)
{
    qDebug("serverconn konstruktor");
    this->networkManager = new QNetworkAccessManager();


}

QString ServerConn::login()
{
//    QUrlQuery pdata;
//    ReturnData_t ret = this->senddata(QUrl("http://www.fanny-leicht.de/static15/http.intern/sheute.pdf"), pdata);
//    qDebug() << ret.text;

    // Create request
        QNetworkRequest request;
        request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/sheute.pdf" ) );

        // Pack in credentials
        QString concatenatedCredentials = "ZedlerDo:LxyJQB";
        QByteArray data = concatenatedCredentials.toLocal8Bit().toBase64();
        QString headerData = "Basic " + data;
        request.setRawHeader( "Authorization", headerData.toLocal8Bit() );
        QUrlQuery pdata;
        // Send request and connect all possible signals
        QNetworkReply*reply = this->networkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());
        qDebug() << QString::fromUtf8(reply->readAll());
}

ReturnData_t ServerConn::senddata(QUrl serviceUrl, QUrlQuery pdata)
{

    ReturnData_t ret; //this is a custom type to store the returned data
    // Call the webservice

    QNetworkRequest request(serviceUrl);
    QAuthenticator authenticator;
    authenticator.setUser("ZedlerDo");
    authenticator.setPassword("LxyJQB");
    request.setHeader(QNetworkRequest::ContentTypeHeader,
        "application/x-www-form-urlencoded");

    //set ssl configuration
    //send a POST request with the given url and data to the server
    QNetworkReply* reply;

    reply = this->networkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());

    //wait until the request has finished
    QEventLoop loop;
    loop.connect(this->networkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
    loop.exec();

    //get the status code
    QVariant status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    ret.status_code = status_code.toInt();
    if(ret.status_code == 0){ //if tehstatus code is zero, the connecion to the server was not possible
        ret.status_code = 444;
    }
    //get the full text response
    ret.text = QString::fromUtf8(reply->readAll());

    //return the data
    return(ret);
}
