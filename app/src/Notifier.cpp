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

#include "Notifier.h"
#include "NotificationSender.h"
#include "Notification.h"
#include "Settings.h"

Notifier::Notifier(QObject* parent)
    : QObject(parent)
{}

void Notifier::setNotificationSender(NotificationSender* sender)
{
    _sender = sender;
}

bool Notifier::canSendNotification() const
{
    return Settings{}.notificationsEnabled() && (_sender != nullptr);
}

void Notifier::notifyClipboardShortened(std::function<void()> viewFn)
{
    if (!canSendNotification())
        return;
    _sender->sendNotification(Notification{
                                  tr("Link shortened"),
                                  tr("Your link has been shortened successfully")});
}

void Notifier::notifyUpdateFound(const Version& version, std::function<void()> actionFn)
{
    if (!canSendNotification())
        return;
    _sender->sendNotification(Notification{
                                  tr("Update found"),
                                  tr("Found new version %1.").arg(version.appVersion),
                                  tr("Update"), actionFn});
}

void Notifier::notifyUpdateNotFound()
{
    if (!canSendNotification())
        return;
    _sender->sendNotification(Notification{
                                  tr("No updates found"),
                                  tr("No updates found, current version is the newest one.")});
}

void Notifier::notifyUpdateDownloaded(std::function<void ()> actionFn)
{
    if (!canSendNotification())
        return;
    _sender->sendNotification(Notification{
                                  tr("Update downloaded"),
                                  tr("Downloaded new version, please restart the application."),
                                  tr("Restart"), actionFn});
}

void Notifier::notifyError(const QString& title, const QString& error)
{
    if (!canSendNotification())
        return;
    _sender->sendNotification(Notification{title, error});
}
