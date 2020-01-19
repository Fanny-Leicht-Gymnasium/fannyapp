#include "headers/filehelper.h"

#if defined(Q_OS_IOS)
#include <QUrl>
#include <QFileInfo>
#include <QDateTime>
#elif defined(Q_OS_ANDROID)
#include <QtAndroidExtras/QAndroidJniObject>
#include <jni.h>
#endif

FileHelper::FileHelper(QObject *parent) : QObject(parent)
{
#if defined(Q_OS_IOS)
#elif defined(Q_OS_ANDROID)
    mInstance = this;
#else

#endif
}

void FileHelper::viewFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId)
{
#if defined(Q_OS_IOS)
    IosShareUtils iosShareUtils;
    iosShareUtils.sendFile(filePath, title, mimeType, requestId);
#elif defined(Q_OS_ANDROID)
        QAndroidJniObject jsPath = QAndroidJniObject::fromString(filePath);
        QAndroidJniObject jsTitle = QAndroidJniObject::fromString(title);
        QAndroidJniObject jsMimeType = QAndroidJniObject::fromString(mimeType);
        jboolean ok = QAndroidJniObject::callStaticMethod<jboolean>("org/ekkescorner/utils/QShareUtils",
                                                  "viewFile",
                                                  "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)Z",
                                                  jsPath.object<jstring>(), jsTitle.object<jstring>(), jsMimeType.object<jstring>(), requestId);
        if(!ok) {
            qWarning() << "Unable to resolve activity from Java";
            emit shareNoAppAvailable(requestId);
        }
#else
    Q_UNUSED(title)
    Q_UNUSED(mimeType)
    Q_UNUSED(requestId)

    QDesktopServices::openUrl(QUrl::fromLocalFile(filePath));
#endif

}

#if defined(Q_OS_ANDROID)
const static int RESULT_OK = -1;
const static int RESULT_CANCELED = 0;

FileHelper* FileHelper::mInstance = nullptr;

FileHelper* FileHelper::getInstance()
{
    if (!mInstance) {
        mInstance = new FileHelper;
        qWarning() << "AndroidShareUtils should be instantiated !";
    }

    return mInstance;
}


// used from QAndroidActivityResultReceiver
void FileHelper::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject &data)
{
    Q_UNUSED(data)
    qDebug() << "From JNI QAndroidActivityResultReceiver: " << receiverRequestCode << "ResultCode:" << resultCode;
    processActivityResult(receiverRequestCode, resultCode);
}

// used from Activity.java onActivityResult()
void FileHelper::onActivityResult(int requestCode, int resultCode)
{
    qDebug() << "From Java Activity onActivityResult: " << requestCode << "ResultCode:" << resultCode;
    processActivityResult(requestCode, resultCode);
}

void FileHelper::processActivityResult(int requestCode, int resultCode)
{
    // we're getting RESULT_OK only if edit is done
    if(resultCode == RESULT_OK) {
        emit shareEditDone(requestCode);
    } else if(resultCode == RESULT_CANCELED) {
        emit shareFinished(requestCode);
    } else {
        qDebug() << "wrong result code: " << resultCode << " from request: " << requestCode;
        emit shareError(requestCode, tr("Share: an Error occured"));
    }
}

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

JNIEXPORT void JNICALL
  Java_de_itsblue_fannyapp_MainActivity_fireActivityResult(JNIEnv *env,
                                        jobject obj,
                                        jint requestCode,
                                        jint resultCode)
{
    Q_UNUSED (obj)
    Q_UNUSED (env)
    FileHelper::getInstance()->onActivityResult(requestCode, resultCode);
    return;
}

#ifdef __cplusplus
}
#endif // __cplusplus
#endif //defined(Q_OS_ANDROID)
