#include "headers/serverconn.h"

ServerConn * pGlobalServConn = nullptr;

ServerConn::ServerConn(QObject *parent) : QObject(parent)
{
    qDebug("+----- serverconn konstruktor -----+");
    pGlobalServConn = this;
    this->networkManager = new QNetworkAccessManager();
    this->refreshNetworkManager = new QNetworkAccessManager();

    // check login state
    int perm = pGlobalAppSettings->loadSetting("permanent").toInt();
    qDebug() << "+-- login state: " << perm;

    if(perm == 1){
        // permanent login
        // restore login
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
    //    QUrlQuery pdata;
    //    ReturnData_t ret = this->senddata(QUrl("http://www.fanny-leicht.de/static15/http.intern/sheute.pdf"), pdata);
    //    qDebug() << ret.text;

    // Create network request
    QNetworkRequest request;
    // call a non-existent file to be fast
    request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/logintest" ) );

    // pack the credentials into a string
    QString credentialsString = username + ":" + password;
    // convert it to a byte array
    QByteArray data = credentialsString.toLocal8Bit().toBase64();
    // put it into a string
    QString headerData = "Basic " + data;
    // and finally write it into the request header
    request.setRawHeader( "Authorization", headerData.toLocal8Bit() );

    // Send GET request to fanny server
    QNetworkReply*reply = networkManager->get( request );

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
    timer.start(2000);
    // start the loop
    loop.exec();

    // get the status code from the request
    int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    // 404 is a success because a non existent file was called and not 401 was returned -> user data was correct
    if(status_code == 404){
        // store username and password in the class variables
        this->username = username;
        this->password = password;

        if(permanent){
            // if the user wants to say logged in, store the username and password to the settings file
            pGlobalAppSettings->writeSetting("permanent", "1");
            pGlobalAppSettings->writeSetting("username", username);
            pGlobalAppSettings->writeSetting("password", password);
        }

        this->setState("loggedIn");

        // return success
        return(200);
    }
    else {
        // if not 404 was returned -> error -> return the return code
        this->setState("notLoggedIn");
        return(status_code);
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
    // return success
    return(200);
}

int ServerConn::checkConn()
{
    // Create request
    QNetworkRequest request;
    request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/" ) );

    // Pack in credentials
    // e.g. ZedlerDo:LxyJQB (yes, these do actually work ;)
    QString concatenatedCredentials = this->username + ":" + this->password;
    QByteArray data = concatenatedCredentials.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;
    request.setRawHeader( "Authorization", headerData.toLocal8Bit() );

    QUrlQuery pdata;
    // Send request and connect all possible signals
    QNetworkReply*reply = this->refreshNetworkManager->post(request, pdata.toString(QUrl::FullyEncoded).toUtf8());
    //QNetworkReply*reply = networkManager->get( request );

    QTimer timer;
    timer.start(3000);

    QEventLoop loop;
    loop.connect(this->refreshNetworkManager, SIGNAL(finished(QNetworkReply*)), SLOT(quit()));
    loop.connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
    loop.exec();

    int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if(status_code == 401){
        authErrorCount ++;

        if(authErrorCount > 3){
            logout();
        }
    }

    this->checkConnTimer->start();
    return(status_code);
}

void ServerConn::updateProgress(qint64 read, qint64 total)
{
    int read_int = int(read);
    int total_int = int(total);
    float percent = (float(read_int) / float(total_int));
    this->progress = percent;
    percent = int(percent);

    //    qDebug() << read << total << percent << "%";
}

float ServerConn::getProgress()
{
    return(this->progress);
}

int ServerConn::getEvents(QString day){

    // Create request
    QNetworkRequest request;
    request.setUrl( QUrl( "http://www.fanny-leicht.de/static15/http.intern/" + day + ".txt" ) );

    // Pack in credentials
    QString concatenatedCredentials = this->username + ":" + this->password;
    QByteArray data = concatenatedCredentials.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;
    request.setRawHeader("Authorization", headerData.toLocal8Bit());

    // send the request
    QNetworkReply*reply = networkManager->get(request);

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
    timer.start(2000);
    // start the loop
    loop.exec();

    // get the status code
    int status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if(status_code != 200){
        // if the request didn't result in a success, clear the old events, as they are probaply incorrect and return the error code
        this->m_events.clear();
        return(status_code);
    }

    QString eventString = reply->readAll();

//    qDebug() << "reading text file";
//    QFile * textFile = new QFile(":/samplehtml/Download File.txt");
//    if (!textFile->open(QIODevice::ReadOnly | QIODevice::Text)) {
//        qDebug() << "Load XML File Problem Couldn't open xmlfile.xml to load settings for download";
//        return 900;
//    }

//    eventString = textFile->readAll();


    // separate all lines into a list
    QStringList events = eventString.split("\n");

    // a line (one element of the list) looks like this:
    // class  hour   replace  subject  room  to        text
    // 8a     1-2    Ei       Ch       ---   Entfall   KEINE KA
    //  [     ] <-- at least two spaces between two blocks
    // 'to' and 'text' can be blank

    for(int i = 0; i < events.length(); i++){
        if(events[i] == ""){
            events.removeAt(i);
        }
    }

    // all pages of the original Event document have a similar header that gets removed by this command
    // (only the first one remains)
    events.removeDuplicates();

    // temporary list to store the events for the given day
    QList<QStringList> tmpEvents;

    // temporary list to store the header information
    QStringList tmpEventHeader;

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

    // go through the list and process every single row
    for(int x = 0; x < events.length(); x++){
        // store the event string
        QString event = events[x];

        // value to count spaces between text
        int spaceCount = 0;

        // temporary list to store the data of one day
        QStringList eventList;

        // temporary dtring to store the data of one block
        QString tmpString;

        // processing works like:
        //  go through the line char by char
        for(int i = 0;i < event.length(); i++){
            // store the char temporarly
            QCharRef tmpChar = event[i];

            // check if the char is a space
            if(tmpChar == " "){
                // if so, increase the spaceCount by one
                spaceCount ++;
            }
            else {
                // if not -> new block or part of a block started
                // could be : 8a     1 - 2 OR 8a     1 - 2
                //             here->|     OR    here->|
                // in the first case, the space counter is higer than one
                // in the second case, the space counter is exactly one
                if(spaceCount == 1){
                    // -> append a space to the temp string
                    tmpString.append(" ");
                }

                // reset the space counter
                spaceCount = 0;

                // append the current character
                tmpString.append(tmpChar);
            }

            // check if the space count is 2
            if(spaceCount == 2){
                // if so -> break between two blocks
                // could be: 8a     1 - 2
                //       here ->|

                // -> append the current tmpString to the eventList
                eventList.append(tmpString);

                // and clear the tmpString
                tmpString = "";
            }

            //qDebug() << "char= " << tmpChar << " string= " << tmpString << " list= " << eventList;
        }

        // append the remaining tmpString to the eventList
        eventList.append(tmpString);

        // fill up the eventList with blanks until it reaches the defined length
        while (eventList.length() < 7) {
            eventList.append("");
        }

        if(x < 6){
            // if the event is in the header
            // the header could look like this:
            //
            // D-70563 FANNY-LEICHT-GYMN.                       Schuljahr 2018/19 - 1. Halbjahr           Untis 2017
            // STUTTGART, F.-LEICHT-STR. 13                     gültig ab 10. September 2018         (13.12.2018 9:04)
            //
            //[Klasse 13.12. / Donnerstag Woche-A]
            //{Ordnungsdienst: Klasse 10a}
            //
            // important data:
            // () = date and time the document has been created
            // [] = date the document is made for
            // {} = class that has to clean up the scool :D
            // (brackets are not present in the document)

            // line 0 and 4 don't contain imporant information -> skip

            if (x == 1) {
                // the second line contains the creation date
                // the creation date is the third block of the line
                tmpEventHeader.append(eventList[2]);
            }
            else if (x == 2) {
                // the third line contains the target date of the document
                // the target date is the first block of the line
                tmpEventHeader.append(eventList[0]);
            }
            else if (x == 3) {
                // the third line contains the cleaning class
                // the cleaning class is the first block of the line
                tmpEventHeader.append(eventList[0]);
            }
            else if (x == 4) {
                // if the fourth line is reached
                // fill the event header
                while (tmpEventHeader.length() < 7) {
                    tmpEventHeader.append("");
                }

                // check if the header is valid
                // variable to count filled blocks
                int blocksOK = 0;
                foreach(QString block, tmpEventHeader){
                    if(block != ""){
                        blocksOK ++;
                    }
                }

                if(blocksOK != 3) {
                    // if there are more or less than 3 filled blocks, the data is invalid
                    this->m_events.clear();
                    return(900);
                }

                // swap creation and target date
                tmpEventHeader.swap(0,1);

                // and append it to the events list
                tmpEvents.append(tmpEventHeader);
            }
            else if (x == 5) {
                // the fifth row contains the labels for the different filds
                // -> append it to the events list
                tmpEvents.append(eventList);
            }

        }
        else if(filtersList.isEmpty()){
            // if there are no filters append the event immideatly
            tmpEvents.append(eventList);
        }
        else {
            // if there is at least one filter, check if the event matches it
            foreach(QStringList filter, filtersList){
                // go through all filters and check if one of them matches the event

                if((eventList[0].contains(filter[0]) && eventList[0].contains(filter[1]))){
                    // append the eventList to the temporary event list
                    tmpEvents.append(eventList);
                    // terminate the loop
                    break;
                }
            }
        }
    }

    // store the new events into the class variable
    this->m_events = tmpEvents;
    qDebug() << tmpEvents;

    // check if there is any valid data
    if(this->m_events.length() < 3){
        // remove the last (in this case the second) element, as it is unnecessary
        m_events.takeLast();
        // return no data
        return(901);
    }

    // return success
    return(200);
}

int ServerConn::getFoodPlan()
{
    // set the progress to 0
    this->progress = 0;

    // Call the webservice
    QNetworkRequest request(QUrl("http://www.treffpunkt-fanny.de/fuer-schueler-und-lehrer/speiseplan.html"));
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");

    // send a GET request to the treffpunkt fanny server
    QNetworkReply* reply;
    reply = this->networkManager->get(request);

    // update the progress during the request
    connect(reply, SIGNAL(downloadProgress(qint64, qint64)),
            this, SLOT(updateProgress(qint64, qint64)));

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
    timer.start(2000);
    // start the loop
    loop.exec();

    // get the status code
    QVariant status_code = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
    // set the progress to 1
    this->progress = 1;
    if(status_code != 200){
        // if the request didn't result in a success, return the error code

        // if the request failed but there is still old data available
        if(!this->m_weekplan.isEmpty()){
            // set the status code to 902 (old data)
            status_code = 902;
        }

        return(status_code.toInt());
    }

    // initialize the weekplan to store information to it
    QList<QList<QString>> temp_weekplan;

    // m_weekplan is a list, that contains a list for each day, which contains: cookteam, date, main dish, vagi main dish, garnish(Beilage) and Dessert.

    // read the whole website
    QString returnedData = QString::fromUtf8(reply->readAll());

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


QString ServerConn::getState() {
    return(this->state);
}

void ServerConn::setState(QString state) {
    this->state = state;
    this->stateChanged(this->state);
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
