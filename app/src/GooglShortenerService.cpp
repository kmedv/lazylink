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

#include "GooglShortenerService.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

// TODO: put your Google API key here
static const QString API_KEY = "";
static const QString SHORTENER_URL = "https://www.googleapis.com/urlshortener/v1/url"
                                     "?key=" + API_KEY;

ShortenerRequest GooglShortenerService::constructRequest(QUrl longUrl)
{
    QNetworkRequest r;
    r.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    r.setUrl(SHORTENER_URL);
    ShortenerRequest res;
    res.isPostRequest = true;
    res.request = r;
    res.data.append("{\"longUrl\": \"").append(longUrl.toEncoded()).append("\"}");
    return res;
}

ShortenerResponse GooglShortenerService::handleResponse(QByteArray response)
{
    ShortenerResponse res;

    QJsonDocument json = QJsonDocument::fromJson(response);
    if (json.isNull()) {
        qCritical() << "Null JSON response.";
        setLastError("Null JSON response.");
        return res;
    }

    QJsonObject rootObj = json.object();
    auto fullUrlIter = rootObj.find("longUrl");
    auto shortUrlIter = rootObj.find("id");
    if (fullUrlIter == rootObj.end() || shortUrlIter == rootObj.end()) {
        qWarning() << "Invalid Googl response format.";
        setLastError("Invalid Googl response format.");
        return res;
    }

    QString longUrl = fullUrlIter.value().toString();
    QString shortUrl = shortUrlIter.value().toString();
    if (longUrl.isEmpty() || shortUrl.isEmpty()) {
        qWarning() << "Empty URL received.";
        setLastError("Empty URL received.");
    } else {
        res.shortUrl = {shortUrl, QUrl::StrictMode};
        res.longUrl = {longUrl, QUrl::StrictMode};
    }

    return res;
}
