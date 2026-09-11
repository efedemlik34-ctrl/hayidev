import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  // Singleton
  AgoraService._internal();
  static final AgoraService _instance = AgoraService._internal();
  static AgoraService get instance => _instance;

  // App ID
  static const String _defaultAppId = "5ceab58207c64d519d5d8620b78dc737";

  RtcEngine? _engine;
  bool _initialized = false;
  bool _muted = false;
  int? _remoteUid;
  Function(int uid)? _onUserJoined;

  RtcEngine? get engine => _engine;
  bool get isInitialized => _initialized;
  bool get isMuted => _muted;
  int? get remoteUid => _remoteUid;

  // ═══ Engine init ═══
  Future<void> initEngine(String appId) async {
    if (_initialized) return;
    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId.isEmpty ? _defaultAppId : appId,
      ));
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (conn, elapsed) {},
        onUserJoined: (conn, uid, elapsed) {
          _remoteUid = uid;
          _onUserJoined?.call(uid);
        },
        onUserOffline: (conn, uid, reason) {
          _remoteUid = null;
        },
        onError: (err, msg) {},
      ));
      await _engine!.enableAudio();
      await _engine!.setEnableSpeakerphone(true);
      _initialized = true;
    } catch (e) {
      // sessiz gec
    }
  }

  // Eski API uyumlulugu
  Future<bool> init({Function(int uid)? onUserJoined}) async {
    _onUserJoined = onUserJoined;
    await initEngine(_defaultAppId);
    return _initialized;
  }

  // ═══ Join ═══
  Future<void> joinChannel({
    required String channelName,
    required int uid,
    String token = '',
  }) async {
    if (_engine == null) return;
    try {
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      // sessiz gec
    }
  }

  // ═══ Leave ═══
  Future<void> leaveChannel() async {
    try {
      await _engine?.leaveChannel();
    } catch (e) {}
  }

  // ═══ Mute ═══
  Future<void> toggleMute() async {
    _muted = !_muted;
    try {
      await _engine?.muteLocalAudioStream(_muted);
    } catch (e) {}
  }

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    try {
      await _engine?.muteLocalAudioStream(muted);
    } catch (e) {}
  }

  // ═══ Release ═══
  Future<void> release() async {
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {}
    _engine = null;
    _initialized = false;
  }

  Future<void> dispose() async {
    await release();
  }
}
