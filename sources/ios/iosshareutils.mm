// (c) 2017 Ekkehard Gentz (ekke) @ekkescorner
// my blog about Qt for mobile: http://j.mp/qt-x
// see also /COPYRIGHT and /LICENSE

#import "headers/ios/iosshareutils.hpp"

#import <UIKit/UIKit.h>
#import <QGuiApplication>
#import <QQuickWindow>
#import <QDesktopServices>
#import <QUrl>
#import <QFileInfo>

#import <UIKit/UIDocumentInteractionController.h>

#import "headers/ios/docviewcontroller.hpp"

IosShareUtils::IosShareUtils(QObject *parent) : QObject(parent)
{
    // Sharing Files from other iOS Apps I got the ideas and some code contribution from:
    // Thomas K. Fischer (@taskfabric) - http://taskfabric.com - thx
    QDesktopServices::setUrlHandler("file", this, "handleFileUrlReceived");
}

bool IosShareUtils::checkMimeTypeView(const QString &mimeType) {
#pragma unused (mimeType)
    // dummi implementation on iOS
    // MimeType not used yet
    return true;
}

bool IosShareUtils::checkMimeTypeEdit(const QString &mimeType) {
#pragma unused (mimeType)
    // dummi implementation on iOS
    // MimeType not used yet
    return true;
}

// altImpl not used yet on iOS, on Android twi ways to use JNI
void IosShareUtils::sendFile(const QString &filePath, const QString &title, const QString &mimeType, const int &requestId) {
#pragma unused (title, mimeType)

    NSString* nsFilePath = filePath.toNSString();
    NSURL *nsFileUrl = [NSURL fileURLWithPath:nsFilePath];

    static DocViewController* docViewController = nil;
    if(docViewController!=nil)
    {
        [docViewController removeFromParentViewController];
        [docViewController release];
    }

    UIDocumentInteractionController* documentInteractionController = nil;
    documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:nsFileUrl];

    UIViewController* qtUIViewController = [[[[UIApplication sharedApplication]windows] firstObject]rootViewController];
    if(qtUIViewController!=nil)
    {
        docViewController = [[DocViewController alloc] init];

        docViewController.requestId = requestId;
        // we need this to be able to execute handleDocumentPreviewDone() method,
        // when preview was finished
        docViewController.mIosShareUtils = this;

        [qtUIViewController addChildViewController:docViewController];
        documentInteractionController.delegate = docViewController;
        // [documentInteractionController presentPreviewAnimated:YES];
        if(![documentInteractionController presentPreviewAnimated:YES])
        {
            emit shareError(0, tr("No App found to open: %1").arg(filePath));
        }
    }
}

void IosShareUtils::handleDocumentPreviewDone(const int &requestId)
{
    // documentInteractionControllerDidEndPreview
    qDebug() << "handleShareDone: " << requestId;
    //emit shareFinished(requestId);
}


