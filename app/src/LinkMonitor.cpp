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

#include "LinkMonitor.h"

#include <cassert>
#include <QApplication>
#include <QClipboard>
#include <QMimeData>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QUrl>
#include <QThread>
#include <QDebug>

#include "App.h"
#include "AppContext.h"
#include "Notifier.h"
#include "ShortenerRequest.h"
#include "ShortenerResponse.h"
#include "GooglShortenerService.h"
#include "BitlyShortenerService.h"
#include "Settings.h"

static constexpr qint64 LEASING_PERIOD_SECS = 24 * 60 * 60;        // 1 day
static constexpr uint QUERIES_PER_LEASE = 200;                     // Shortenings per day
static constexpr int URL_MIN_LENGTH = 4;
static constexpr int URL_MAX_LENGTH = 2048;
static constexpr auto MIME_PLAIN_TEXT = "text/plain";

LinkMonitor::LinkMonitor()
    : _shortenerService{new BitlyShortenerService()},
      _net{new QNetworkAccessManager(this)},
      _settings{App::appContext()->settings(this)}
{
    connect(_net, &QNetworkAccessManager::finished, this, &LinkMonitor::handleNetReply);
}

QString LinkMonitor::lastError() const
{
    return _lastError;
}

void LinkMonitor::tryShortenClipboardAsync()
{
    if (_isInProgress || !_settings->linkHammerEnabled())
        return;

    QByteArray validCbrd;
    const auto* mime = qApp->clipboard()->mimeData();
    Q_CHECK_PTR(mime);
    if (mime->hasText()) {
        auto cbrdData = mime->data(MIME_PLAIN_TEXT);
        if (cbrdData.length() >= URL_MIN_LENGTH && cbrdData.length() <= URL_MAX_LENGTH)
            validCbrd = cbrdData;
    }

    if (validCbrd.length() != _prevCbrd.length()
            || validCbrd.compare(_prevCbrd, Qt::CaseSensitive) != 0) {
        _prevCbrd = validCbrd;
        if (!validCbrd.isEmpty())
            _isInProgress = tryShortenTextAsync(validCbrd);
    }
}

void LinkMonitor::setLastError(QString error)
{
    _lastError = error;
}

void LinkMonitor::emitError(QString err)
{
    setLastError(err);
    emit error(lastError());
}

bool LinkMonitor::replaceClipboard(QUrl shortUrl, QUrl)
{
    const auto* mime = qApp->clipboard()->mimeData();
    if (mime->hasText()) {
        auto cbrdData = mime->data(MIME_PLAIN_TEXT);
        if (cbrdData == _prevCbrd) {
            auto str = shortUrl.toString();
            qApp->clipboard()->setText(str);
            return true;
        }
    }
    return false;
}

bool LinkMonitor::tryShortenTextAsync(QString text)
{
    auto longUrl = QUrl{text, QUrl::StrictMode};
    if (!longUrl.isValid()) {
        qInfo() << "Shorten rejected: clipboard content is not a valid URL.";
        return false;
    }

    const LinkPattern* pattern = nullptr;
    for (const auto& p : _settings->patterns()) {
        if (p.matches(text, !_settings->subdomainsDisabled())) {
            pattern = &p;
            break;
        }
    }
    if (!pattern) {
        qDebug() << "Shorten rejected: clipboard content is an URL, but doesn't match any pattern.";
        return false;
    }
    qDebug() << "Clipboard matched pattern:" << pattern->toString();


    // A simple spam filter.
    auto nowUtc = QDateTime::currentSecsSinceEpoch();
    if (nowUtc - _settings->leasingStartUtc() > LEASING_PERIOD_SECS) {
        _settings->setLeasingStartUtc(uint(nowUtc));
        _settings->setQueriesLeft(QUERIES_PER_LEASE);
    }
    auto queriesLeft = _settings->queriesLeft();
    if (queriesLeft < 1) {
        qWarning() << "Shorten rejected: Queries limit reached!";
        emitError("Queries limit reached, shortening was aborted!");
        return false;
    }

    qDebug() << "Shorten accepted.";
    auto r = _shortenerService->constructRequest(longUrl);
    if (r.isValid()) {
        QNetworkReply* reply = nullptr;
        if (r.isPostRequest) {
            qDebug() << "Sending POST:"
                     << "url =" << r.request.url().toString()
                     << "body =" << r.data;
            reply = _net->post(r.request, r.data);
        } else {
            qDebug() << "Sending GET:" << r.request.url().toString();
            reply = _net->get(r.request);
        }
        if (reply->error() != QNetworkReply::NoError) {
            qCritical() << "Network error:" << reply->errorString();
            emitError("Network error");
            return false;
        }
        _settings->setQueriesLeft(queriesLeft - 1);
        return true;
    } else {
        qCritical() << "Failed to construct request:" << _shortenerService->lastError();
        emitError(_shortenerService->lastError());
    }
    return false;
}

void LinkMonitor::handleNetReply(QNetworkReply* reply)
{
    assert(_isInProgress);

    if (!reply->error()) {
        auto response = reply->readAll();
        qDebug() << "Received network response:" << response;
        auto parsed = _shortenerService->handleResponse(response);
        if (parsed.isValid()) {
            if (replaceClipboard(parsed.shortUrl, parsed.longUrl)) {
                qInfo() << "Link is shortened.";
                qDebug() << "Link is shortened:"
                         << "longUrl =" << parsed.longUrl
                         << "shortUrl =" << parsed.shortUrl;
                emit linkClipped(parsed.shortUrl);
            } else {
                qWarning() << "Clipboard was updated after request, replace skipped.";
            }
        } else {
            qCritical() << "Failed to parse service response:" << _shortenerService->lastError();
            emitError(_shortenerService->lastError());
        }

    } else {
        qCritical() << "Server error:" << reply->errorString();
        emitError(reply->errorString());
    }

    reply->deleteLater();

    _isInProgress = false;
}

