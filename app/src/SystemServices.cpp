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

#include "SystemServices.h"
#include <QApplication>
#include <QFileInfo>
#include <QStandardPaths>
#include "Settings.h"
#include "App.h"
#include "AppContext.h"
#include "updater/Updater.h"

#ifdef Q_OS_MACOS
#include "macos/MacOSSystemServices.h"
#endif

void SystemServices::onStartup()
{
#ifdef Q_OS_MACOS
    MacOSSystemServices::onStartup();
#endif
}

// This validate approach instead of direct value check is applied because macOS
// doesn't give an opportunity to check the leunch on login state directly.
void SystemServices::validateSettings(Settings* settings)
{
    Q_CHECK_PTR(settings);
    auto launchOnLoginVal = settings->launchOnLoginEnabled();
#if defined(Q_OS_MACOS)
    if (!MacOSSystemServices::validateLaunchOnLoginValue(launchOnLoginVal))
        launchOnLoginVal = !launchOnLoginVal;
#elif defined(Q_OS_WIN)
    QFileInfo appFileInfo{QCoreApplication::applicationFilePath()};
    auto startupLnkFile = QString{"%1\\Startup\\%2.lnk"}
            .arg(QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation))
            .arg(appFileInfo.completeBaseName());
    launchOnLoginVal = QFile::exists(startupLnkFile);
#endif
    settings->setLaunchOnLoginEnabled(launchOnLoginVal);
}

void SystemServices::setLaunchOnLogin(bool launchOnLogin)
{
#if defined(Q_OS_MACOS)
    MacOSSystemServices::setLaunchOnLoginEnabled(launchOnLogin);
#elif defined(Q_OS_WIN)
    QFileInfo appFileInfo(QCoreApplication::applicationFilePath());
    QString startupLnkFile = QString{"%1\\Startup\\%2.lnk"}
            .arg(QStandardPaths::writableLocation(QStandardPaths::ApplicationsLocation))
            .arg(appFileInfo.completeBaseName());
    if (launchOnLogin) {
        if (!QFile::exists(startupLnkFile))
            QFile::link(QCoreApplication::applicationFilePath(), startupLnkFile);
    } else {
        QFile::remove(startupLnkFile);
    }
#endif
}

