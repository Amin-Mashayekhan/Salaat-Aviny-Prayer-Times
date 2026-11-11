#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  // When true the window is not shown after the first frame: the app was
  // started with --minimized and lives in the tray until the Dart side shows
  // it.
  void SetStartHidden(bool start_hidden) { start_hidden_ = start_hidden; }

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // Tells the Dart side about sleep, resume and clock changes over the
  // "owghat/power" channel ("suspending", "resumed" or "timeChanged").
  void NotifyPower(const char* event);

  // The project to run.
  flutter::DartProject project_;

  bool start_hidden_ = false;

  // Channel "owghat/power": method "event" with one of the strings above.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      power_channel_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
