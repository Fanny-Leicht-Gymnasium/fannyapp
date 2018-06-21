#include "headers/serverconn.h"


ServerConn::ServerConn(QObject *parent) : QObject(parent)
{
    qDebug("serverconn konstruktor");
    this->networkManager = new QNetworkAccessManager();
    this->refreshNetworkManager = new QNetworkAccessManager();
}

ServerConn::~ServerConn()
{
    qDebug("serverconn destruktor");
    delete this->networkManager;
    delete this->refreshNetworkManager;

    QString path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QDir dir(path + "/.fannyapp-tmp");
    dir.removeRecursively();
}


QString ServerConn::login(QString username, QString password, bool permanent)
{
//    QUrlQuery pdata;
//    ReturnData_t ret = this->senddata(QUrl("http://www.fanny-leicht.de/static15/http.intern/sheute.pdf"), pdata);
//    qDebug() << ret.text;

    // Create request
        QNetworkRequest request;
        request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/sheute.pdf" ) );

        // Pack in credentials
         QString concatenatedCredentials = username + ":" + password;
         QByteArray data = concatenatedCredentials.toLocal8Bit().toBase64();
         QString headerData = "Basic " + data;
         request.setRawHeader( "Authorization", headerData.toLocal8Bit() );

        QUrlQuery pdata;
        // Send request and connect all possible signals
        QNetworkReply*reply = this->networkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());
        //QNetworkReply*reply = networkManager->get( request );

        QEventLoop loop;
        loop.connect(this->networkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
        loop.exec();
        int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

        if(status_code == 200){
            this->username = username;
            this->password = password;
            if(permanent){
                pGlobalAppSettings->writeSetting("permanent", "1");
                pGlobalAppSettings->writeSetting("username", username);
                pGlobalAppSettings->writeSetting("password", password);
            }
            return("OK");
        }
        else if(status_code == 401){
            return("Ungültige Benutzerdaten.");
        }
        else if(status_code == 0){
            return("Keine Verbindung zum Server.");
        }
        else {
           QString ret = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toChar();
           ret = ret +  reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toChar();
           return(ret);
        }
}

int ServerConn::logout()
{
    this->username = "";
    this->password = "";
    pGlobalAppSettings->writeSetting("permanent", "0");
    pGlobalAppSettings->writeSetting("username", "");
    pGlobalAppSettings->writeSetting("password", "");

}

QString ServerConn::getDay(QString day)
{
    qDebug("getting file of day");
    // Create request
        QNetworkRequest request;
        request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/" + day + ".pdf" ) );

        // Pack in credentials
        // Pack in credentials
         QString concatenatedCredentials = this->username + ":" + this->password;
         QByteArray data = concatenatedCredentials.toLocal8Bit().toBase64();
         QString headerData = "Basic " + data;
         request.setRawHeader( "Authorization", headerData.toLocal8Bit() );

        QUrlQuery pdata;
        // Send request and connect all possible signals
        QNetworkReply*reply = this->networkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());
        //QNetworkReply*reply = networkManager->get( request );

        QEventLoop loop;
        loop.connect(this->networkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
        loop.exec();

        int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if(status_code == 200){
            qDebug("OK");
            QString path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);

            QDir dir;
            dir.mkdir(path + "/.fannyapp-tmp");
            QFile file(path + "/.fannyapp-tmp/" + day + ".pdf");

            file.open(QIODevice::ReadWrite);
            file.write(reply->readAll());
            file.close();

            QDesktopServices::openUrl(QUrl::fromLocalFile(path + "/.fannyapp-tmp/" + day + ".pdf"));
            qDebug() << QString::fromUtf8(reply->readAll());
            qDebug() << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            return("OK");
        }
        else if(status_code == 401){
            return("Ungültige Benutzerdaten.");
        }
        else if(status_code == 0){
            return("Keine Verbindung zum Server.");
        }
        else {
           QString ret = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toChar();
           ret = ret +  " (" + reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toChar() + ")";
           return(ret);
        }
}

int ServerConn::checkConn()
{
    // Create request
        QNetworkRequest request;
        request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/" ) );

        // Pack in credentials
        // Pack in credentials
        //ZedlerDo:LxyJQB
         QString concatenatedCredentials = this->username + ":" + this->password;
         QByteArray data = concatenatedCredentials.toLocal8Bit().toBase64();
         QString headerData = "Basic " + data;
         request.setRawHeader( "Authorization", headerData.toLocal8Bit() );

        QUrlQuery pdata;
        // Send request and connect all possible signals
        QNetworkReply*reply = this->refreshNetworkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());
        //QNetworkReply*reply = networkManager->get( request );

        QEventLoop loop;
        loop.connect(this->refreshNetworkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
        loop.exec();

        int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        return(status_code);

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
