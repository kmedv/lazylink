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

#include <memory>
#include <QNetworkAccessManager>
#include "ShortenerService.h"

class QNetworkReply;
class QNetworkAccessManager;
class LinkPattern;
class Settings;

class LinkMonitor : public QObject
{
    Q_OBJECT

protected:
    LinkMonitor();

public:
    ~LinkMonitor() = default;

    virtual bool startMonitoring() = 0;
    virtual void stopMonitoring() = 0;

    QString lastError() const;

public slots:
    void tryShortenClipboardAsync();

signals:
    void linkClipped(QUrl shortLink);
    void error(QString error);

private slots:
    void handleNetReply(QNetworkReply* reply);

private:
    void setLastError(QString error);
    void emitError(QString err);
    bool replaceClipboard(QUrl shortUrl, QUrl longUrl);
    bool tryShortenTextAsync(QString text);

private:
    std::unique_ptr<ShortenerService> _shortenerService;
    QByteArray _prevCbrd;
    bool _isInProgress = false;
    QNetworkAccessManager* _net = nullptr;
    QString _lastError;
    Settings* _settings = nullptr;
};
