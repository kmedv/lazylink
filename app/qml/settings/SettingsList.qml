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
import net.lazylink 1.0

Item {
    id: root
    implicitHeight: content.height

    Column {
        id: content
        anchors {
            top: parent.top
            topMargin: dp_24
            left: parent.left
            leftMargin: dp_24
            right: parent.right
            rightMargin: dp_24
        }
        spacing: dp_12

        SettingsCheckBox {
            id: startOnLogin
            anchors {
                left: parent.left
                right: parent.right
            }
            text: qsTr("Start on login")
            checked: Settings.launchOnLoginEnabled
            onToggled: Settings.launchOnLoginEnabled = checked
        }

        SettingsCheckBox {
            id: showNotifications
            anchors {
                left: parent.left
                right: parent.right
            }
            text: qsTr("Show notifications")
            checked: Settings.notificationsEnabled
            onToggled: Settings.notificationsEnabled = checked
        }

        SettingsCheckBox {
            id: updateOnStartup
            anchors {
                left: parent.left
                right: parent.right
            }
            text: qsTr("Check for updates on startup")
            checked: Settings.checkUpdateOnStartup
            visible: !appWnd.isMacOS()
            onToggled: Settings.checkUpdateOnStartup = checked
        }

        SettingsCheckBox {
            id: useShortenHotkey
            anchors {
                left: parent.left
                right: parent.right
            }
            text: appWnd.isMacOS()
                  ? qsTr("Use ⌘+⌥+V to enter shortened URL from any website")
                  : qsTr("Use Ctrl+Alt+V to enter shortened URL from any website")
            enabled: false
        }

        SettingsCheckBox {
            id: disableSubdomainsMatch
            anchors {
                left: parent.left
                right: parent.right
            }
            text: qsTr("Disable subdomains matching");
            checked: Settings.subdomainsDisabled
            onToggled: Settings.subdomainsDisabled = checked
        }

        SettingsCheckBox {
            id: sendCriticalInfo
            anchors {
                left: parent.left
                right: parent.right
            }
            text: qsTr("Send critical errors");
            checked: Settings.sendCriticalInfoEnabled
            onToggled: Settings.sendCriticalInfoEnabled = checked
        }

        SettingsCheckBox {
            id: sendDebugInfo
            anchors {
                left: parent.left
                right: parent.right
            }
            text: qsTr("Send debug information");
            checked: Settings.sendDebugInfoEnabled
            onToggled: Settings.sendDebugInfoEnabled = checked
        }

        Rectangle {
            id: separator
            anchors {
                left: parent.left
                right: parent.right
            }
            height: dp_1
            color: Qt.rgba(0, 0, 0, 0.11)
        }
    }
}
