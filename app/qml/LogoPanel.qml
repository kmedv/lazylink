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
import QtGraphicalEffects 1.0
import net.lazylink 1.0

Item {
    id: root

    signal addWebsite

    implicitWidth: dp_300
    implicitHeight: dp_93

    // Top part of MacOS app is a an arrow-like panel without system menu.
    Image {
        id: logoBackgroundMac
        anchors.fill: parent
        source: "qrc:/icon/top.png"
        smooth: false
        visible: appWnd.isMacOS()
    }

    LinearGradient {
        id: logoBackgroundWin
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
        visible: !logoBackgroundMac.visible
    }

    Image {
        id: logoImg
        anchors {
            left: parent.left
            leftMargin: dp_12
            bottom: parent.bottom
            bottomMargin: dp_15
        }
        width: dp_166
        height: dp_40
        source: "qrc:/icon/logo_LL.png"
        smooth: false
    }

    OnOffSwitch {
        anchors {
            right: parent.right
            rightMargin: dp_24
            verticalCenter: logoImg.verticalCenter
        }
        z: 1
        checked: Settings.linkHammerEnabled
        onToggled: Settings.linkHammerEnabled = checked
    }

    MouseArea {
        id: moveArea

        property int startPosX
        property int startPosY

        anchors.fill: parent
        enabled: !appWnd.isMacOS()

        onPressed: {
            startPosX = mouse.x
            startPosY = mouse.y
        }

        onPositionChanged: {
            appWnd.x += mouse.x - startPosX;
            appWnd.y += mouse.y - startPosY;
        }
    }
}
