#ifndef EVENTMODEL_H
#define EVENTMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include "headers/serverconn.h"

class EventModel : public QAbstractListModel
{
    Q_OBJECT
public:
    EventModel(QObject *parent = nullptr);
    ~EventModel();

    enum DayRole {
        GradeRole = Qt::DisplayRole,
        HourRole,
        ReplaceRole,
        SubjectRole,
        RoomRole,
        ToRole,
        TextRole
    };
    Q_ENUM(DayRole)

    int rowCount(const QModelIndex & = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QVariantMap get(int row) const;

private:
    struct Day {
        QString grade;
        QString hour;
        QString replace;
        QString subject;
        QString room;
        QString to;
        QString text;
    };

    QList<Day> m_events;
};

#endif // EVENTMODEL_H
