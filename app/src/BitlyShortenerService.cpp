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

#include "BitlyShortenerService.h"
#include <cassert>
#include <QDebug>
#include <QUrlQuery>
#include <QJsonDocument>
#include <QJsonObject>
#include <QApplication>
#include "simplecrypt.h"


static constexpr auto AUTH_HEADER = "Authorization";
static constexpr auto TOKEN_ENC = "";   // TODO: Put your Bitly token here

ShortenerRequest BitlyShortenerService::constructRequest(QUrl longUrl)
{
    QByteArray token;
    {
       // This is a naive protection of the authorization key in static resources.
       QByteArray key;
       key.append(AUTH_HEADER[7]);
       key.append(AUTH_HEADER[6]);
       key.append(AUTH_HEADER[2]);
       key.append(AUTH_HEADER[8]);
       key.append(AUTH_HEADER[1]);
       key.append(AUTH_HEADER[12]);
       key.append(AUTH_HEADER[2]);
       key.append(AUTH_HEADER[11]);
       auto uintKey = (*reinterpret_cast<const quint64*>(key.data()));
       SimpleCrypt crypto;
       crypto.setKey(uintKey);
       crypto.setIntegrityProtectionMode(SimpleCrypt::ProtectionNone);
       crypto.setCompressionMode(SimpleCrypt::CompressionNever);
       token = crypto.decryptToByteArray(QByteArray::fromBase64(TOKEN_ENC));
    }

    QJsonObject jsonObj = {{"long_url", QJsonValue::fromVariant(longUrl.toEncoded())}};
    auto json = QJsonDocument{jsonObj};
    auto jsonData = json.toJson(QJsonDocument::Compact);

    QUrl url;
    url.setScheme("https");
    url.setHost("api-ssl.bitly.com");
    url.setPath("/v4/shorten");

    QNetworkRequest r;
    r.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    r.setRawHeader(AUTH_HEADER, QByteArray{"Bearer "} + token);
    r.setUrl(url);

    ShortenerRequest res;
    res.isPostRequest = true;
    res.request = r;
    res.data = jsonData;
    return res;
}

ShortenerResponse BitlyShortenerService::handleResponse(QByteArray response)
{
    ShortenerResponse res;
    QJsonParseError jsonErr;
    auto json = QJsonDocument::fromJson(response, &jsonErr);
    if (jsonErr.error == QJsonParseError::NoError) {
        auto rootObj = json.object();
        auto longUrlStr = rootObj["long_url"].toString();
        auto shortUrlStr = rootObj["link"].toString();
        if (!shortUrlStr.isNull() && !longUrlStr.isNull()) {
            res.longUrl = {longUrlStr, QUrl::DecodedMode};
            res.shortUrl = {shortUrlStr, QUrl::StrictMode};
        }
    }
    if (!res.isValid()) {
        qWarning() << "Failed to parse JSON response: err =" << jsonErr.errorString();
        setLastError(qApp->tr("Unknown shortening service response format."));
        return ShortenerResponse{};
    }
    return res;
}
