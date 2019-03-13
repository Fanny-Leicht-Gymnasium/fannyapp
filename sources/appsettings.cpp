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

#include "headers/appsettings.h"

AppSettings * pGlobalAppSettings = nullptr;

AppSettings::AppSettings(QObject* parent)
    :QObject(parent)
{
    qDebug() << "+----- AppSettings konstruktor -----+";

    pGlobalAppSettings = this;

    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    qDebug() << "+----- Settings Path:" << path << " -----+";

    this->settingsManager = new QSettings(path+"/fannyapp/settings.ini", QSettings::IniFormat);

    if(loadSetting("init") == "false"){
        this->writeSetting("init", 0);
    }
    if(loadSetting("grade") == "false"){
        this->writeSetting("grade", 5);
    }
    if(loadSetting("theme") == "false"){
        this->writeSetting("theme", "Light");
    }

    this->filtersFile = new QFile(path + "/fannyapp/filters.json");
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

AppSettings::~AppSettings()
{
    qDebug("+----- AppSettings destruktor -----+");
    delete settingsManager;
}

