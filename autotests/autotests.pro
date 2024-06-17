QT += testlib
QT += gui
CONFIG += qt warn_on depend_includepath testcase

TEMPLATE = app

INCLUDEPATH += ../app/src

SOURCES += \
    tst_lazylinktest.cpp
