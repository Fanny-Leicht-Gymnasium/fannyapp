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
