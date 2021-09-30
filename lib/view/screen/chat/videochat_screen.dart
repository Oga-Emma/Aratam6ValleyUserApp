import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/response/seller_model.dart';
import 'package:flutter_sixvalley_ecommerce/provider/profile_provider.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/call_notifier.dart';
import 'package:flutter_sixvalley_ecommerce/view/basewidget/show_custom_modal_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:provider/provider.dart';

class VideoChatScreen extends StatefulWidget {
  const VideoChatScreen({Key key, this.receiver, this.callInfo})
      : super(key: key);
  final String receiver;
  final CallInfo callInfo;

  @override
  _VideoChatScreenState createState() => _VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  int _remoteUid;
  RtcEngine _engine;

  var token =
      "006d056307a775a4520a1b0a10023b5c91fIACsxvBYhzTQiwDMHXArtoC6+Zh9xI0FMq52ZJruXw1i2eEmJogAAAAAEAApikci5xVXYQEAAQDmFVdh";
  var channel = "aratama_room1";

  @override
  void dispose() {
    FirebaseDatabase.instance
        .reference()
        .child("${widget.receiver}")
        .child("call")
        .update({"status": Status.idle});

    super.dispose();
  }

  @override
  void initState() {
    if (widget.receiver != null) {
      setup();
    } else if (widget.callInfo != null) {
      token = widget.callInfo.token;
      channel = widget.callInfo.channel;
    } else {
      Future.delayed(
          Duration.zero, () => showInfo("Something went wrong", close: true));
    }
    initAgora();
    super.initState();
  }

  Future<void> initAgora() async {
    // retrieve permissions
    var response = await [Permission.microphone, Permission.camera].request();

    print(response);
    // if (response.map((key, value) => {key, value.isDenied}).containsKey(false))

    //create the engine
    _engine = await RtcEngine.create("d056307a775a4520a1b0a10023b5c91f");
    await _engine.enableVideo();
    _engine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print("local user $uid joined");
        },
        userJoined: (int uid, int elapsed) {
          print("remote user $uid joined");
          setState(() {
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          print("remote user $uid left channel");
          setState(() {
            _remoteUid = null;
          });
          showInfo("Call ended", close: true);
        },
      ),
    );

    try {
      await _engine.joinChannel(token, channel, null, 0);

      print("Call Joined");
    } catch (err) {
      print("Call Error");
      print("$err");
    }
  }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: RtcLocalView.SurfaceView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Connecting..."),
          SizedBox(height: 20),
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"))
        ],
      );
    }
  }

  void setup() async {
    var user =
        await Provider.of<ProfileProvider>(context, listen: false).getProfile();

    if (user != null) {
      try {
        var ref = FirebaseDatabase.instance
            .reference()
            .child("${widget.receiver}")
            .child("call");

        Future.delayed(Duration(seconds: 15), () async {
          if (_remoteUid == null) {
            showInfo("No answer", close: true);
            await ref.update({"status": Status.idle});
          }
        });

        await ref.update(CallInfo(
                userId: user.id,
                userName: user.fName,
                status: Status.calling,
                channel: channel,
                token: token)
            .toMap());

        ref.onValue.listen((event) async {
          if (event != null) {
            var info = CallInfo.fromMap(event.snapshot.value);
            if (info.status == Status.ended) {
              showInfo("Call ended", close: true);
            } else if (info.status == Status.declined) {
              showInfo("Call declined", close: true);
            }
          }
        });
      } catch (err) {
        print("Error occurred");
        print(err);
      }
    }
  }

  showInfo(String label, {close = false}) async {
    await showCupertinoDialog(
        context: context, builder: (_) => CallDialog(text: label));

    if (close) {
      Navigator.pop(context);
    }
  }
}

class CallDialog extends StatelessWidget {
  const CallDialog({this.text, Key key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$text"),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"))
        ],
      ),
    );
  }
}
