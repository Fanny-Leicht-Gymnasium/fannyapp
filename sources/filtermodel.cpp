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

#include "headers/filtermodel.h"

FilterModel::FilterModel(QObject *parent ) : QAbstractListModel(parent)
{
    m_filters.clear();

    QList<QStringList> filtersList = pGlobalAppSettings->readFilters();

    foreach(QStringList filterList, filtersList){
        m_filters.append({filterList[0], filterList[1], filterList[2]});
    }
}

int FilterModel::rowCount(const QModelIndex &) const
{
    return m_filters.count();
}

QVariant FilterModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < rowCount())
        switch (role) {
        case GradeRole: return m_filters.at(index.row()).grade;
        case ClassLetterRole: return m_filters.at(index.row()).classLetter;
        case RoleRole: return m_filters.at(index.row()).role;
        default: return QVariant();
    }
    return QVariant();
}

QHash<int, QByteArray> FilterModel::roleNames() const
{
    static const QHash<int, QByteArray> roles {
        { GradeRole, "grade" },
        { ClassLetterRole, "classLetter" },
        { RoleRole, "role"}
    };
    return roles;
}

QVariantMap FilterModel::get(int row) const
{
    const Filter filter = m_filters.value(row);
    return { {"grade", filter.grade}, {"classLetter", filter.classLetter}, {"role", filter.role} };
}

void FilterModel::append(const QString &grade, const QString &classLetter, const QString &role)
{

    foreach(Filter filter, this->m_filters){
        if(filter.grade == grade && filter.classLetter == classLetter){
            // dublicates aren't allowed
            return;
        }
    }

    int row = 0;
    while (row < m_filters.count() && grade.toInt() > m_filters.at(row).grade.toInt()){
        row++;
    }

    while (row < m_filters.count() && classLetter > m_filters.at(row).classLetter && grade.toInt() == m_filters.at(row).grade.toInt()) {
        row++;
    }
    beginInsertRows(QModelIndex(), row, row);
    m_filters.insert(row, {grade, classLetter, role});
    endInsertRows();

    QList<QStringList> filtersList;
    filtersList.clear();

    foreach(Filter filter, this->m_filters){
        filtersList.append({filter.grade, filter.classLetter, filter.role});
    }

    pGlobalAppSettings->writeFilters(filtersList);

}

void FilterModel::remove(int row)
{
    if (row < 0 || row >= m_filters.count())
        return;

    beginRemoveRows(QModelIndex(), row, row);
    m_filters.removeAt(row);
    endRemoveRows();

    QList<QStringList> filtersList;
    filtersList.clear();

    foreach(Filter filter, this->m_filters){
        filtersList.append({filter.grade, filter.classLetter, filter.role});
    }

    pGlobalAppSettings->writeFilters(filtersList);
}
