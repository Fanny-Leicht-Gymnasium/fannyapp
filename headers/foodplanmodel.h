#ifndef FOODPLANMODEL_H
#define FOODPLANMODEL_H

#include <QAbstractListModel>
#include <QtDebug>
#include "serverconn.h"

class FoodPlanModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit FoodPlanModel(QObject *parent = nullptr);
    ~FoodPlanModel();

    enum DishRole {
        CookteamRole = Qt::DisplayRole,
        DateRole,
        MainDishRole,
        MainDishVegRole,
        GarnishRole,
        DessertRole
    };
    Q_ENUM(DishRole)

    int rowCount(const QModelIndex & = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QVariantMap get(int row) const;

private:
    struct Dish {
        QString cookteam;
        QString date;
        QString mainDish;
        QString mainDishVeg;
        QString garnish;
        QString dessert;
    };

    QList<Dish> m_foodPlan;
};

#endif // FOODPLANMODEL_H
