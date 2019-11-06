// (c) 2017 Ekkehard Gentz (ekke)
// this project is based on ideas from
// http://blog.lasconic.com/share-on-ios-and-android-using-qml/
// see github project https://github.com/lasconic/ShareUtils-QML
// also inspired by:
// https://www.androidcode.ninja/android-share-intent-example/
// https://www.calligra.org/blogs/sharing-with-qt-on-android/
// https://stackoverflow.com/questions/7156932/open-file-in-another-app
// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
// https://stackoverflow.com/questions/5734678/custom-filtering-of-intent-chooser-based-on-installed-android-package-name
// see also /COPYRIGHT and /LICENSE

package org.ekkescorner.utils;

import org.qtproject.qt5.android.QtNative;

import java.lang.String;
import android.content.Intent;
import java.io.File;
import android.net.Uri;
import android.util.Log;

import android.content.ContentResolver;
import android.database.Cursor;
import android.provider.MediaStore;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileOutputStream;

import java.util.List;
import android.content.pm.ResolveInfo;
import java.util.ArrayList;
import android.content.pm.PackageManager;
import java.util.Comparator;
import java.util.Collections;
import android.content.Context;
import android.os.Parcelable;

import android.os.Build;

import android.support.v4.content.FileProvider;
import android.support.v4.app.ShareCompat;

public class QShareUtils
{
    // reference Authority as defined in AndroidManifest.xml
    private static String AUTHORITY="de.itsblue.fannyapp.fileprovider";

    protected QShareUtils()
    {
       //Log.d("ekkescorner", "QShareUtils()");
    }

    // thx @oxied and @pooks for the idea: https://stackoverflow.com/a/18835895/135559
    // theIntent is already configured with all needed properties and flags
    // so we only have to add the packageName of targeted app
    public static boolean createCustomChooserAndStartActivity(Intent theIntent, String title, int requestId, Uri uri) {
        final Context context = QtNative.activity();
        final PackageManager packageManager = context.getPackageManager();
        final boolean isLowerOrEqualsKitKat = Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT;

        // MATCH_DEFAULT_ONLY: Resolution and querying flag. if set, only filters that support the CATEGORY_DEFAULT will be considered for matching.
        // Check if there is a default app for this type of content.
        ResolveInfo defaultAppInfo = packageManager.resolveActivity(theIntent, PackageManager.MATCH_DEFAULT_ONLY);
        if(defaultAppInfo == null) {
            Log.d("ekkescorner", title+" PackageManager cannot resolve Activity");
            return false;
        }

        // had to remove this check - there can be more Activity names, per ex
        // com.google.android.apps.docs.editors.kix.quickword.QuickWordDocumentOpenerActivityAlias
        // if (!defaultAppInfo.activityInfo.name.endsWith("ResolverActivity") && !defaultAppInfo.activityInfo.name.endsWith("EditActivity")) {
            // Log.d("ekkescorner", title+" defaultAppInfo not Resolver or EditActivity: "+defaultAppInfo.activityInfo.name);
            // return false;
        //}

        // Retrieve all apps for our intent. Check if there are any apps returned
        List<ResolveInfo> appInfoList = packageManager.queryIntentActivities(theIntent, PackageManager.MATCH_DEFAULT_ONLY);
        if (appInfoList.isEmpty()) {
            Log.d("ekkescorner", title+" appInfoList.isEmpty");
            return false;
        }
        Log.d("ekkescorner", title+" appInfoList: "+appInfoList.size());

        // Sort in alphabetical order
        Collections.sort(appInfoList, new Comparator<ResolveInfo>() {
            @Override
            public int compare(ResolveInfo first, ResolveInfo second) {
                String firstName = first.loadLabel(packageManager).toString();
                String secondName = second.loadLabel(packageManager).toString();
                return firstName.compareToIgnoreCase(secondName);
            }
        });

        List<Intent> targetedIntents = new ArrayList<Intent>();
        // Filter itself and create intent with the rest of the apps.
        for (ResolveInfo appInfo : appInfoList) {
            // get the target PackageName
            String targetPackageName = appInfo.activityInfo.packageName;
            // we don't want to share with our own app
            // in fact sharing with own app with resultCode will crash because doesn't work well with launch mode 'singleInstance'
            if (targetPackageName.equals(context.getPackageName())) {
                continue;
            }
            // if you have a blacklist of apps please exclude them here

            // we create the targeted Intent based on our already configured Intent
            Intent targetedIntent = new Intent(theIntent);
            // now add the target packageName so this Intent will only find the one specific App
            targetedIntent.setPackage(targetPackageName);
            // collect all these targetedIntents
            targetedIntents.add(targetedIntent);

            // legacy support and Workaround for Android bug
            // grantUriPermission needed for KITKAT or older
            // see https://code.google.com/p/android/issues/detail?id=76683
            // also: https://stackoverflow.com/questions/18249007/how-to-use-support-fileprovider-for-sharing-content-to-other-apps
            if(isLowerOrEqualsKitKat) {
                Log.d("ekkescorner", "legacy support grantUriPermission");
                context.grantUriPermission(targetPackageName, uri, Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                // attention: you must revoke the permission later, so this only makes sense with getting back a result to know that Intent was done
                // I always move or delete the file, so I don't revoke permission
            }
        }

        // check if there are apps found for our Intent to avoid that there was only our own removed app before
        if (targetedIntents.isEmpty()) {
            Log.d("ekkescorner", title+" targetedIntents.isEmpty");
            return false;
        }

        // now we can create our Intent with custom Chooser
        // we need all collected targetedIntents as EXTRA_INITIAL_INTENTS
        // we're using the last targetedIntent as initializing Intent, because
        // chooser adds its initializing intent to the end of EXTRA_INITIAL_INTENTS :)
        Intent chooserIntent = Intent.createChooser(targetedIntents.remove(targetedIntents.size() - 1), title);
        if (targetedIntents.isEmpty()) {
            Log.d("ekkescorner", title+" only one Intent left for Chooser");
        } else {
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, targetedIntents.toArray(new Parcelable[] {}));
        }
        // Verify that the intent will resolve to an activity
        if (chooserIntent.resolveActivity(QtNative.activity().getPackageManager()) != null) {
            if(requestId > 0) {
                QtNative.activity().startActivityForResult(chooserIntent, requestId);
            } else {
                QtNative.activity().startActivity(chooserIntent);
            }
            return true;
        }
        Log.d("ekkescorner", title+" Chooser Intent not resolved. Should never happen");
        return false;
    }

    public static boolean viewFile(String filePath, String title, String mimeType, int requestId) {
        if (QtNative.activity() == null)
            return false;

        // using v4 support library create the Intent from ShareCompat
        // Intent viewIntent = new Intent();
        Intent viewIntent = ShareCompat.IntentBuilder.from(QtNative.activity()).getIntent();
        viewIntent.setAction(Intent.ACTION_VIEW);

        File imageFileToShare = new File(filePath);

        // Using FileProvider you must get the URI from FileProvider using your AUTHORITY
        // Uri uri = Uri.fromFile(imageFileToShare);
        Uri uri;
        try {
            uri = FileProvider.getUriForFile(QtNative.activity(), AUTHORITY, imageFileToShare);
        } catch (IllegalArgumentException e) {
            Log.d("ekkescorner viewFile - cannot be shared: ", filePath);
            return false;
        }
        // now we got a content URI per ex
        // content://org.ekkescorner.examples.sharex.fileprovider/my_shared_files/qt-logo.png
        // from a fileUrl:
        // /data/user/0/org.ekkescorner.examples.sharex/files/share_example_x_files/qt-logo.png
        Log.d("ekkescorner viewFile from file path: ", filePath);
        Log.d("ekkescorner viewFile to content URI: ", uri.toString());

        if(mimeType == null || mimeType.isEmpty()) {
            // fallback if mimeType not set
            mimeType = QtNative.activity().getContentResolver().getType(uri);
            Log.d("ekkescorner viewFile guessed mimeType:", mimeType);
        } else {
            Log.d("ekkescorner viewFile w mimeType:", mimeType);
        }

        viewIntent.setDataAndType(uri, mimeType);

        viewIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        viewIntent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

        return createCustomChooserAndStartActivity(viewIntent, title, requestId, uri);
    }

}
