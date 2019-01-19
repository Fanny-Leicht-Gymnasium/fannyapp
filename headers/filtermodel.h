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

#ifndef FILTERMODEL_H
#define FILTERMODEL_H

#include <QAbstractListModel>
#include <QtDebug>
#include "serverconn.h"

class FilterModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit FilterModel(QObject *parent = nullptr);

    enum FilterRole {
        GradeRole = Qt::DisplayRole,
        ClassLetterRole,
        RoleRole
    };
    Q_ENUM(FilterRole)

    int rowCount(const QModelIndex & = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QVariantMap get(int row) const;
    Q_INVOKABLE void append(const QString &grade, const QString &classLetter, const QString &role);
    Q_INVOKABLE void remove(int row);

private:
    struct Filter {
        QString grade;
        QString classLetter;
        QString role;
    };

    QList<Filter> m_filters;
};

#endif // FILTERMODEL_H
