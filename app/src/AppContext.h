/*  This file is part of Lazylink project (https://lazylink.net)
 *  Copyright (C) 2015-2019 Kirill Medvedev
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a
 *  copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *  DEALINGS IN THE SOFTWARE.
 */

#pragma once

#include <QObject>

class QGuiApplication;
class QQmlApplicationEngine;
class QQuickWindow;
class ClipConfig;
class TrayIcon;
class Notifier;
class LinkMonitor;
class Updater;
class SharedSettingsFactory;
class Settings;
class QQmlEngine;
class QJSEngine;

class AppContext : public QObject
{
    Q_OBJECT

public:
    explicit AppContext(QObject* parent = nullptr);

    void init();

    QQuickWindow* mainWindow() const;
    QQuickWindow* notificationWindow() const;

    TrayIcon* trayIcon() const;
    Notifier* notifier() const;
    LinkMonitor* clipMonitor() const;
    Updater* updater() const;
    Settings* settings(QObject* parent = nullptr) const;

private:
    static QObject* qmlSettingsProviderFn(QQmlEngine*, QJSEngine*);
    QQmlApplicationEngine* createQmlEngine();
    void loadMainQml();

private:
    QQmlApplicationEngine* _qmlEngine = nullptr;
    TrayIcon* _trayIcon = nullptr;
    Notifier* _notifier = nullptr;
    LinkMonitor* _clipMonitor = nullptr;
    Updater* _updater = nullptr;
    SharedSettingsFactory* _settingsFactory = nullptr;
    Settings* _settings = nullptr;
};

