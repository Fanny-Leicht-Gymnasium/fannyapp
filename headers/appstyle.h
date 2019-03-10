#ifndef APPSTYLE_H
#define APPSTYLE_H

#include <QObject>
#include <QVariant>

#include "appsettings.h"

class AppStyle : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant style READ getStyle NOTIFY styleChanged)

public:
    explicit AppStyle(QObject *parent = nullptr);

private:
    QVariant lightTheme;
    QVariant darkTheme;

    QVariant * currentTheme;

signals:
    void styleChanged();

public slots:
    QVariant getStyle();
    Q_INVOKABLE void changeTheme();
};

#endif // APPSTYLE_H
