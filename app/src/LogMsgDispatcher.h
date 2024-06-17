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

#include <time.h>
#include <stdio.h>
#include <QDebug>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QStandardPaths>
#include <QSysInfo>
#include <sentry.h>
#include "Settings.h"


class LogMsgDispatcher
{
    Q_DISABLE_COPY_MOVE(LogMsgDispatcher);

public:
    static void installMessageHandler(LogMsgDispatcher* obj)
    {
        _GOBJ = obj;
        qInstallMessageHandler(LogMsgDispatcher::qtDebugMsgHandler);
    }

    LogMsgDispatcher() = default;

    ~LogMsgDispatcher()
    {
        disableLogFile();
        disableSentry();
    }

    bool isLogFileAvailable() const
    {
        return _logFile.isOpen();
    }

    void enableLogFile()
    {
        if (_logFile.isOpen())
            return;
        auto fname = QCoreApplication::applicationName() + ".log";
        auto fdir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        auto fpath = QString{"%1/%2"}.arg(fdir).arg(fname);
        if (!QDir{fdir}.exists())
            QDir{}.mkpath(fdir);
        _logFile.setFileName(fpath);
        if (_logFile.open(QIODevice::WriteOnly | QIODevice::Unbuffered)) {
            qInfo() << "Log file is enabled.";
        } else {
            qCritical("Failed to open the log file: fname = %s, err = %s",
                      qUtf8Printable(_logFile.fileName()),
                      qUtf8Printable(_logFile.errorString()));
        }
    }

    void disableLogFile()
    {
        _logFile.close();
        qInfo() << "Log file is disabled";
    }

    bool isSentryAvailable() const
    {
        return _sentryEnabled;
    }

    void enableSentry()
    {
        if (_sentryEnabled)
            return;
        auto options = sentry_options_new();
        // TODO: put your sentry DSN here.
        sentry_options_set_dsn(options, "https://<sentry-dsn>@<sentry-host>/0");
        sentry_options_set_release(options,
                                   qUtf8Printable(QCoreApplication::applicationVersion()));
        sentry_init(options);
        auto clientId = QSysInfo::machineUniqueId();
        auto user = sentry_value_new_object();
        sentry_value_set_by_key(user, "username", sentry_value_new_string(clientId));
        sentry_set_user(user);
#ifndef QT_DEBUG
        sentry_options_set_environment(options, "Release");
#else
        sentry_options_set_environment(options, "Debug");
#endif
        _sentryEnabled = true;
        qInfo("Sentry logging is enabled.");
    }

    void disableSentry()
    {
        sentry_shutdown();
        _sentryEnabled = false;
        qInfo() << "Sentry logging is disabled";
    }

private:
    static void qtDebugMsgHandler(QtMsgType type, const QMessageLogContext& context,
                                  const QString& msg)
    {
        assert(_GOBJ);

        // Timestamp is injected into the log message as well.
        time_t t;
        tm tinfo;
        char tstamp[32];
        time(&t);
    #ifdef Q_OS_WIN
        localtime_s(&tinfo, &t);
    #else
        localtime_r(&t, &tinfo);
    #endif
        strftime(tstamp, sizeof(tstamp), "%F %T", &tinfo);

        char fullMsg[4096];
        const char* fmt = nullptr;
        switch (type) {
        case QtDebugMsg:
            fmt = "%s [%s:%d] Debug - %s";
            break;
        case QtInfoMsg:
            fmt = "%s [%s:%d] Info - %s";
            break;
        case QtWarningMsg:
            fmt = "%s [%s:%d] Warning - %s";
            break;
        case QtCriticalMsg:
            fmt = "%s [%s:%d] Critical - %s";
            break;
        case QtFatalMsg:
            fmt = "%s [%s:%d] Fatal - %s";
            break;
        }
        // Dispatch the message.
        auto len = snprintf(fullMsg, sizeof(fullMsg), fmt,
                            tstamp, context.file, context.line,
                            qUtf8Printable(msg));
        if (len >= 0) {
            _GOBJ->dispatchMessage(type, fullMsg, len);
        } else {
            _GOBJ->writeToStdout("Log message is too long to dispatch.");
        }
    }

    void dispatchMessage(QtMsgType type, const char* msg, int len)
    {
        if (isSentryAvailable())
            writeToSentry(type, msg);
        if (isLogFileAvailable())
            writeToLogFile(msg, len);
        writeToStdout(msg);
    }

    void writeToSentry(QtMsgType type, const char* msg)
    {
        sentry_level_t lvl;
        switch (type) {
        case QtDebugMsg:
            lvl = SENTRY_LEVEL_DEBUG;
            break;
        case QtInfoMsg:
            lvl = SENTRY_LEVEL_INFO;
            break;
        case QtWarningMsg:
            lvl = SENTRY_LEVEL_WARNING;
            break;
        case QtCriticalMsg:
            lvl = SENTRY_LEVEL_ERROR;
            break;
        case QtFatalMsg:
            lvl = SENTRY_LEVEL_FATAL;
            break;
        }
        Settings settings;
        if ((lvl >= SENTRY_LEVEL_ERROR && settings.sendCriticalInfoEnabled())
                || (lvl < SENTRY_LEVEL_ERROR && settings.sendDebugInfoEnabled())) {
            auto sentryMsg = sentry_value_new_message_event(lvl, "default", msg);
            sentry_capture_event(sentryMsg);
        }
    }

    void writeToLogFile(const char* msg, int len)
    {
        _logFile.write(msg, len);
        _logFile.write("\n");
    }

    void writeToStdout(const char* msg)
    {
        puts(msg);
    }

private:
    static LogMsgDispatcher* _GOBJ;
    bool _sentryEnabled = false;
    QFile _logFile;
};

LogMsgDispatcher* LogMsgDispatcher::_GOBJ = nullptr;
