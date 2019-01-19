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
