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

#include <QtTest>
#include <QCoreApplication>
#include "LinkPattern.cpp"

// add necessary includes here

class LazylinkTest : public QObject
{
    Q_OBJECT

public:
    LazylinkTest();
    ~LazylinkTest();

private slots:
    void initTestCase();
    void cleanupTestCase();
    void test_LinkPattern_match();

};

LazylinkTest::LazylinkTest()
{

}

LazylinkTest::~LazylinkTest()
{

}

void LazylinkTest::initTestCase()
{

}

void LazylinkTest::cleanupTestCase()
{


}

void LazylinkTest::test_LinkPattern_match()
{
    LinkPattern p1{"yandex.ru"};
    QVERIFY(p1.matches("yandex.ru", true));
    QVERIFY(p1.matches("subd1.yandex.ru", true));
    QVERIFY(p1.matches("s1.s2.yandex.ru", true));
    QVERIFY(p1.matches("s1.s2.s3.yandex.ru", true));

    QVERIFY(p1.matches("https://yandex.ru", true));
    QVERIFY(p1.matches("https://subd1.yandex.ru", true));
    QVERIFY(p1.matches("https://s1.s2.yandex.ru", true));
    QVERIFY(p1.matches("https://s1.s2.s3.yandex.ru", true));
    QVERIFY(p1.matches("https://s1.s2.s3.s4.yandex.ru", true));

    QVERIFY(p1.matches("yandex.ru", false));
    QVERIFY(!p1.matches("subd1.yandex.ru", false));
    QVERIFY(!p1.matches("s1.s2.yandex.ru", false));
    QVERIFY(!p1.matches("s1.s2.s3.yandex.ru", false));

    QVERIFY(p1.matches("https://yandex.ru", false));
    QVERIFY(!p1.matches("https://subd1.yandex.ru", false));
    QVERIFY(!p1.matches("https://s1.s2.yandex.ru", false));
    QVERIFY(!p1.matches("https://s1.s2.s3.yandex.ru", false));
    QVERIFY(!p1.matches("https://s1.s2.s3.s4.yandex.ru", false));

    LinkPattern p2{"onlinetrade.ru"};
    QVERIFY(p2.matches("https://www.onlinetrade.ru/actions/skidka_20_na_tekhniku_philips_po_promoko"
                       "du-a6012.html?utm_source=internal&utm_medium=twister&utm_campaign=b7861",
                       true));

    LinkPattern p3{"trello.com"};
    QVERIFY(p3.matches("https://trello.com/b/NiWXe3SA/%D0%B8%D0%BB%D0%BB%D1%8E%D1%81%D1%82%D1%80%D0"
                       "%B0%D1%86%D0%B8%D0%B8", true));

    LinkPattern p4{"amazonaws.com"};
    QVERIFY(p4.matches("https://trello-attachments.s3.amazonaws.com/56d58109a9aaa5ab6df5159f/5e416a"
                       "d97d6fe36c78eb173a/ddc84eb3baa0f88737329529b1f4c094/Index-Shields-1920.png",
                       true));
}


QTEST_MAIN(LazylinkTest)

#include "tst_lazylinktest.moc"
