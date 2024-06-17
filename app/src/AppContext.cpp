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

#include "AppContext.h"

#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQuickItem>
#include <QGuiApplication>
#include <QScreen>
#include <QQmlFileSelector>
#include <QQmlContext>
#include <QProcessEnvironment>
#include <QUrl>
#include <QDir>
#include <QQuickWindow>
#include <QDesktopServices>
#include <QDebug>

#include "TrayIcon.h"
#include "NotificationSender.h"
#include "TimerBasedLinkMonitor.h"
#include "EventBasedLinkMonitor.h"
#include "LinkPattern.h"
#include "SharedSettingsFactory.h"
#include "Settings.h"
#include "AppNotificationSender.h"
#include "Notifier.h"
#include "App.h"
#include "SystemServices.h"
#include "updater/WinUpdater.h"
#include "updater/NoUpdater.h"
#ifdef QT_DEBUG
#include "QmlReloader.h"
#endif

static Updater* createUpdater(QObject* parent)
{
#if defined(Q_OS_MACOS)
//    return new MacUpdater(parent);
    return new NoUpdater(parent);
#elif defined(Q_OS_WIN)
    return new WinUpdater(parent);
#endif
}

AppContext::AppContext(QObject* parent)
    : QObject{parent}
{}

void AppContext::init()
{
    _settingsFactory = new SharedSettingsFactory(this);
    _notifier = new Notifier(this);
    _trayIcon = new TrayIcon(_settingsFactory, this);
    _updater = createUpdater(this);
    _qmlEngine = createQmlEngine();

#ifdef Q_OS_WIN
    _clipMonitor = new EventBasedLinkMonitor();
#else
    _clipMonitor = new TimerBasedLinkMonitor();
#endif
    _clipMonitor->setParent(this);

    _settings = _settingsFactory->createSettings(this);

    SystemServices::validateSettings(_settings);
    connect(_settings, &Settings::changed, this, [this]() {
        SystemServices::setLaunchOnLogin(_settings->launchOnLoginEnabled());
	});

    connect(_clipMonitor, &LinkMonitor::linkClipped, notifier(), [=](QUrl url) {
        notifier()->notifyClipboardShortened([=](){QDesktopServices::openUrl(url);});
	});
    connect(_clipMonitor, &LinkMonitor::error, notifier(), [=](QString err) {
        notifier()->notifyError(tr("Shortening error"), tr(err.toLatin1()));
	});

    connect(_updater, &Updater::updateFound, notifier(), [=](Version v) {
        notifier()->notifyUpdateFound(v, [=](){updater()->startUpdate(v);});
	});
	connect(_updater, &Updater::updateNotFound, notifier(), &Notifier::notifyUpdateNotFound);
    connect(_updater, &Updater::error, notifier(), [=](QString err){
        notifier()->notifyError(tr("Update failed: "), err);
	});

    loadMainQml();
    connect(_trayIcon, &TrayIcon::appActivated, this, [this]() {
        auto wnd = mainWindow();
        if (!wnd->isActive()) {
            QMetaObject::invokeMethod(wnd, "showFromTray",
                                      Q_ARG(QVariant, QVariant::fromValue(_trayIcon->geometry())));
        } else {
            wnd->close();
        }
    });

    connect(_qmlEngine, &QQmlEngine::quit, qApp, &QApplication::quit);
    connect(qApp, &QApplication::aboutToQuit, _qmlEngine, &QQmlEngine::deleteLater);

    _notifier->setNotificationSender(new AppNotificationSender());
    _clipMonitor->startMonitoring();
    _trayIcon->show();
    if (_settings->checkUpdateOnStartup())
        _updater->checkForUpdateQuietly();
}

QQuickWindow* AppContext::mainWindow() const
{
    return q_check_ptr(qobject_cast<QQuickWindow*>(_qmlEngine->rootObjects().first()));
}

QQuickWindow *AppContext::notificationWindow() const
{
    return q_check_ptr(mainWindow()->contentItem()->findChild<QQuickWindow*>(
                           "notification", Qt::FindDirectChildrenOnly));
}

TrayIcon* AppContext::trayIcon() const
{
    return _trayIcon;
}

Notifier* AppContext::notifier() const
{
    return _notifier;
}

LinkMonitor* AppContext::clipMonitor() const
{
    return _clipMonitor;
}

Updater* AppContext::updater() const
{
    return _updater;
}

Settings* AppContext::settings(QObject* parent) const
{
    return _settingsFactory->createSettings(parent);
}

QQmlApplicationEngine* AppContext::createQmlEngine()
{
    QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);
    qmlRegisterSingletonType<Settings>("net.lazylink", 1, 0, "Settings", &qmlSettingsProviderFn);
    QQmlApplicationEngine* engine = new QQmlApplicationEngine(this);
//    qreal pxPerDp = qApp->screenAt({0, 0})->devicePixelRatio();
    qreal pxPerDp = 1.;
    qInfo() << "Scaling ratio is" << pxPerDp;
    // Fill dp_ values for QML for high DPI scaling.
	for (int i = 0; i < 1024; ++i) {
		int dpVal = (pxPerDp > 1.0) ? qRound(i * pxPerDp) : i;
        engine->rootContext()->setContextProperty(QString{"dp_%1"}.arg(i), dpVal);
    }
    return engine;
}

void AppContext::loadMainQml()
{
#ifdef QT_DEBUG
    // Autoupdater
    QString srcDir = QProcessEnvironment::systemEnvironment().value("LAZYLINK_SRC_DIR");
    if (!srcDir.isEmpty()) {
        QDir qmlDir{srcDir + "/qml"};
        Q_ASSERT(qmlDir.exists());
        _qmlEngine->load(QFileInfo{qmlDir, "main.qml"}.absoluteFilePath());
        new QmlReloader(qmlDir.absolutePath(), _qmlEngine);
        qDebug() << "QML is loaded from" << qmlDir.absolutePath();
    } else {
        _qmlEngine->load("qrc:/qml/main.qml");
        qDebug() << "QML is loaded from the resources.";
    }

    // Assert that all items are layouted with integer values in bounding rect.
    std::function<void(QObject*)> assertIntBounds = [&](QObject* obj){
        if (!obj)
            return;
        auto x = obj->property("x");
        auto y = obj->property("y");
        auto width = obj->property("width");
        auto height = obj->property("height");
        if (!x.isNull() && !y.isNull() && !width.isNull() && !height.isNull()) {
            bool allInt = (x.toReal() == qreal(x.toInt()))
                    && (y.toReal() == qreal(y.toInt()))
                    && (width.toReal() == qreal(width.toInt()))
                    && (height.toReal() == qreal(height.toInt()));
            if (!allInt) {
                auto item = qobject_cast<QQuickItem*>(obj);
                item->setProperty("color", "red");
                qDebug() << "Bounding rect contains float,"
                           << "global_pos =" << item->mapToGlobal(item->position())
                           << "x =" << x.toReal() << "y =" << y.toReal()
                           << "width =" << width.toReal() << "height =" << height.toReal();
                obj->dumpObjectInfo();
                obj->dumpObjectTree();
            }
        }
        const auto& children = obj->children();
        for (const auto& child : children)
            assertIntBounds(child);
    };
    for (auto& obj : _qmlEngine->rootObjects())
        assertIntBounds(obj);
#else
    _qmlEngine->load("qrc:/qml/main.qml");
#endif
}

QObject* AppContext::qmlSettingsProviderFn(QQmlEngine*, QJSEngine*)
{
    return App::appContext()->_settings;
}

