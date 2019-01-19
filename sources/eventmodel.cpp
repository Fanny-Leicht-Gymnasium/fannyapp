#include "headers/eventmodel.h"

EventModel::EventModel(QObject *parent) : QAbstractListModel(parent)
{
    // event constructor
    // is called when the EventView is loaded

    // list
    m_events.clear();

    // convert the stringlist from the serverconn to a Day-list
    foreach(QList<QString>day, pGlobalServConn->m_events){
        m_events.append({day[0], day[1], day[2], day[3], day[4], day[5], day[6]});
    }
}

int EventModel::rowCount(const QModelIndex &) const
{
    return m_events.count();
}

QVariant EventModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < rowCount())
        switch (role) {
        case GradeRole: return m_events.at(index.row()).grade;
        case HourRole: return m_events.at(index.row()).hour;
        case ReplaceRole: return m_events.at(index.row()).replace;
        case SubjectRole: return m_events.at(index.row()).subject;
        case RoomRole: return m_events.at(index.row()).room;
        case ToRole: return m_events.at(index.row()).to;
        case TextRole: return m_events.at(index.row()).text;
        default: return QVariant();
    }
    return QVariant();
}

QHash<int, QByteArray> EventModel::roleNames() const
{
    static const QHash<int, QByteArray> roles {
        { GradeRole, "grade" },
        { HourRole, "hour" },
        { ReplaceRole, "replace" },
        { SubjectRole, "subject" },
        { RoomRole, "room" },
        { ToRole, "to" },
        { TextRole, "text" }
    };
    return roles;
}

QVariantMap EventModel::get(int row) const
{
    const Day foodPlan = m_events.value(row);
    return { {"grade", foodPlan.grade}, {"hour", foodPlan.hour}, {"replace", foodPlan.replace}, {"subject", foodPlan.subject}, {"room", foodPlan.room}, {"to", foodPlan.to}, {"text", foodPlan.text} };
}

EventModel::~EventModel()
{

}
