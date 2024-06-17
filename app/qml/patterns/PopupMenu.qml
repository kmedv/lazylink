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
import "../"

ShadowedWindow {
    id: menuWnd

    property int contentVPadding: dp_10

    signal editLink
    signal openSite
    signal deleteItem

    radius: dp_4
    backgroundColor: "#3c83ff"
    modality: Qt.NonModal       // We should set window as non modal to use popup mouse interceptor.

    shadowEnabled: appWnd.shadowEnabled
    shadowVerticalOffset: dp_10
    shadowHorizontalOffset: dp_5
    shadowBlurRadius: dp_8
    shadowColor: Qt.rgba(60/255.0, 131/255.0, 1, 0.4)

    flags: ShadowedWindow.recommendedFlags | Qt.Popup
           | Qt.FramelessWindowHint
           | Qt.WindowStaysOnTopHint
    content: wndContent

    onVisibleChanged: {
        if (typeof(appWnd) == "object")
            appWnd.popupWnd = visible ? this : undefined;
    }

    Item {
        id: wndContent

        function editLink() {
            menuWnd.close();
            menuWnd.editLink();
        }

        function openSite() {
            menuWnd.close();
            menuWnd.openSite();
        }

        function deleteItem() {
            menuWnd.close();
            menuWnd.deleteItem();
        }

        implicitWidth: items.width
        implicitHeight: Math.ceil(items.height) + contentVPadding * 2

        Column {
            id: items
            anchors.centerIn: parent
            width: Math.ceil(Math.max(editMenuItem.implicitWidth, deleteMenuItem.implicitWidth))

            PopupMenuItem {
                id: editMenuItem
                width: parent.width
                label: qsTr("Edit link")
                icon: "qrc:/icon/i-edit.png"
                onClicked: wndContent.editLink()
            }

            PopupMenuItem {
                id: deleteMenuItem
                width: parent.width
                label: qsTr("Delete")
                icon: "qrc:/icon/i-delete.png"
                onClicked: wndContent.deleteItem()
            }
        }
    }

    Connections {
        target: appWnd
        onClosePopup: menuWnd.close()
    }
}
