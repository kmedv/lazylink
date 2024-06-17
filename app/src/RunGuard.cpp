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

#include "RunGuard.h"
#include <QCryptographicHash>

QString generateKeyHash(const QString& key, const QString& salt)
{
    QByteArray data;
    data.append(key.toLatin1());
    data.append(salt.toLatin1());
    data = QCryptographicHash::hash(data, QCryptographicHash::Sha1).toHex();
    return data;
}

RunGuard::RunGuard(const QString& key)
    : _key(key),
      _memLockKey(generateKeyHash(key, "_memLockKey")),
      _sharedmemKey(generateKeyHash(key, "_sharedmemKey")),
      _sharedMem(_sharedmemKey),
      _memLock(_memLockKey, 1)
{
    _memLock.acquire();
    QSharedMemory fix{_sharedmemKey};    // Fix for *nix: http://habrahabr.ru/post/173281/
    fix.attach();
    _memLock.release();
}

RunGuard::~RunGuard()
{
    release();
}

bool RunGuard::isAnotherRunning()
{
    if (_sharedMem.isAttached())
        return false;

    _memLock.acquire();
    const bool isRunning = _sharedMem.attach();
    if (isRunning)
        _sharedMem.detach();
    _memLock.release();

    return isRunning;
}

bool RunGuard::tryToRun()
{
    if (isAnotherRunning())   // Extra check
        return false;
    _memLock.acquire();
    const bool result = _sharedMem.create(sizeof(quint64));
    _memLock.release();
    if (!result) {
        release();
        return false;
    }
    return true;
}

void RunGuard::release()
{
    _memLock.acquire();
    if (_sharedMem.isAttached())
        _sharedMem.detach();
    _memLock.release();
}
