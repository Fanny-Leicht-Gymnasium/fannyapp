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

    Q_INVOKABLE QStringList readFiltersQml();
    Q_INVOKABLE void writeFiltersQml(QStringList);

    QSettings *settingsManager;
    QFile * filtersFile;

signals:

public slots:
};
extern AppSettings * pGlobalAppSettings;

#endif // APPSETTINGS_H
