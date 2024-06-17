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

#include <vector>
#include <mutex>
#include <QObject>
#include "LinkPattern.h"

class QQmlEngine;
class QJSEngine;

class Settings : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList patternStrings
               READ patternStrings
               NOTIFY changed)
    Q_PROPERTY(bool launchOnLoginEnabled
               READ launchOnLoginEnabled WRITE setLaunchOnLoginEnabled
               NOTIFY changed)
    Q_PROPERTY(bool notificationsEnabled
               READ notificationsEnabled WRITE setNotificationsEnabled
               NOTIFY changed)
    Q_PROPERTY(bool checkUpdateOnStartup
               READ checkUpdateOnStartup WRITE setCheckUpdateOnStartup
               NOTIFY changed)
    Q_PROPERTY(bool linkHammerEnabled
               READ linkHammerEnabled WRITE setLinkHammerEnabled
               NOTIFY changed)
    Q_PROPERTY(bool subdomainsDisabled
               READ subdomainsDisabled WRITE setSubdomainsDisabled
               NOTIFY changed)
    Q_PROPERTY(bool sendCriticalInfoEnabled
               READ sendCriticalInfoEnabled WRITE setSendCriticalInfoEnabled
               NOTIFY changed)
    Q_PROPERTY(bool sendDebugInfoEnabled
               READ sendDebugInfoEnabled WRITE setSendDebugInfoEnabled
               NOTIFY changed)

public:
    explicit Settings(QObject* parent = nullptr);

public slots:
    void addPattern(QString pattern);
    void replacePattern(QString prev, QString pattern);
    void removePattern(QString pattern);

public:
    const std::vector<LinkPattern>& patterns() const;
    QStringList patternStrings() const;

    bool launchOnLoginEnabled();
    void setLaunchOnLoginEnabled(bool enabled);

    bool notificationsEnabled();
    void setNotificationsEnabled(bool enabled);

    bool checkUpdateOnStartup();
    void setCheckUpdateOnStartup(bool enabled);

    bool linkHammerEnabled();
    void setLinkHammerEnabled(bool enabled);

    bool subdomainsDisabled();
    void setSubdomainsDisabled(bool disabled);

    bool sendCriticalInfoEnabled();
    void setSendCriticalInfoEnabled(bool enabled);

    bool sendDebugInfoEnabled();
    void setSendDebugInfoEnabled(bool enabled);

    uint leasingStartUtc();
    void setLeasingStartUtc(const uint utcDate);

    uint queriesLeft();
    void setQueriesLeft(uint n);

signals:
    void changed();

private:
    size_t findPatternIndex(const QString& patternStr);

    void readPatterns();
    void writePatterns();

private:
    std::vector<LinkPattern> _patterns;
};
