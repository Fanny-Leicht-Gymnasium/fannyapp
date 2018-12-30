#include "headers/appsettings.h"

AppSettings * pGlobalAppSettings = nullptr;

AppSettings::AppSettings(QObject* parent)
    :QObject(parent)
{
    qDebug("+----- AppSettings konstruktor -----");

    pGlobalAppSettings = this;

    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    qDebug() << "+----- Settings Path:" << path;

    this->settingsManager = new QSettings(path+"/fannyapp/settings.ini", QSettings::IniFormat);

    if(loadSetting("init") == "false"){
        this->writeSetting("init", 0);
    }
    if(loadSetting("grade") == "false"){
        this->writeSetting("grade", 5);
    }

    this->filtersFile = new QFile(path + "/fannyapp/filters.json");

    //QList<QStringList> filters = {{"5", "d"}, {"6", "c"}, {"11", ""}};

    //writeFilters(filters);
    //qDebug() << readFilters();
}

QString AppSettings::loadSetting(const QString &key)
{
    this->settingsManager->beginGroup("AppSettings");
    QString value = this->settingsManager->value(key , false).toString();
    this->settingsManager->endGroup();
    return(value);
}

void AppSettings::writeSetting(const QString &key, const QVariant &variant)
{
    this->settingsManager->beginGroup("AppSettings");
    this->settingsManager->setValue(key , variant);
    this->settingsManager->endGroup();
}

QList<QStringList> AppSettings::readFilters() {

    // list to be returned
    QList<QStringList> filtersList;

    this->filtersFile->open(QFile::ReadOnly | QFile::Text);

    QString jsonString = this->filtersFile->readAll();

    this->filtersFile->close();

    //qDebug() << jsonString;
    QJsonDocument jsonFilters = QJsonDocument::fromJson(jsonString.toUtf8());
    // array with all filters in it
    QJsonArray filtersArray = jsonFilters.array();
    foreach(const QJsonValue & value, filtersArray){
        // array of a single filter
        QJsonArray filterArray = value.toArray();

        QStringList tmpFilterList;

        // extract values from array
        foreach(const QJsonValue & key, filterArray){
            tmpFilterList.append(key.toString());
        }

        while (tmpFilterList.length() < 3) {
            tmpFilterList.append("");
        }

        filtersList.append(tmpFilterList);
    }

    for(int i = 0; i < filtersList.length(); i++){
        QStringList filterList = filtersList[i];
        if( filterList[2] == "" ){
           filtersList.removeAt(i);
           i = i-1;
        }
    }

    return(filtersList);
}

void AppSettings::writeFilters(QList<QStringList> list) {

    // string to write to file
    QString jsonString;
    QJsonArray filtersArray;

    for(int i = 0; i < list.length(); i++){
        QStringList filterList = list[i];
        if( filterList[2] == "" ){
           list.removeAt(i);
           i = i-1;
        }
    }

    foreach(QStringList filter, list){
        QJsonArray filterArray;

        while (filter.length() < 3) {
            filter.append("");
        }

        filterArray.append(filter[0]);
        filterArray.append(filter[1]);
        filterArray.append(filter[2]);

        filtersArray.append(filterArray);
    }

    QJsonDocument filtersDoc(filtersArray);
    //qDebug() << filtersDoc.toJson();

    this->filtersFile->open(QIODevice::ReadWrite);

    this->filtersFile->resize(0);

    this->filtersFile->write(filtersDoc.toJson());

    this->filtersFile->close();
}

QStringList AppSettings::readFiltersQml() {

    QStringList filtersList;

    foreach(QStringList filterList, this->readFilters()){
        filtersList.append(filterList[0]+"|"+filterList[1]);
    }

    return(filtersList);
}

void AppSettings::writeFiltersQml(QStringList) {

}

AppSettings::~AppSettings()
{
    delete settingsManager;
}

