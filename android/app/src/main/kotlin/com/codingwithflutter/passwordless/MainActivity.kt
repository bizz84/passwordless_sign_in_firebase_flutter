package com.codingwithflutter.passwordless

import android.os.Bundle

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
