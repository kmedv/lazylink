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

#include "Settings.h"

#include <functional>
#include <QGuiApplication>
#include <QMessageBox>
#include <QDate>
#include <QSettings>
#include <QDebug>
#include "AppContext.h"

const auto KEY_CLIPS = "clips";
const auto KEY_CLIP_URL = "url";
const auto KEY_LAUNCH_ON_LOGIN = "launch_on_login";
const auto KEY_NOTIFICATIONS = "notifications";
const auto KEY_LINK_HAMMER = "link_hammer";
const auto KEY_CHECK_UPDATE_ON_STARTUP = "check_update_on_startup";
const auto KEY_SUBDOMAINS_DISABLED = "subdomains_disabled";
const auto KEY_LEASING_START = "r1";
const auto KEY_QUERIES_LEFT = "r2";
const auto KEY_SEND_CRITICAL_INFO = "send_critical_info";
const auto KEY_SEND_DEBUG_INFO = "send_debug_info";

static auto qs()
{
    return std::make_unique<QSettings>(
                QSettings::IniFormat,
                QSettings::UserScope,
                qApp->organizationName(),
                qApp->applicationName());
}

Settings::Settings(QObject* parent)
    : QObject(parent)
{
    readPatterns();
    connect(this, &Settings::changed, this, &Settings::readPatterns);
}

const std::vector<LinkPattern>& Settings::patterns() const
{
    return _patterns;
}

QStringList Settings::patternStrings() const
{
    QStringList res;
    for (const auto& p : _patterns)
        res << p.pattern();
    return res;
}

void Settings::addPattern(QString pattern)
{
    if (findPatternIndex(pattern) == _patterns.size()) {
        _patterns.push_back(pattern);
        writePatterns();
        emit changed();
        qDebug() << "Pattern added:" << pattern;
        qInfo() << "Pattern added.";
    } else {
        qInfo() << "Pattern already present:" << pattern;
    }
}

void Settings::replacePattern(QString prev, QString pattern)
{
    auto p = findPatternIndex(prev);
    if (p < _patterns.size()) {
        _patterns[p] = pattern;
        writePatterns();
        emit changed();
        qDebug() << "Pattern replaced:"
                 << "prev =" << prev
                 << "pattern =" << pattern;
        qInfo() << "Pattern replaced.";
    } else {
        qWarning() << "Pattern cannot be replaced, original not found:"
                   << "prev =" << prev
                   << "pattern =" << pattern;
    }
}

void Settings::removePattern(QString pattern)
{
    auto p = findPatternIndex(pattern);
    if (p < _patterns.size()) {
        _patterns.erase(_patterns.cbegin() + ptrdiff_t(p));
        writePatterns();
        emit changed();
        qDebug() << "Pattern removed:" << pattern;
        qInfo() << "Pattern removed.";
    } else {
        qWarning() << "Pattern cannot be removed, original not found:" << pattern;
    }
}

size_t Settings::findPatternIndex(const QString& str)
{
    for (size_t i = 0; i < _patterns.size(); ++i)
        if (_patterns[i].pattern() == str)
            return i;
    return _patterns.size();
}

bool Settings::launchOnLoginEnabled()
{
    return qs()->value(KEY_LAUNCH_ON_LOGIN, false).toBool();
}

void Settings::setLaunchOnLoginEnabled(bool enabled)
{
    qs()->setValue(KEY_LAUNCH_ON_LOGIN, enabled);
    emit changed();
}

bool Settings::notificationsEnabled()
{
    return qs()->value(KEY_NOTIFICATIONS, true).toBool();
}

void Settings::setNotificationsEnabled(bool enabled)
{
    qs()->setValue(KEY_NOTIFICATIONS, enabled);
    emit changed();
}

bool Settings::checkUpdateOnStartup()
{
    return qs()->value(KEY_CHECK_UPDATE_ON_STARTUP, true).toBool();
}

void Settings::setCheckUpdateOnStartup(bool enabled)
{
    qs()->setValue(KEY_CHECK_UPDATE_ON_STARTUP, enabled);
    emit changed();
}

bool Settings::linkHammerEnabled()
{
    return qs()->value(KEY_LINK_HAMMER, true).toBool();
}

void Settings::setLinkHammerEnabled(bool enabled)
{
    qs()->setValue(KEY_LINK_HAMMER, enabled);
    emit changed();
}

bool Settings::subdomainsDisabled()
{
    return qs()->value(KEY_SUBDOMAINS_DISABLED, false).toBool();
}

void Settings::setSubdomainsDisabled(bool disabled)
{
    qs()->setValue(KEY_SUBDOMAINS_DISABLED, disabled);
    emit changed();
}

bool Settings::sendCriticalInfoEnabled()
{
    return qs()->value(KEY_SEND_CRITICAL_INFO, true).toBool();
}

void Settings::setSendCriticalInfoEnabled(bool enabled)
{
    qs()->setValue(KEY_SEND_CRITICAL_INFO, enabled);
    emit changed();
}

bool Settings::sendDebugInfoEnabled()
{
    return qs()->value(KEY_SEND_DEBUG_INFO, false).toBool();
}

void Settings::setSendDebugInfoEnabled(bool enabled)
{
    qs()->setValue(KEY_SEND_DEBUG_INFO, enabled);
    emit changed();
}

uint Settings::leasingStartUtc()
{
    return qs()->value(KEY_LEASING_START, 0).toUInt();
}

void Settings::setLeasingStartUtc(uint utcDate)
{
    qDebug() << "Leasing moved to" << utcDate;
    qs()->setValue(KEY_LEASING_START, utcDate);
    emit changed();
}

uint Settings::queriesLeft()
{
    return qs()->value(KEY_QUERIES_LEFT, 0).toUInt();
}

void Settings::setQueriesLeft(uint n)
{
    qDebug() << "Queries left:" << n;
    qs()->setValue(KEY_QUERIES_LEFT, n);
    emit changed();
}

void Settings::readPatterns()
{
    auto settings = qs();
    int sz = settings->beginReadArray(KEY_CLIPS);
    decltype(_patterns) patterns;
    for (int i = 0; i < sz; ++i) {
        settings->setArrayIndex(i);
        auto pattern = settings->value(KEY_CLIP_URL).toString();
        patterns.push_back(pattern);
    }
    settings->endArray();
    _patterns = std::move(patterns);
}

void Settings::writePatterns()
{
    auto settings = qs();
    settings->beginWriteArray(KEY_CLIPS, int(_patterns.size()));
    for (size_t i = 0; i < _patterns.size(); ++i) {
        settings->setArrayIndex(int(i));
        settings->setValue(KEY_CLIP_URL, _patterns[i].pattern());
    }
    settings->endArray();
}
