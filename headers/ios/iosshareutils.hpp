// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#ifndef __IOSSHAREUTILS_H__
#define __IOSSHAREUTILS_H__

#include <QObject>

class IosShareUtils : public QObject
{
    Q_OBJECT

public:
    explicit IosShareUtils(QObject *parent = 0);
    bool checkMimeTypeView(const QString &mimeType);
    bool checkMimeTypeEdit(const QString &mimeType);
    void sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);

    void handleDocumentPreviewDone(const int &requestId);

signals:
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);
};

#endif
