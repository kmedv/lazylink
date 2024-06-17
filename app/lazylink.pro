TEMPLATE = app
TARGET = Lazylink
VERSION = 1.1.0

QT = core network gui quick quickwidgets quickcontrols2
CONFIG += strict_c++ exceptions_off c++14

CONFIG(debug, debug|release) {
    CONFIG -= qtquickcompiler
    DESTDIR = debug
} else {
    CONFIG += qtquickcompiler
    DESTDIR = release
    DEFINES += QT_NO_DEBUG QT_NO_DEBUG_OUTPUT
}

OBJECTS_DIR = $$DESTDIR
MOC_DIR = $$DESTDIR
RCC_DIR = $$DESTDIR
UI_DIR = $$DESTDIR

DEFINES += QT_DEPRECATED_WARNINGS
DEFINES += APP_VERSION=$$VERSION

INCLUDEPATH += src
QML_IMPORT_PATH = qml/

HEADERS += \
    src/App.h \
    src/AppContext.h \
    src/AppNotificationSender.h \
    src/BitlyShortenerService.h \
    src/EventBasedLinkMonitor.h \
    src/GooglShortenerService.h \
    src/LinkMonitor.h \
    src/LinkPattern.h \
    src/LogMsgDispatcher.h \
    src/Notification.h \
    src/NotificationSender.h \
    src/Notifier.h \
    src/OsNotificationSender.h \
    src/QmlReloader.h \
    src/RunGuard.h \
    src/Settings.h \
    src/SharedSettingsFactory.h \
    src/ShortenerRequest.h \
    src/ShortenerResponse.h \
    src/ShortenerService.h \
    src/SystemServices.h \
    src/TrayIcon.h \
    src/TimerBasedLinkMonitor.h \
    src/updater/Updater.h \
    src/updater/NoUpdater.h \
    src/updater/sparkle/SparkleUpdater.h

SOURCES += \
    src/App.cpp \
    src/AppContext.cpp \
    src/AppNotificationSender.cpp \
    src/BitlyShortenerService.cpp \
    src/EventBasedLinkMonitor.cpp \
    src/GooglShortenerService.cpp \
    src/LinkMonitor.cpp \
    src/LinkPattern.cpp \
    src/SystemServices.cpp \
    src/main.cpp \
    src/Notifier.cpp \
    src/OsNotificationSender.cpp \
    src/QmlReloader.cpp \
    src/RunGuard.cpp \
    src/Settings.cpp \
    src/SharedSettingsFactory.cpp \
    src/ShortenerService.cpp \
    src/TrayIcon.cpp \
    src/TimerBasedLinkMonitor.cpp \
    src/updater/Updater.cpp

RESOURCES += \
    fonts/fonts.qrc \
    icons/icons.qrc \
    qml/qml.qrc \
    certs/certs.qrc

# Windows specific
win32 {
    ICON = app.ico
    RC_ICONS = app.ico

    HEADERS += \
        src/updater/WinUpdater.h

    SOURCES += \
        src/updater/WinUpdater.cpp \
        src/updater/sparkle/win/SparkleUpdater.cpp
} # win32

# macOS specific
macx {
    CONFIG += app_bundle
    ICON = app.icns
    QMAKE_INFO_PLIST = Info.plist

    HEADERS += \
        src/macos/MacOSSystemServices.h

    SOURCES += \
        src/macos/MacOSSystemServices.mm

    LIBS += -framework AppKit
    LIBS += -framework Foundation
    LIBS += -framework ServiceManagement
} # macx

#WinSparkle
win32 {
    WINSPARKLE_PATH=$$PWD/ext/WinSparkle

    contains(QMAKE_TARGET.arch, x86_64) {
        WINSPARKLE_LIB_DIR=$$WINSPARKLE_PATH/x64
    } else {
        WINSPARKLE_LIB_DIR=$$WINSPARKLE_PATH/x32
    }
    WINSPARKLE_LIB_DIR=$$WINSPARKLE_LIB_DIR/Release

    INCLUDEPATH += $$WINSPARKLE_PATH/include
    LIBS += -L$$WINSPARKLE_LIB_DIR -lWinSparkle
}

# SimpleCrypt

SOURCES += ext/SimpleCrypt/simplecrypt.cpp
INCLUDEPATH += ext/SimpleCrypt

# Sentry
SENTRY_PATH=$$PWD/ext/sentry-native
INCLUDEPATH += $$SENTRY_PATH

macx {
    LIBS += -L$$SENTRY_PATH/macx -lsentry
    Sentry.files += $$SENTRY_PATH/macx/libsentry.dylib
    Sentry.path += Contents/Frameworks
    QMAKE_BUNDLE_DATA += Sentry
}

# Print variables during qmake
for(var, $$list(VERSION DESTDIR DEFINES QT CONFIG LIBS QMAKE_MACOSX_DEPLOYMENT_TARGET)) {
    message($$var = $$eval($$var))
}
