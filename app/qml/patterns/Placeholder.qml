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

Item {
    Image {
        id: logoImg
        anchors {
            top: parent.top
            topMargin: dp_65
            horizontalCenter: parent.horizontalCenter
        }
        width: dp_46
        height: dp_46
        source: "qrc:/icon/placeholder-link.png"
        smooth: false
    }

    Image {
        id: arrowImg
        anchors {
            top: parent.top
            topMargin: dp_9
            right: logoImg.left
            rightMargin: dp_11
        }
        width: dp_40
        height: dp_70
        source: "qrc:/icon/img-arrow.png"
        smooth: false
    }
    
    Text {
        anchors {
            top: logoImg.bottom
            topMargin: dp_16
            horizontalCenter: logoImg.horizontalCenter
        }
        width: dp_218
        text: qsTr("Please add the website, which links you want to shorten.")
        wrapMode: Text.WordWrap
        lineHeightMode: Text.FixedHeight
        lineHeight: dp_20
        horizontalAlignment: Text.AlignHCenter
        color: Qt.rgba(56/255., 76/255., 111/255., 0.6)
        font.family: robotoMedium.name
        font.pixelSize: dp_13
    }
}
