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
import QtQuick.Controls 2.1
import "components"

Rectangle {
    id: bar
    color: "#f4f5fb"

    signal openSettings()
    signal exitApplication()
    signal donate()

    // DonateButton {
    //     id: donateButton
    //     anchors {
    //         left: parent.left
    //         leftMargin: dp_20
    //         verticalCenter: parent.verticalCenter
    //     }
    //     onClicked: bar.donate()
    // }

    UniButton {
        id: settingsButton
        anchors {
            right: exitButton.left
            rightMargin: dp_16
            verticalCenter: parent.verticalCenter
        }
        contentWidth: dp_24
        contentHeight: dp_24
        image: "qrc:/icon/i-settings.png"
        hoveredImage: "qrc:/icon/i-settings_active.png"
        onClicked: bar.openSettings()
    }

    UniButton {
        id: exitButton
        anchors {
            right: parent.right
            rightMargin: dp_16
            verticalCenter: parent.verticalCenter
        }
        contentWidth: dp_24
        contentHeight: dp_24
        image: "qrc:/icon/i-exit.png"
        hoveredImage: "qrc:/icon/i-exit_active.png"
        onClicked: bar.exitApplication()
    }


}
