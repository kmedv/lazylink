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
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

ShadowedWindow {
    id: notificationWnd

    property alias message: messageItem.text
    property alias actionText: actionButton.text

    function open(message, actionText) {
        console.log("Opening notification: message=", message, " action text=", actionText);
        notificationWnd.message = message;
        notificationWnd.actionText = actionText;
        showNormal();
    }

    signal actionClicked
    signal closeClicked

    x: Screen.desktopAvailableWidth - notificationWnd.width - dp_20
    y: dp_40
    radius: dp_5
    backgroundColor: Qt.rgba(1, 1, 1, 0.9)

    shadowEnabled: appWnd.shadowEnabled
    shadowColor: Qt.rgba(0, 0, 0, 0.3)
    shadowBlurRadius: dp_10
    shadowVerticalOffset: dp_3

    flags: recommendedFlags
           | Qt.Popup | Qt.FramelessWindowHint
           | Qt.WindowStaysOnTopHint
           | Qt.WindowDoesNotAcceptFocus
           | (appWnd.isWindows() ? Qt.WA_ShowWithoutActivating : 0)
    content: wndContent

    Item {
        id: wndContent

        implicitWidth: dp_328
        implicitHeight: Math.ceil(title.anchors.topMargin + title.height
                        + messageItem.anchors.topMargin + messageItem.height
                        + actionButton.anchors.topMargin
                        + (actionButton.visible ? actionButton.height + dp_23 : 0))

        LinearGradient {
            id: backgroundGradient
            anchors.fill: parent
            start: Qt.point(0, height * 1/3)
            end: Qt.point(width, height * 2/3)
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#6cb0ff"
                }
                GradientStop {
                    position: 1.0
                    color: "#5d7aff"
                }

            }
            cached: true
        }

        Image {
            id: logo
            anchors {
                left: parent.left
                leftMargin: dp_16
                top: parent.top
                topMargin: dp_16
            }
            width: dp_32
            height: dp_32
            source: "qrc:/icon/logo-notification.png"
            smooth: false
        }

        Text {
            id: title
            anchors {
                left: logo.right
                leftMargin: dp_16
                top: parent.top
                topMargin: dp_16
            }
            width: Math.ceil(implicitWidth)
            text: "Lazylink"
            color: "#ffffff"
            font.family: robotoMedium.name
            font.pixelSize: dp_14
        }

        Text {
            id: messageItem
            anchors {
                left: title.left
                right: parent.right
                rightMargin: dp_24
                top: title.bottom
                topMargin: dp_5
            }
            width: Math.ceil(implicitWidth)
            font.family: robotoMedium.name
            font.pixelSize: dp_13
            font.letterSpacing: 0.2 * dp_1
            lineHeightMode: Text.FixedHeight
            lineHeight: dp_16
            wrapMode: Text.WordWrap
            color: "#ffffff"
        }

        ImageButton {
            id: closeBtn
            anchors {
                top: parent.top
                topMargin: dp_3
                right: parent.right
                rightMargin: dp_3
            }
            width: dp_24
            height: dp_24
            radius: dp_3
            backgroundColor: !hovered ? "transparent" : Qt.rgba(0, 0, 0, 0.1)
            image: "qrc:/icon/i-cross.png"
            onClicked: {
                notificationWnd.close();
                notificationWnd.closeClicked()
            }
        }

        NotificationButton {
            id: actionButton
            anchors {
                left: messageItem.left
                top: messageItem.bottom
                topMargin: dp_16
            }
            visible: text.length > 0
            onClicked: {
                notificationWnd.actionClicked()
                notificationWnd.close()
            }
        }
    }
}
