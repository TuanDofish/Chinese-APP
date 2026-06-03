import 'dart:async';
import 'dart:js_interop';

// Global JS functions
@JS('eval')
external JSAny? _jsEval(JSString code);

/// Speech recognition + audio recording for Flutter Web
class SpeechService {
  static String? _lastAudioUrl;

  static bool get isSupported {
    try {
      final r = _jsEval('String(typeof webkitSpeechRecognition !== "undefined" || typeof SpeechRecognition !== "undefined")'.toJS);
      return r.dartify().toString() == 'true';
    } catch (_) {
      return false;
    }
  }

  /// Get the last recorded audio URL for playback
  static String? get lastAudioUrl => _lastAudioUrl;

  /// Listen for Chinese speech and return recognized text
  static Future<String> listen() async {
    final completer = Completer<String>();

    // Generate unique ID for this session
    final id = DateTime.now().millisecondsSinceEpoch;
    final resultKey = '__sr_result_$id';
    final audioKey = '__sr_audio_$id';

    // Initialize result storage in JS
    _jsEval('window.$resultKey = null; window.$audioKey = null;'.toJS);

    // Run speech recognition + audio recording entirely in JavaScript
    _jsEval('''
      (async function() {
        try {
          var mediaRecorder = null;
          var audioChunks = [];
          
          // Try microphone recording
          try {
            var stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            mediaRecorder = new MediaRecorder(stream);
            mediaRecorder.ondataavailable = function(e) { audioChunks.push(e.data); };
            mediaRecorder.onstop = function() {
              var blob = new Blob(audioChunks, { type: "audio/webm" });
              window.$audioKey = URL.createObjectURL(blob);
              stream.getTracks().forEach(function(t) { t.stop(); });
            };
            mediaRecorder.start();
          } catch(e) { console.log("No mic:", e); }

          // Speech recognition
          var SR = window.SpeechRecognition || window.webkitSpeechRecognition;
          var rec = new SR();
          rec.lang = "zh-CN";
          rec.continuous = false;
          rec.interimResults = false;
          rec.maxAlternatives = 1;
          
          var finished = false;
          
          rec.onresult = function(event) {
            if (finished) return;
            finished = true;
            var text = event.results[0][0].transcript;
            console.log("Recognized:", text);
            window.$resultKey = text;
            if (mediaRecorder && mediaRecorder.state === "recording") mediaRecorder.stop();
          };
          
          rec.onerror = function(event) {
            console.log("Speech error:", event.error);
            if (finished) return;
            finished = true;
            window.$resultKey = "";
            if (mediaRecorder && mediaRecorder.state === "recording") mediaRecorder.stop();
          };
          
          rec.onend = function() {
            if (mediaRecorder && mediaRecorder.state === "recording") mediaRecorder.stop();
            if (!finished) { finished = true; window.$resultKey = ""; }
          };
          
          rec.start();
          
          // Timeout after 7s
          setTimeout(function() {
            if (!finished) {
              finished = true;
              try { rec.stop(); } catch(e) {}
              if (mediaRecorder && mediaRecorder.state === "recording") mediaRecorder.stop();
              if (window.$resultKey === null) window.$resultKey = "";
            }
          }, 7000);
          
        } catch(e) {
          console.log("Init error:", e);
          window.$resultKey = "";
        }
      })();
    '''.toJS);

    // Poll for result every 300ms (simpler than callbacks across JS/Dart boundary)
    int attempts = 0;
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      attempts++;
      try {
        final result = _jsEval('window.$resultKey'.toJS);
        final resultStr = result?.dartify()?.toString();
        
        if (resultStr != null && resultStr != 'null') {
          timer.cancel();
          // Also get audio URL
          try {
            final audioResult = _jsEval('window.$audioKey'.toJS);
            final audioStr = audioResult?.dartify()?.toString();
            if (audioStr != null && audioStr != 'null') {
              _lastAudioUrl = audioStr;
            }
          } catch (_) {}
          
          if (!completer.isCompleted) {
            completer.complete(resultStr);
          }
          // Cleanup
          _jsEval('delete window.$resultKey; delete window.$audioKey;'.toJS);
        }
      } catch (_) {}

      // Safety timeout after ~10 seconds
      if (attempts > 33 && !completer.isCompleted) {
        timer.cancel();
        completer.complete('');
      }
    });

    return completer.future;
  }

  /// Play back the last recorded audio
  static void playLastRecording() {
    if (_lastAudioUrl != null && _lastAudioUrl!.isNotEmpty) {
      _jsEval('new Audio("${_lastAudioUrl!}").play();'.toJS);
    }
  }

  /// Calculate pronunciation score (0-100)
  static int calculateScore(String target, String recognized) {
    if (recognized.isEmpty) return 0;
    
    // Normalize: keep only Chinese characters
    String t = target.replaceAll(RegExp(r'[^\u4e00-\u9fff]'), '');
    String r = recognized.replaceAll(RegExp(r'[^\u4e00-\u9fff]'), '');

    if (t.isEmpty) return 0;
    if (t == r) return 100;
    if (r.contains(t)) return 95;
    if (t.contains(r) && r.isNotEmpty) return 85;

    // Character-level matching (order-aware)
    int matches = 0;
    String remaining = r;
    for (int i = 0; i < t.length; i++) {
      int idx = remaining.indexOf(t[i]);
      if (idx >= 0) {
        matches++;
        remaining = remaining.substring(0, idx) + remaining.substring(idx + 1);
      }
    }

    double score = (matches / t.length) * 100;
    return score.round().clamp(0, 100);
  }
}
