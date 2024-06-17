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

#include "LinkPattern.h"
#include <QDebug>

LinkPattern::LinkPattern(const QString& pattern)
{
    QString str = QRegularExpression::escape(pattern);
    str.replace("\\*", ".*");     // Support for * wildcard.

    {   // Regexp for direct matching (without subdomains).
        QString nosubdomainsStr = str.contains("://")
                ? "^" + str
                : "^(\\w+://)?" + str;
        auto regexp = QRegularExpression{nosubdomainsStr};
        regexp.setPatternOptions(QRegularExpression::CaseInsensitiveOption
                                 | QRegularExpression::UseUnicodePropertiesOption
                                 | QRegularExpression::DontCaptureOption);
        regexp.optimize();
        _regExp = regexp;
    }

    {   // Regexp with subdomains enabled.
        QString subdomainsStr = str;
        if (subdomainsStr.contains("://")) {
            subdomainsStr = "^" + subdomainsStr;
            subdomainsStr.replace("://", "://(.+\\.)*");
        } else {
            subdomainsStr = "^(\\w+://)?(.+\\.)*" + subdomainsStr;
        }
        auto regexp = QRegularExpression{subdomainsStr};
        regexp.setPatternOptions(QRegularExpression::CaseInsensitiveOption
                                 | QRegularExpression::UseUnicodePropertiesOption
                                 | QRegularExpression::DontCaptureOption);
        regexp.optimize();
        _regExpWithSubdomains = regexp;
    }

    _pattern = pattern;
    qDebug() << "Pattern created:" << toString();
}

const QString& LinkPattern::pattern() const
{
    return _pattern;
}

QString LinkPattern::toString() const
{
    return QString{"LinkPattern {pattern = %1, regExp = %2, regExpWithSubdomains = %3}"}
            .arg(_pattern).arg(_regExp.pattern()).arg(_regExpWithSubdomains.pattern());
}

bool LinkPattern::matches(const QString& url, bool withSubdomains) const
{
    if (withSubdomains)
        return _regExpWithSubdomains.match(url).hasMatch();
    return _regExp.match(url).hasMatch();
}
