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

#include "TrayIcon.h"
#include <QApplication>
#include <QMenu>
#include <QAction>
#include <QIcon>
#include "SharedSettingsFactory.h"
#include "Settings.h"

static QIcon enabledIcon()
{
	QIcon res;
#if defined(Q_OS_WIN)
    return QIcon{":/icon/win-idle.png"};
#elif defined(Q_OS_MACOS)
    res.addFile(":/icon/mac-idle-white.png");
    res.setIsMask(true);
#endif
	return res;
}

static QIcon disabledIcon()
{
	QIcon res;
#if defined(Q_OS_WIN)
    res.addFile(":/icon/win-disabled.png");
#elif defined(Q_OS_MACOS)
    res.addFile(":/icon/mac-disable-status.png");
	res.setIsMask(true);
#endif
	return res;
}

TrayIcon::TrayIcon(SharedSettingsFactory* ssf, QObject* parent)
	: QSystemTrayIcon(parent),
	  _enabledIcon{enabledIcon()},
	  _disabledIcon{disabledIcon()}
{
    setToolTip(tr("%1 %2").arg(qApp->applicationName()).arg(qApp->applicationVersion()));
	_settings = ssf->createSettings(this);
	connect(this, &TrayIcon::activated, this, &TrayIcon::onActivated);
	connect(_settings, &Settings::changed, this, &TrayIcon::onSettingsChanged);
	onSettingsChanged();
}

void TrayIcon::onActivated(QSystemTrayIcon::ActivationReason reason)
{
    Q_UNUSED(reason);
	emit appActivated();
}

void TrayIcon::onSettingsChanged()
{
    setIcon(_settings->linkHammerEnabled() ? _enabledIcon : _disabledIcon);
}
