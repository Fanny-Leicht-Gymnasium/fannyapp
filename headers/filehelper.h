#ifndef FILEHELPER_H
#define FILEHELPER_H

#include <QObject>
#include <QDebug>

#if defined(Q_OS_IOS)
    mPlatformShareUtils = new IosShareUtils(this);
#elif defined(Q_OS_ANDROID)
#include <QtAndroid>
#include <QAndroidActivityResultReceiver>
#else
#include <QDesktopServices>
#include <QUrl>
#endif

class FileHelper : public QObject
        #if defined(Q_OS_ANDROID)
        , public QAndroidActivityResultReceiver
        #endif
{
    Q_OBJECT
public:
    explicit FileHelper(QObject *parent = nullptr);

    void viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId);
#if defined(Q_OS_ANDROID)
    void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data);
    void onActivityResult(int requestCode, int resultCode);
    static FileHelper* getInstance();
#endif

private:
#if defined(Q_OS_IOS)
#elif defined(Q_OS_ANDROID)
    void processActivityResult(int requestCode, int resultCode);
    static FileHelper* mInstance;
#else
#endif

signals:
    void shareEditDone(int requestCode);
    void shareFinished(int requestCode);
    void shareNoAppAvailable(int requestCode);
    void shareError(int requestCode, QString message);

public slots:
};

#endif // FILEHELPER_H
