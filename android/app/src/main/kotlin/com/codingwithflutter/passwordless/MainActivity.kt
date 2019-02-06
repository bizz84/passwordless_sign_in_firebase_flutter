package com.codingwithflutter.passwordless

import android.content.ContentValues.TAG
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import com.google.firebase.dynamiclinks.FirebaseDynamicLinks

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  var linkStreamHandler: LinkStreamHandler? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    linkStreamHandler = LinkStreamHandler()
    val channel = EventChannel(flutterView, "linkHandler")
    channel.setStreamHandler(linkStreamHandler)

    // https://firebase.google.com/docs/dynamic-links/android/receive
    // NOTE: This seems to crash the app on emulator with this log:
    // Error connecting to the service protocol: HttpException: Connection closed before full header was received, uri = http://127.0.0.1:53810/ws
    // See: https://github.com/flutter/flutter/issues/19056
    // For this reason we only run this code on a real device (see https://stackoverflow.com/questions/2799097/how-can-i-detect-when-an-android-application-is-running-in-the-emulator)
    if (!Build.FINGERPRINT.contains("generic")) {
        FirebaseDynamicLinks.getInstance()
                .getDynamicLink(intent)
                .addOnSuccessListener(this) { pendingDynamicLinkData ->
                    // Get deep link from result (may be null if no link is found)
                    if (pendingDynamicLinkData != null) {
                        var deepLink = pendingDynamicLinkData.link
                        linkStreamHandler?.handleLink(deepLink.toString())
                        Log.i(TAG, "getDynamicLink:onSuccess -> " + deepLink.toString())
                    } else {
                        Log.i(TAG, "getDynamicLink:onSuccess -> no link found")
                    }
                }
                .addOnFailureListener(this) { e -> Log.w(TAG, "getDynamicLink:onFailure", e) }
    }
  }
}

class LinkStreamHandler: EventChannel.StreamHandler {

  private var eventSink: EventChannel.EventSink? = null

  override fun onListen(
          arguments: Any?, eventSink: EventChannel.EventSink?) {
    this.eventSink = eventSink
  }
  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  fun handleLink(link: String) {
    eventSink?.success(link)
  }
}
