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

#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QFile>
#include <QObject>
#include <QtDebug>
#include <QSettings>
#include <QJsonArray>
#include <QJsonDocument>
#include <QStandardPaths>

class AppSettings : public QObject
{
    Q_OBJECT
public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    Q_INVOKABLE QString loadSetting(const QString &key);
    Q_INVOKABLE void writeSetting(const QString &key, const QVariant &variant);

    QList<QStringList> readFilters();
    void writeFilters(QList<QStringList> list);

    QSettings *settingsManager;
    QFile * filtersFile;

signals:

public slots:
};
extern AppSettings * pGlobalAppSettings;

#endif // APPSETTINGS_H
