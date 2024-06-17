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

#include "AppNotificationSender.h"
#include <assert.h>
#include <QQuickWindow>
#include <QQuickItem>
#include <QTimer>
#include "App.h"
#include "AppContext.h"
#include "Notification.h"

AppNotificationSender::AppNotificationSender(QObject* parent)
    : NotificationSender(parent),
      _notification{nullptr},
      _nextTimer{new QTimer(this)},
      _closeTimer{new QTimer(this)}
{
    _closeTimer->setSingleShot(true);
    connect(_closeTimer, &QTimer::timeout, this, &AppNotificationSender::closeNotification);

    _nextTimer->setSingleShot(true);
    connect(_nextTimer, &QTimer::timeout, this, &AppNotificationSender::processQueue);

    auto* wnd = App::appContext()->notificationWindow();
    bool ok = connect(wnd, SIGNAL(actionClicked()), this, SLOT(onActionClicked()))
            && connect(wnd, SIGNAL(closeClicked()), this, SLOT(onNotificationClosed()));
    assert(ok);
}

bool AppNotificationSender::sendNotification(const Notification& notification)
{
	_queue.push(notification);
    if (!_nextTimer->isActive())
        _nextTimer->start(0);
	return true;
}

void AppNotificationSender::processQueue()
{
    assert(!_queue.empty());
    _notification = &_queue.front();
    auto* wnd = App::appContext()->notificationWindow();
    bool ok = QMetaObject::invokeMethod(wnd, "open",
                                        Q_ARG(QVariant, _notification->message),
                                        Q_ARG(QVariant, _notification->action));
    assert(ok);
    _closeTimer->start(NOTIFICATION_CLOSE_TIMEOUT_MS);
}

void AppNotificationSender::closeNotification()
{
    auto* wnd = App::appContext()->notificationWindow();
    QMetaObject::invokeMethod(wnd, "close");
    onNotificationClosed();
}

void AppNotificationSender::onActionClicked()
{
    if (_notification->actionFn)
        _notification->actionFn();
    onNotificationClosed();
}

void AppNotificationSender::onNotificationClosed()
{
    _closeTimer->stop();
    if (_notification) {
        _notification = nullptr;
        _queue.pop();
    }
    if (!_queue.empty())
        _nextTimer->start(NEXT_NOTIFICATION_TIMEOUT_MS);
}
