import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static final AgoraService instance = AgoraService._();
  AgoraService._();

  RtcEngine? _engine;
  String? _appId;
  bool _initialized = false;
  bool _muted = false;

  bool get isMuted => _muted;
  bool get isInitialized => _initialized;
  bool get inChannel => _engine != null && _initialized;

  Future<bool> initEngine(String appId) async {
    if (_initialized && _appId == appId) return true;

    _appId = appId;

    // Mikrofon izni
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      return false;
    }

    // Eski engine varsa temizle
    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        await _engine!.release();
      } catch (_) {}
      _engine = null;
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (conn, elapsed) {},
      onUserJoined: (conn, uid, elapsed) {},
      onUserOffline: (conn, uid, reason) {},
      onError: (err, msg) {},
    ));

    await _engine!.enableAudio();
    await _engine!.disableVideo();
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileSpeechStandard,
      scenario: AudioScenarioType.audioScenarioChatroom,
    );
    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableAudioVolumeIndication(
      interval: 200,
      smooth: 3,
      reportVad: false,
    );

    _initialized = true;
    return true;
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
  }) async {
    if (_engine == null) return;
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
  }

  Future<void> leaveChannel() async {
    if (_engine == null) return;
    try {
      await _engine!.leaveChannel();
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    if (_engine == null) return;
    _muted = !_muted;
    await _engine!.muteLocalAudioStream(_muted);
  }

  Future<void> setMute(bool mute) async {
    if (_engine == null) return;
    _muted = mute;
    await _engine!.muteLocalAudioStream(mute);
  }

  Future<void> release() async {
    if (_engine == null) return;
    try {
      await _engine!.leaveChannel();
      await _engine!.release();
    } catch (_) {}
    _engine = null;
    _initialized = false;
    _muted = false;
  }
}
