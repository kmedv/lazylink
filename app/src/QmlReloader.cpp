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

#include "QmlReloader.h"
#include <QFileSystemWatcher>
#include <QDir>

static void findWatchObjects(const QString& searchRoot, QStringList* out)
{
    QDir dir{searchRoot};
    out->append(dir.absolutePath());
    auto files = dir.entryInfoList(QStringList{"*.qml"}, QDir::Files);
    for (const auto& f : files)
        out->append(f.absoluteFilePath());
    auto subdirs = dir.entryInfoList(QStringList{}, QDir::Dirs|QDir::NoDotAndDotDot);
    for (const auto& f : subdirs)
        findWatchObjects(f.absoluteFilePath(), out);
}

QmlReloader::QmlReloader(const QString& qmlDir, QQmlApplicationEngine* qmlEngine)
    : QObject(qmlEngine),
      _watcher{new QFileSystemWatcher(this)},
      _qmlDir{qmlDir},
      _qmlEngine{qmlEngine}
{
    Q_CHECK_PTR(qmlEngine);
    connect(_watcher, &QFileSystemWatcher::fileChanged, this, &QmlReloader::restartQmlEngine);
    connect(_watcher, &QFileSystemWatcher::directoryChanged, this, &QmlReloader::reinstallWatcher);
    reinstallWatcher();
}

void QmlReloader::restartQmlEngine(QString path)
{
    for (auto& obj : _qmlEngine->rootObjects())
        obj->deleteLater();
    _qmlEngine->clearComponentCache();
    _qmlEngine->load(QUrl::fromLocalFile(_qmlDir + "/main.qml"));
    _watcher->addPath(path);
}

void QmlReloader::reinstallWatcher()
{
    _watcher->removePaths(_watcher->directories() + _watcher->files());
    QStringList watchObjects;
    findWatchObjects(_qmlDir, &watchObjects);
    _watcher->addPaths(watchObjects);
}
