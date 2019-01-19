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

ServerConn * pGlobalServConn = nullptr;

ServerConn::ServerConn(QObject *parent) : QObject(parent)
{
    qDebug("+----- ServerConn konstruktor -----+");
    pGlobalServConn = this;
    this->networkManager = new QNetworkAccessManager();
    this->refreshNetworkManager = new QNetworkAccessManager();

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
    ReturnData_t ret = this->senddata(QUrl("http://www.fanny-leicht.de/j34/templates/g5_helium/intern/events.php"), pdata);

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
    ReturnData_t ret = this->senddata(QUrl("http://www.fanny-leicht.de/j34/templates/g5_helium/intern/events.php"), pdata);

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
    if(this->state != "loggedIn"){
        return(401);
    }

    // add the data to the request
    QUrlQuery pdata;
    pdata.addQueryItem("username", this->username);
    pdata.addQueryItem("password", this->password);
    pdata.addQueryItem("day", day);

    // send the request
    ReturnData_t ret = this->senddata(QUrl("http://www.fanny-leicht.de/j34/templates/g5_helium/intern/events.php"), pdata);

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
    // array with all filters in it
    QJsonObject dataArray = jsonFilters.object();

    // get the version of the json format
    QString version = dataArray.value("version").toString();

    // get the header data
    tmpEventHeader.append(dataArray.value("targetDate").toString());
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
    QUrlQuery pdata;
    ReturnData_t ret = this->senddata(QUrl("http://www.treffpunkt-fanny.de/fuer-schueler-und-lehrer/speiseplan.html"), pdata);

    if(ret.status_code != 200){
        // if the request didn't result in a success, return the error code

        // if the request failed but there is still old data available
        if(!this->m_weekplan.isEmpty()){
            // set the status code to 902 (old data)
            ret.status_code = 902;
        }

        return(ret.status_code);
    }

    // initialize the weekplan to store information to it
    QList<QList<QString>> temp_weekplan;

    // m_weekplan is a list, that contains a list for each day, which contains: cookteam, date, main dish, vagi main dish, garnish(Beilage) and Dessert.

    // read the whole website
    QString returnedData = ret.text;

    // remove unnecessary stuff
    returnedData.replace("\n","");
    returnedData.replace("\r","");
    returnedData.replace("\t","");

    // workaround for changing html syntax
    returnedData.replace("style=\"width: 25%;\"", "width=\"25%\"");

    // split the string at the beginning of the tables
    QStringList documentList = returnedData.split( "<table class=\"speiseplan\">" );

    // enshure that the data is valid
    if(documentList.length() < 2){
        return(900);
    }

    //---------- prepare the table of the first week ----------
    QString table1 = documentList[1];

    // enshure that the data is valid
    if(table1.split( "</table>" ).length() < 1){
        return(900);
    }

    // remove everything after "</table>"
    table1 = table1.split( "</table>" )[0];
    // remove "<tbody><tr style=\"border: 1px solid #999;\" align=\"center\" valign=\"top\">" at the beginning
    table1.remove(0,71);
    //remove "</tr></tbody>" at the end
    table1 = table1.left(table1.length() - 13);

    //split at the days to get a list of all days
    QStringList table1list = table1.split("<td width=\"25%\">");

    // enshure that the data is valid
    if(table1list.length() < 5){
        return(900);
    }

    //remove the first item, as it is empty
    table1list.takeFirst();

    //---------- prepare the table of the second week ----------
    QString table2 = documentList[2];

    // enshure that the data is valid
    if(table2.split( "</table>" ).length() < 1){
        return(900);
    }

    //remove everything after "</table>"
    table2 = table2.split( "</table>" )[0];
    //remove "<tbody><tr align=\"center\" valign=\"top\">" at the beginning
    table2.remove(0,39);
    //remove "</tr></tbody>" at the end
    table2.remove(table2.length() - 13, table2.length());

    //split at the days to get a list of all days
    QStringList table2list = table2.split("<td width=\"25%\">");

    // enshure that the data is valid
    if(table2list.length() < 5){
        return(900);
    }

    //remove the first item, as it is empty
    table2list.takeFirst();

    //---------- put both weeks into one big list ----------
    QStringList weeklist = table1list + table2list;

    //---------- go through all days and split the day-string into the different types of information ----------

    for (int i = 0; i <=7; i ++){
        if(i > weeklist.length()){
            // if the loop exceeds the length of the wweklist some kind of eror occured
            return 900;
        }

        // store item temporarly to edit it
        QString day = weeklist[i];
        // remove "</td>" at the and of the Item
        day = day.left(day.length()-5);

        // table list[i] looks now like:    | clould be:
        // <strong>cookteam</strong>        | <strong>Red Hot Chili Peppers</strong>
        // <br />                           | <br />
        // <strong>date</strong>            | <strong>26.06.2018</strong>
        // <hr />mainDish                   | <hr />Gulasch mit Kartoffeln
        // <hr />mainDishVeg                | <hr />Pellkartoffeln mit Quark
        // <hr />garnish                    | <hr />Gemischter Salat
        // <hr />dessert</td>               | <hr />Eaton Mess ( Erdbeer-Nachtisch )</td>

        // split item at strong, to get the cookteam and the date
        QStringList daylist = day.split("<strong>");
        day = "";

        // convert the list to a big string
        for (int i = 0; i <= 2; i ++){
            if(i <= daylist.length()){
                day += daylist[i];
            }
        }

        day.replace("<br />","");
        daylist = day.split("</strong>");

        // store cookteam and date in the temp_weekplan
        //temp_weekplan.append({daylist[0], daylist[1]});

        // store information in day
        // (looks like: "<hr />MainDish<hr />MainDishVeg<hr />Garnish<hr />Dessert")
        // (could be: "<hr />Gulasch mit Kartoffeln<hr />Pellkartoffeln mit Quark<hr />Gemischter Salat<hr />Eaton Mess ( Erdbeer-Nachtisch )")
        day = daylist.takeLast();
        // seperate the information
        daylist.append(day.split("<hr />"));
        // remove the item that is emplty from the list
        daylist.removeAt(2);

        //---------- check if the day is aleady over ----------

        // get the datestring
        QString dateString = daylist[1];
        // convert it to a valid QDate
        QDateTime date = QDateTime::fromString(dateString,"dd.MM.yyyy");

        // get the current date and time
        QDateTime currentDateTime = QDateTime::currentDateTimeUtc();

        // check if the given day is still in the future or today (then it is valid)
        if(date.toTime_t() > currentDateTime.toTime_t() || date.date() == currentDateTime.date()){
            // add the rest of the information to the temp_weekplan
            qDebug() << "day valid:" << daylist;

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

            qDebug() << readableDateString;

            // insert the redable tring into the daylist
            daylist[1] = readableDateString;

            // append the day to the weeklist
            temp_weekplan.append({daylist[0], daylist[1], daylist[2], daylist[3], daylist[4], daylist[5]});
        }
    }

    // write data to global foodplan
    this->m_weekplan = temp_weekplan;

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

    ReturnData_t ret; //this is a custom type to store the return-data

    // Create network request
    QNetworkRequest request(serviceUrl);
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");

    //set ssl configuration
    //send a POST request with the given url and data to the server
    QNetworkReply* reply;

    reply = this->networkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());

    // loop to wait until the request has finished before processing the data
    QEventLoop loop;
    // timer to cancel the request after 3 seconds
    QTimer timer;
    timer.setSingleShot(true);

    // quit the loop when the request finised
    loop.connect(this->networkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
    // or the timer timed out
    loop.connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
    // start the timer
    timer.start(4000);
    // start the loop
    loop.exec();

    //get the status code
    QVariant status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);

    ret.status_code = status_code.toInt();

    //get the full text response
    ret.text = QString::fromUtf8(reply->readAll());

    if(reply->isOpen()){
        delete reply;
    }

    //return the data
    return(ret);
}

QString ServerConn::getState() {
    return(this->state);
}

void ServerConn::setState(QString state) {

    if(state != this->state){
        qDebug() << "+----- serverconn has new state: " + state + " -----+";
        this->state = state;
        this->stateChanged(this->state);
    }
}

ServerConn::~ServerConn()
{
    qDebug("+----- ServerConn destruktor -----+");
    delete this->networkManager;
    delete this->refreshNetworkManager;
}
