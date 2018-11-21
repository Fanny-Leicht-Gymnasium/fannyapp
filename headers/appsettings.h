#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QObject>
#include <QSettings>
#include <QStandardPaths>

class AppSettings : public QObject
{
    Q_OBJECT
public:
    explicit AppSettings(QObject *parent = nullptr);
    ~AppSettings();

    Q_INVOKABLE QString loadSetting(const QString &key);
    Q_INVOKABLE void writeSetting(const QString &key, const QVariant &variant);

    QSettings *settingsManager;

signals:

public slots:
};
extern AppSettings * pGlobalAppSettings;

#endif // APPSETTINGS_H
