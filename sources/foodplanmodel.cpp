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

#include "headers/foodplanmodel.h"

FoodPlanModel::FoodPlanModel(QObject *parent) : QAbstractListModel(parent)
{
    // foodplan constructor
    // is called when the FoodplanView is loaded

    // list
    m_foodPlan.clear();

    // convert the stringlist from the serverconn to a Dish-list
    foreach(QList<QString>day, pGlobalServConn->m_weekplan){
        m_foodPlan.append({day[0], day[1], day[2], day[3], day[4], day[5]});
    }
}

int FoodPlanModel::rowCount(const QModelIndex &) const
{
    return m_foodPlan.count();
}

QVariant FoodPlanModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < rowCount())
        switch (role) {
        case CookteamRole: return m_foodPlan.at(index.row()).cookteam;
        case DateRole: return m_foodPlan.at(index.row()).date;
        case MainDishRole: return m_foodPlan.at(index.row()).mainDish;
        case MainDishVegRole: return m_foodPlan.at(index.row()).mainDishVeg;
        case GarnishRole: return m_foodPlan.at(index.row()).garnish;
        case DessertRole: return m_foodPlan.at(index.row()).dessert;
        default: return QVariant();
    }
    return QVariant();
}

QHash<int, QByteArray> FoodPlanModel::roleNames() const
{
    static const QHash<int, QByteArray> roles {
        { CookteamRole, "cookteam" },
        { DateRole, "date" },
        { MainDishRole, "mainDish" },
        { MainDishVegRole, "mainDishVeg" },
        { GarnishRole, "garnish" },
        { DessertRole, "dessert" }
    };
    return roles;
}

QVariantMap FoodPlanModel::get(int row) const
{
    const Dish foodPlan = m_foodPlan.value(row);
    return { {"cookteam", foodPlan.cookteam}, {"date", foodPlan.date}, {"mainDish", foodPlan.mainDish}, {"mainDishVeg", foodPlan.mainDishVeg}, {"garnish", foodPlan.garnish}, {"dessert", foodPlan.dessert} };
}

FoodPlanModel::~FoodPlanModel(){

}

