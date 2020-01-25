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

#include "headers/serverconn.h"
#define http https

ServerConn * pGlobalServConn = nullptr;

ServerConn::ServerConn(QObject *parent) : QObject(parent)
{
    qDebug("+----- ServerConn constructor -----+");
    pGlobalServConn = this;

    this->fileHelper = new FileHelper();
    connect(this->fileHelper, &FileHelper::shareError, [=](){qWarning() << "share error";});
    connect(this->fileHelper, &FileHelper::shareFinished, [=](){qWarning() << "share finished";});
    connect(this->fileHelper, &FileHelper::shareNoAppAvailable, [=](){qWarning() << "share no app available";});

    // get local work path
#if defined (Q_OS_IOS)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).value(0);
    qDebug() << "iOS: QStandardPaths::DocumentsLocation: " << docLocationRoot;
#elif defined(Q_OS_ANDROID)
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#else
    QString docLocationRoot = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).value(0);
#endif
    mDocumentsWorkPath = docLocationRoot.append("/tmp_pdf_files");
    if (!QDir(mDocumentsWorkPath).exists()) {
        if (!QDir("").mkpath(mDocumentsWorkPath)) {
            pGlobalAppSettings->writeSetting("localDocPathError", "true");
        }
    }

    // check login state
    int perm = pGlobalAppSettings->loadSetting("permanent").toInt();
    qDebug() << "+----- login state: " << perm << " -----+";

    if(perm == 1){
        // permanent login -> restore login
        this->token = pGlobalAppSettings->loadSetting("token");

        this->setState("loggedIn");
    }
    else {
        this->setState("notLoggedIn");
    }
}

int ServerConn::login(QString username, QString password, bool permanent)
{
    // prepare URL

    QByteArray usernameByteArray = username.toUtf8();
    QByteArray passwordByteArray = password.toUtf8();

    QString url =
            "https://www.fanny-leicht.de/j34/index.php/component/fannysubstitutionplan?task=api_login&username=" +
            usernameByteArray.toBase64() + "&password=" + passwordByteArray.toBase64() + "&loginIsBase64=true";
    qDebug() << url;
    // send the request
    QVariantMap ret = this->senddata(QUrl(url));

    if(ret["status"].toInt() == 200){
        QJsonDocument jsonDoc = QJsonDocument::fromJson(ret["text"].toString().toUtf8());

        if(jsonDoc.toVariant().toMap()["result"].toInt() == 200) {

            this->token = jsonDoc.toVariant().toMap()["data"].toMap()["token"].toString();

            if(permanent){
                // if the user wants to say logged in, store the username and password to the settings file
                pGlobalAppSettings->writeSetting("permanent", "1");
                pGlobalAppSettings->writeSetting("token", this->token);
                pGlobalAppSettings->writeSetting("password", password);
            }

            // set state to loggedIn
            this->setState("loggedIn");

            qDebug() << "+----- logged in -----+";

            // return success
            return 200;
        }
        else {
            ret["status"] = jsonDoc.toVariant().toMap()["result"].toInt();
        }
    }

    // if not 200 was returned -> error -> return the return code
    this->setState("notLoggedIn");
    // -> reset the stored credentinals
    pGlobalAppSettings->writeSetting("permanent", "0");
    pGlobalAppSettings->writeSetting("token", "");
    return ret["status"].toInt();
}

int ServerConn::logout()
{
    // reset the data stored in the class
    this->token = "";

    // reset the data stored in the settings
    pGlobalAppSettings->writeSetting("permanent", "0");
    pGlobalAppSettings->writeSetting("token", "");

    this->setState("notLoggedIn");

    qDebug() << "+----- logout -----+";

    // return success
    return(200);
}

int ServerConn::getEvents(QString day)
{
    // day: 0-today; 1-tomorrow
    if(this->state != "loggedIn"){
        return(401);
    }

    // add the data to the request
    QUrlQuery pdata;
    pdata.addQueryItem("token", this->token);
    pdata.addQueryItem("mode", pGlobalAppSettings->loadSetting("teacherMode") == "true" ? "1":"0");
    pdata.addQueryItem("day", day);

    // send the request
    QVariantMap ret = this->senddata(QUrl("https://www.fanny-leicht.de/j34/index.php/component/fannysubstitutionplan?task=api_getData&token=" + token
                                          + "&mode=" + (pGlobalAppSettings->loadSetting("teacherMode") == "true" ? "1":"0") + "&day=" + day));

    if(ret["status"].toInt() != 200){
        // if the request didn't result in a success, clear the old events, as they are probaply incorrect and return the error code
        this->m_events.clear();

        if(ret["status"].toInt() == 401){
            // if the stats code is 401 -> userdata is incorrect
            qDebug() << "+----- checkconn: user data is incorrect -----+";
            logout();
        }

        return ret["status"].toInt();
    }


    // get the filers list for later usage
    QList<QStringList> filtersList = pGlobalAppSettings->readFilters();

    // remove all elements from the filters list, that do not match the current mode ( teacher / student ) of the app
    for(int i = 0; i < filtersList.length(); i++){
        QStringList filterList = filtersList[i];
        if( !(pGlobalAppSettings->loadSetting("teacherMode") == "true" ? filterList[2] == "t":filterList[2] == "s") ){
            filtersList.removeAt(i);
            i = i-1;
        }
    }

    // list to be returned
    QList<QStringList> tmpEvents;
    QStringList tmpEventHeader;

    //qDebug() << jsonString;
    QJsonDocument jsonFilters = QJsonDocument::fromJson(ret["text"].toString().toUtf8());

    // array with tghe whole response in it
    QJsonObject JsonArray = jsonFilters.object();

    // get the version of the json format
    QString version = JsonArray.value("version").toString();
    QStringList versionList = version.split(".");
    if(versionList.length() < 3){
        return(900);
    }

    int versionMajor = version.split(".")[0].toInt();
    int versionMinor = version.split(".")[1].toInt();
    //int versionRevision = version.split(".")[2].toInt();

    if(versionMajor > this->apiVersion[0] || versionMinor > this->apiVersion[1]){
        return(904);
    }

    // get parse the document out of the return
    QJsonObject dataArray = JsonArray.value("data").toObject();

    // get the header data
    tmpEventHeader.append(dataArray.value("targetDate").toString());
    tmpEventHeader.append(dataArray.value("refreshDate").toString());
    tmpEventHeader.append(dataArray.value("stewardingClass").toString());

    // expand the length of the header list to seven to prevent list out of range errors
    while (tmpEventHeader.length() < 7) {
        tmpEventHeader.append("");
    }

    // append the header to the temporyry event list
    tmpEvents.append(tmpEventHeader);

    // get the event data
    QJsonArray eventsArray = dataArray.value("events").toArray();

    for(int i=0; i<eventsArray.count(); i++){
        // get the current event-list out of the array
        QJsonArray eventArray = eventsArray[i].toArray();

        // lst to store the current event
        QStringList tmpEventList;

        // extract values from array
        foreach(const QJsonValue & key, eventArray){
            // and append them to the temporyry list
            tmpEventList.append(key.toString());
        }

        while (tmpEventList.length() < 7) {
            // enshure that the list contains at least seven items (to prevent getting list out of range errors)
            tmpEventList.append("");
        }

        if(filtersList.isEmpty()){
            // if there are no filters append the event immideatly
            tmpEvents.append(tmpEventList);
        }
        else {
            // if there is at least one filter, check if the event matches it
            foreach(QStringList filter, filtersList){
                // go through all filters and check if one of them matches the event
                // always append the first row, as it is the legend

                if((tmpEventList[0].contains(filter[0]) && tmpEventList[0].contains(filter[1])) || i == 0){
                    // append the eventList to the temporary event list
                    tmpEvents.append(tmpEventList);
                    // terminate the loop
                    break;
                }
            }
        }
    }

    // check if there is any valid data
    if(tmpEvents.length() == 0 || tmpEvents.length() == 1) {
        // no data was delivered at all -> the server encountered a parse error
        tmpEvents.clear();
        ret["status"].setValue(900);
    }
    else if(tmpEvents.length() == 2) {
        // remove the last (in this case the second) element, as it is unnecessary (it is the legend -> not needed when there is no data)
        tmpEvents.takeLast();
        // set return code to 'no data' (901)
        ret["status"].setValue(901);
    }

    this->m_events = tmpEvents;
    return(ret["status"].toInt());
}

int ServerConn::openEventPdf(QString day) {
    // day: 0-today; 1-tomorrow
    if(this->state != "loggedIn"){
        return 401;
    }

    if(pGlobalAppSettings->loadSetting("localDocPathError") == "true") {
        // we have no local document path to work with -> this is not going to work!
        return 905;
    }

    // add the data to the request
    QUrlQuery pdata;
    pdata.addQueryItem("token", this->token);
    pdata.addQueryItem("mode", pGlobalAppSettings->loadSetting("teacherMode") == "true" ? "1":"0");
    pdata.addQueryItem("day", day);
    pdata.addQueryItem("asPdf", "true");

    // send the request
    QVariantMap ret = this->senddata(QUrl("https://www.fanny-leicht.de/j34/index.php/component/fannysubstitutionplan?task=api_getData&token=" + token
                                          + "&mode=" + (pGlobalAppSettings->loadSetting("teacherMode") == "true" ? "1":"0") + "&day=" + day + "&asPdf=true"), true);

    if(ret["status"].toInt() != 200){
        // if the request didn't result in a success, clear the old events, as they are probaply incorrect and return the error code
        this->m_events.clear();

        if(ret["status"].toInt() == 401){
            // if the stats code is 401 -> userdata is incorrect
            qDebug() << "+----- checkconn: user data is incorrect -----+";
            logout();
        }

        return ret["status"].toInt();
    }

    QString path = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QString filname = (QString(pGlobalAppSettings->loadSetting("teacherMode") == "true" ? "l":"s") + QString(day == "0" ? "heute":"morgen" ));
    QFile file(mDocumentsWorkPath + "/" + filname + ".pdf");
    file.remove();
    file.open(QIODevice::ReadWrite);
    file.write(ret["data"].toByteArray());
    file.close();

    this->fileHelper->viewFile(mDocumentsWorkPath + "/" + filname + ".pdf", "SMorgen", "application/pdf", 1);

    return 200;
}

int ServerConn::getFoodPlan()
{
    // list with all data keys which need to be read from the API
    QStringList foodplanDataKeys = { "cookteam", "date", "mainDish", "mainDishVeg", "garnish", "dessert" };
    QString foodplanDateKey = "date";

    QString url = "http://www.treffpunkt-fanny.de/images/stories/dokumente/Essensplaene/api/TFfoodplanAPI.php?dataCount=10&dataMode=days&dateFormat=U&dataFromTime=now";
    // construct the URL with all requested fields
    foreach(QString foodplanDataKey, foodplanDataKeys){
        url.append("&fields[]="+foodplanDataKey);
    }

    // send the request to the server
    QVariantMap ret = this->senddata(QUrl(url));

    if(ret["status"].toInt() != 200){
        // if the request didn't result in a success, return the error code

        // if the request failed but there is still old data available
        if(!this->m_weekplan.isEmpty()){
            // set the status code to 902 (old data)
            ret["status"].setValue(902);
        }

        return(ret["status"].toInt());
    }

    // list to be returned
    // m_weekplan is a list, that contains a list for each day, which contains: cookteam, date, main dish, vagi main dish, garnish(Beilage) and Dessert.
    QList<QStringList> tmpWeekplan;

    //qDebug() << jsonString;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(ret["text"].toString().toUtf8());
    //qDebug() << ret["text"].toString();
    // array with the whole response in it
    QJsonArray foodplanDays = jsonDoc.array();

    foreach(QJsonValue foodplanDay, foodplanDays){
        QStringList tmpFoodplanDayList;

        foreach(QString foodplanDataKey, foodplanDataKeys){
            QString dataValue = foodplanDay.toObject().value(foodplanDataKey).toString();
            if(foodplanDataKey == foodplanDateKey){
                QDateTime date;
                date.setSecsSinceEpoch(uint(dataValue.toInt()));
                date.setTimeSpec(Qt::UTC);

                // get the current date and time
                QDateTime currentDateTime = QDateTime::currentDateTimeUtc();

                //---------- convert the date to a readable string ----------
                QString readableDateString;

                if(date.date() == currentDateTime.date()){
                    // the given day is today
                    readableDateString = "Heute";
                }
                else if (date.toTime_t() < ( currentDateTime.toTime_t() + ( 48 * 60 * 60 ) )) {
                    // the given day is tomorrow
                    readableDateString = "Morgen";
                }
                else {
                    readableDateString = date.toString("dddd, d.M.yy");
                }

                dataValue = readableDateString;
            }

            tmpFoodplanDayList.append( dataValue );
        }

        tmpWeekplan.append(tmpFoodplanDayList);

    }

    // write data to global foodplan
    this->m_weekplan = tmpWeekplan;

    // check if there is any valid data
    if(this->m_weekplan.isEmpty()){
        // no data
        return(901);
    }

    // success
    return(200);
}

QVariantMap ServerConn::senddata(QUrl serviceUrl, bool raw)
{
    // create network manager
    QNetworkAccessManager * networkManager = new QNetworkAccessManager();

    QVariantMap ret; //this is a custom type to store the return-data

    // Create network request
    QNetworkRequest request(serviceUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");

    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::TlsV1_2);
    request.setSslConfiguration(config);

    //send a POST request with the given url and data to the server

    QNetworkReply *reply;

    // loop to wait until the request has finished before processing the data
    QEventLoop loop;
    // timer to cancel the request after 3 seconds
    QTimer timer;
    timer.setSingleShot(true);

    // quit the loop when the request finised
    loop.connect(networkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
    // or the timer timed out
    loop.connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
    // start the timer
    timer.start(10000);

    this->updateDownloadProgress(0, 1);
    reply = networkManager->get(request);
    connect(reply, &QNetworkReply::sslErrors, this, [=](){ reply->ignoreSslErrors(); });

    connect(reply, SIGNAL(downloadProgress(qint64, qint64)),
            this, SLOT(updateDownloadProgress(qint64, qint64)));

    // start the loop
    loop.exec();

    if(!timer.isActive()) {
        // timeout
        return {{"status", 0}};
    }

    //get the status code
    QVariant status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    ret.insert("status", status_code.toInt());

    //get the full text response
    if(!raw) {
        ret.insert("text", QString::fromUtf8(reply->readAll()));
    }
    else {
        ret.insert("data", reply->readAll());
    }

    // delete the reply object
    reply->deleteLater();

    // delete the newtwork access manager object
    networkManager->deleteLater();

    //return the data
    return(ret);
}

void ServerConn::updateDownloadProgress(qint64 read, qint64 total)
{
    double progress;

    if(total <= 0)
        progress = 0;
    else
        progress = (double(read) / double(total));

    if(progress < 0)
        progress = 0;

    this->downloadProgress = progress;
    emit this->downloadProgressChanged();
}

QString ServerConn::getState() {
    return(this->state);
}

void ServerConn::setState(QString state) {

    if(state != this->state){
        qDebug() << "+----- serverconn has new state: " << state << " -----+";
        this->state = state;
        this->stateChanged(this->state);
    }
}

double ServerConn::getDownloadProgress() {
    return this->downloadProgress;
}

ServerConn::~ServerConn()
{
    qDebug("+----- ServerConn destruktor -----+");
}
