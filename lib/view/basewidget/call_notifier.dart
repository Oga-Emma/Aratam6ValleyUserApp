import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/color_resources.dart';
import 'package:flutter_sixvalley_ecommerce/view/screen/chat/videochat_screen.dart';
import 'package:overlay_support/src/overlay_state_finder.dart';

class CallNotifier extends StatelessWidget {
  const CallNotifier({this.callerInfo, Key key}) : super(key: key);
  final CallInfo callerInfo;

  @override
  Widget build(BuildContext context) {
    var textColor = ColorResources.getTextBg(context);

    return Material(
      color: ColorResources.getPrimary(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Incoming Call",
                  style: TextStyle(
                      fontSize: 24,
                      color: textColor,
                      fontWeight: FontWeight.bold)),
              Text("You have an incoming call from ${callerInfo.userName}",
                  style: TextStyle(color: textColor)),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => closeOverlay(context),
                      label: Text("Decline"),
                      icon: Icon(Icons.cancel_outlined),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    VideoChatScreen(callInfo: callerInfo)));
                        closeOverlay(context);
                      },
                      label: Text("Answer"),
                      icon: Icon(Icons.call),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void closeOverlay(context) {
    final overlaySupport = findOverlayState(context: context);
    final oldSupportEntry = overlaySupport.getEntry(key: key);

    oldSupportEntry?.dismiss(animate: true);
  }
}

class CallInfo {
  var userId;
  var userName;
  var status = Status.idle;
  var channel;
  var token;

  CallInfo({this.userId, this.userName, this.status, this.channel, this.token});

  CallInfo.fromMap(Map<dynamic, dynamic> data) {
    userId = data["userId"];
    userName = data["userName"];
    status = data["status"];
  }

  Map<String, dynamic> toMap() =>
      {"userId": "$userId", "userName": userName, "status": status};
}

class Status {
  static String idle = "idle";
  static String calling = "calling";
  static String ended = "ended";
  static String answered = "answered";
  static String declined = "declined";
}
