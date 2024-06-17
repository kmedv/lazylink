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

import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import "patterns/"
import "settings/"

ShadowedWindow {
    id: appWnd

    property var popupWnd: undefined

    signal closePopup

    function showFromTray(trayIconRect) {
        if (appWnd.isMacOS()) {
            // On macOs the tray icon is always on top edge, so simply
            // show the app under the icon.
            appWnd.x = trayIconRect.x + trayIconRect.width / 2 - appWnd.width / 2;
            appWnd.y = trayIconRect.height + dp_4;
        }
        showNormal();
        raise();
    }

    function showNotification(msg, showCloseButton, showViewButton) {
        notification.open(msg, showCloseButton, showViewButton);
    }

    function closeNotification() {
        notification.close();
    }

    function isMacOS() {
        return Qt.platform.os == "osx"
    }

    function isWindows() {
        return Qt.platform.os == "windows"
    }

    title: "Lazylink"
    flags: ShadowedWindow.recommendedFlags | Qt.Tool
           | Qt.FramelessWindowHint
           | Qt.WindowStaysOnTopHint
    visible: false

    radius: dp_3
    backgroundColor: "#e7e9f2"

    shadowEnabled: appWnd.isMacOS() ? false : true
    shadowColor: Qt.rgba(0, 0, 0, 0.3)
    shadowBlurRadius: dp_30
    shadowVerticalOffset: dp_17
    shadowHorizontalOffset: 0

    content: appContent

    onActiveChanged: {
        if (!active) {
            visible = false;
            closePopup();       // close the menu
        }
    }

    Component.onCompleted: {
        if (appWnd.isMacOS()) {
            // Make background a little smaller on macOs for the top arrow
            // to have transparent back.
            appWnd.backY += dp_15;
            appWnd.backHeight -= dp_15;
        }
    }

    FontLoader {id: robotoMedium; source: "qrc:/font/Roboto-Medium.ttf"}
    FontLoader {id: robotoRegular; source: "qrc:/font/Roboto-Regular.ttf"}
    FontLoader {id: robotoBold; source: "qrc:/font/Roboto-Bold.ttf"}

    Item {
        id: appContent
        width: dp_300
        height: dp_468

        SystemBar {
            id: systemBar
            anchors {
                top: parent.top
                topMargin: dp_1
                left: parent.left
                leftMargin: dp_1
                right: parent.right
                rightMargin: dp_1
            }
            height: dp_24
            z: 1
            onMinimize: appWnd.showMinimized()
            onClose: appWnd.close()
            visible: !appWnd.isMacOS()
        }

        LogoPanel {
            id: logoPanel
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        }

        // Stretchable elements {

        PatternsFragment {
            id: patternsFragment
            anchors {
                left: parent.left
                right: parent.right
                top: logoPanel.bottom
                bottom: footerBorder.top
            }
        }

        SettingsFragment {
            id: settingsFragment
            anchors {
                left: parent.left
                right: parent.right
                top: logoPanel.bottom
                bottom: footerBorder.top
            }
            visible: false
            onBack: {
                visible = false;
                patternsFragment.visible = true;
            }
        }

        // }

        Rectangle {
            id: footerBorder
            anchors {
                left: parent.left
                right: parent.right
                bottom: footer.top
            }
            height: dp_1
            color: "#000000"
            opacity: 0.06
        }

        BottomBar {
            id: footer
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: dp_54
            onOpenSettings: {
                patternsFragment.visible = false;
                settingsFragment.visible = true;
            }
            onExitApplication: Qt.quit()
            onDonate: Qt.openUrlExternally("https://lazylink.net")
        }
    }

    NotificationPopup {
        id: notification
        objectName: "notification"
    }

    MouseArea {
        id: popupCloseInterceptor
        anchors.fill: appWnd.contentItem
        z: 10
        enabled: (typeof(appWnd.popupWnd) == "object")
        visible: enabled
        onPressed: appWnd.closePopup()
    }
}

