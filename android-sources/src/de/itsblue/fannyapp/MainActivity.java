package de.itsblue.fannyapp;

import org.qtproject.qt5.android.QtNative;

import org.qtproject.qt5.android.bindings.QtActivity;
import android.os.*;
import android.content.*;
import android.app.*;

import java.lang.String;
import android.content.Intent;
import java.io.File;
import android.net.Uri;
import android.util.Log;
import android.content.ContentResolver;
import android.webkit.MimeTypeMap;

import org.ekkescorner.utils.*;

public class MainActivity extends QtActivity
{
    // native - must be implemented in Cpp via JNI
    //
    public static native void fireActivityResult(int requestCode, int resultCode);

    // we start Activity with result code
    // to test JNI with QAndroidActivityResultReceiver you must comment or rename
    // this method here - otherwise you'll get wrong request or result codes
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        // hint: result comes back too fast for Action SEND
        // if you want to delete/move the File add a Timer w 500ms delay
        // see Example App main.qml - delayDeleteTimer
        // if you want to revoke permissions for older OS
        // it makes sense also do this after the delay
        fireActivityResult(requestCode, resultCode);
    }
} // class QShareActivity

