import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  static const String appId = "5ceab58207c64d519d5d8620b78dc737";

  RtcEngine? _engine;
  bool _initialized = false;
  int? _remoteUid;
  bool _muted = false;
  Function(int uid)? _onUserJoined;

  RtcEngine? get engine => _engine;
  int? get remoteUid => _remoteUid;
  bool get isMuted => _muted;
  bool get initialized => _initialized;

  Future<bool> init({Function(int uid)? onUserJoined}) async {
    if (_initialized) return true;
    _onUserJoined = onUserJoined;
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(appId: appId));
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (conn, elapsed) {},
        onUserJoined: (conn, uid, elapsed) {
          _remoteUid = uid;
          _onUserJoined?.call(uid);
        },
        onUserOffline: (conn, uid, reason) {
          _remoteUid = null;
        },
        onError: (err) {},
      ));
      await _engine!.enableAudio();
      _engine!.setEnableSpeakerphone(true);
      _initialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> joinChannel({
    required String channelName,
    required int uid,
  }) async {
    if (_engine == null) return;
    await _engine!.joinChannel(
      token: '',
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    await _engine?.muteLocalAudioStream(_muted);
  }

  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    _initialized = false;
  }
}
