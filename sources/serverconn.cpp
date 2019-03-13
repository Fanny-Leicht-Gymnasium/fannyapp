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
    qDebug("+----- ServerConn konstruktor -----+");
    pGlobalServConn = this;

    // check login state
    int perm = pGlobalAppSettings->loadSetting("permanent").toInt();
    qDebug() << "+----- login state: " << perm << " -----+";

    if(perm == 1){
        // permanent login -> restore login
        this->username = pGlobalAppSettings->loadSetting("username");
        this->password = pGlobalAppSettings->loadSetting("password");

        this->setState("loggedIn");
    }
    else {
        this->setState("notLoggedIn");
    }

    this->checkConnTimer = new QTimer();
    this->checkConnTimer->setInterval(1000);
    this->checkConnTimer->setSingleShot(true);
    connect(checkConnTimer, SIGNAL(timeout()), this, SLOT(checkConn()));
    this->checkConnTimer->start();
}

int ServerConn::login(QString username, QString password, bool permanent)
{

    // add the data to the request
    QUrlQuery pdata;
    pdata.addQueryItem("username", username);
    pdata.addQueryItem("password", password);

    // send the request
    ReturnData_t ret = this->senddata(QUrl("https://www.fanny-leicht.de/j34/templates/g5_helium/intern/events.php"), pdata);

    if(ret.status_code == 200){
        // if not 200 was returned -> user data was correct
        // store username and password in the class variables
        this->username = username;
        this->password = password;

        if(permanent){
            // if the user wants to say logged in, store the username and password to the settings file
            pGlobalAppSettings->writeSetting("permanent", "1");
            pGlobalAppSettings->writeSetting("username", username);
            pGlobalAppSettings->writeSetting("password", password);
        }

        // set state to loggedIn
        this->setState("loggedIn");

        qDebug() << "+----- logged in -----+";

        // return success
        return(200);
    }
    else {
        // if not 200 was returned -> error -> return the return code
        this->setState("notLoggedIn");
        // -> reset the stored credentinals
        pGlobalAppSettings->writeSetting("permanent", "0");
        pGlobalAppSettings->writeSetting("username", "");
        pGlobalAppSettings->writeSetting("password", "");
        return(ret.status_code);
    }
}

int ServerConn::logout()
{
    // reset the data stored in the class
    this->username = "";
    this->password = "";

    // reset the data stored in the settings
    pGlobalAppSettings->writeSetting("permanent", "0");
    pGlobalAppSettings->writeSetting("username", "");
    pGlobalAppSettings->writeSetting("password", "");

    this->setState("notLoggedIn");

    qDebug() << "+----- logout -----+";

    // return success
    return(200);
}

int ServerConn::checkConn()
{
    if(this->state == "notLoggedIn"){
        return(903);
    }

    // add the data to the request
    QUrlQuery pdata;
    pdata.addQueryItem("username", this->username);
    pdata.addQueryItem("password", this->password);

    // send the request
    ReturnData_t ret = this->senddata(QUrl("https://www.fanny-leicht.de/j34/templates/g5_helium/intern/events.php"), pdata);

    if(ret.status_code == 401){
        // if the stats code is 401 -> userdata is incorrect
        authErrorCount ++;

        if(authErrorCount > 3){
            qDebug() << "+----- checkconn: user data is incorrect -----+";
            logout();
        }
    }

    this->checkConnTimer->start();
    return(ret.status_code);
}

int ServerConn::getEvents(QString day)
{
    // day: 0-today; 1-tomorrow
    if(this->state != "loggedIn"){
        return(401);
    }

    // add the data to the request
    QUrlQuery pdata;
    pdata.addQueryItem("username", this->username);
    pdata.addQueryItem("password", this->password);
    pdata.addQueryItem("mode", pGlobalAppSettings->loadSetting("teacherMode") == "true" ? "1":"0");
    pdata.addQueryItem("day", day);

    // send the request
    ReturnData_t ret = this->senddata(QUrl("https://www.fanny-leicht.de/j34/templates/g5_helium/intern/events.php"), pdata);

    if(ret.status_code != 200){
        // if the request didn't result in a success, clear the old events, as they are probaply incorrect and return the error code
        this->m_events.clear();
        return(ret.status_code);
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
    QJsonDocument jsonFilters = QJsonDocument::fromJson(ret.text.toUtf8());

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
    if(tmpEvents.length() < 3){
        // remove the last (in this case the second) element, as it is unnecessary (it is the legend -> not needed when there is no data)
        tmpEvents.takeLast();
        // set return code to 'no data' (901)
        ret.status_code = 901;
    }

    this->m_events = tmpEvents;
    return(ret.status_code);
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

    QUrlQuery pdata;
    // send the request to the server
    ReturnData_t ret = this->senddata(QUrl(url), pdata);

    if(ret.status_code != 200){
        // if the request didn't result in a success, return the error code

        // if the request failed but there is still old data available
        if(!this->m_weekplan.isEmpty()){
            // set the status code to 902 (old data)
            ret.status_code = 902;
        }

        return(ret.status_code);
    }

    // list to be returned
    // m_weekplan is a list, that contains a list for each day, which contains: cookteam, date, main dish, vagi main dish, garnish(Beilage) and Dessert.
    QList<QStringList> tmpWeekplan;

    //qDebug() << jsonString;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(ret.text.toUtf8());
    //qDebug() << ret.text;
    // array with the whole response in it
    QJsonArray foodplanDays = jsonDoc.array();

    foreach(QJsonValue foodplanDay, foodplanDays){
        QStringList tmpFoodplanDayList;

        foreach(QString foodplanDataKey, foodplanDataKeys){
            QString dataValue = foodplanDay.toObject().value(foodplanDataKey).toString();
            if(foodplanDataKey == foodplanDateKey){
                QDateTime date;
                date.setTime_t(uint(dataValue.toInt()));

                // get the current date and time
                QDateTime currentDateTime = QDateTime::currentDateTimeUtc();

                //---------- convert the date to a readable string ----------
                QString readableDateString;

                if(date.date() == currentDateTime.date()){
                    // the given day is today
                    readableDateString = "Heute";
                }
                else if (date.toTime_t() < ( currentDateTime.toTime_t() + ( 24 * 60 * 60 ))) {
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

ReturnData_t ServerConn::senddata(QUrl serviceUrl, QUrlQuery pdata)
{

    QNetworkAccessManager * networkManager = new QNetworkAccessManager();

    ReturnData_t ret; //this is a custom type to store the return-data

    // Create network request
    QNetworkRequest request(serviceUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");

    QSslConfiguration config = QSslConfiguration::defaultConfiguration();
    config.setProtocol(QSsl::TlsV1_2);
    request.setSslConfiguration(config);

    //send a POST request with the given url and data to the server

    QNetworkReply *reply;

    reply = networkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());
    connect(reply, &QNetworkReply::sslErrors, this, [=](){ reply->ignoreSslErrors(); });
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
    // start the loop
    loop.exec();

    //get the status code
    QVariant status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    ret.status_code = status_code.toInt();

    //get the full text response
    ret.text = QString::fromUtf8(reply->readAll());

    // delete the reply object
    delete reply;

    // delete the newtwork access manager object
    delete networkManager;

    //return the data
    return(ret);
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

ServerConn::~ServerConn()
{
    qDebug("+----- ServerConn destruktor -----+");
}
