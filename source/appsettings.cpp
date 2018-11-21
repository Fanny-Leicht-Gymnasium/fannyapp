#include "headers/appsettings.h"

AppSettings * pGlobalAppSettings = NULL;

AppSettings::AppSettings(QObject* parent)
    :QObject(parent)
{
    QString path = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    qDebug(path.toLatin1());
    this->settingsManager = new QSettings(path+"/fannyapp/settings.ini", QSettings::IniFormat);

    qDebug("AppSettings konstruktor");
    if(loadSetting("init") == "false"){
        this->writeSetting("init", 0);
    }
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

AppSettings::~AppSettings()
{
    delete settingsManager;
}

