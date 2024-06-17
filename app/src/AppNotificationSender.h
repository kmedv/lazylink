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

#include <queue>
#include <chrono>
#include "NotificationSender.h"
#include "Notification.h"

using namespace std::chrono_literals;

class QQuickWindow;
class QTimer;

class AppNotificationSender : public NotificationSender
{
    Q_OBJECT

public:
    explicit AppNotificationSender(QObject* parent = nullptr);

	bool sendNotification(const Notification& notification) override;

private slots:
    void processQueue();
    void closeNotification();
    void onActionClicked();
    void onNotificationClosed();

private:
    static constexpr int NOTIFICATION_CLOSE_TIMEOUT_MS = 3000;
    static constexpr int NEXT_NOTIFICATION_TIMEOUT_MS = 150;

    std::queue<Notification> _queue;
    Notification* _notification = nullptr;
    QTimer* _nextTimer = nullptr;
    QTimer* _closeTimer = nullptr;
};
