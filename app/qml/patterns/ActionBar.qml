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
import QtQuick.Dialogs 1.2
import "../"

ActionBar {
    id: root

    property bool isEditorVisible: false

    signal addPattern(var pattern)
    signal replacePattern(var pattern, var prev)
    signal cancelled

    function openForNew() {
        editor.reset();
        isEditorVisible = true;
    }

    function openForEdit(pattern) {
        editor.reset();
        editor.original = pattern;
        editor.text = pattern;
        isEditorVisible = true;
    }

    function closeEditor() {
        isEditorVisible = false;
    }

    Item {
        id: addButtonNormal
        anchors.fill: parent
        visible: !isEditorVisible

        Image {
            id: addImg
            anchors {
                left: parent.left
                leftMargin: dp_24
                verticalCenter: parent.verticalCenter
            }
            source: "qrc:/icon/i-add.png"
            smooth: false
            width: dp_16
            height: dp_16
        }

        Text {
            id: addWebsiteTxt
            anchors {
                left: addImg.right
                leftMargin: dp_11
                verticalCenter: parent.verticalCenter
            }
            width: Math.ceil(implicitWidth)
            text: qsTr("Add website")
            color: "#3c83ff"
            font.family: robotoBold.name
            font.weight: Font.Bold
            font.pixelSize: dp_15
            font.letterSpacing: 0.4 * dp_1
            font.capitalization: Font.AllUppercase
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: openForNew()
        }
    }

    FocusScope {
        id: inputFocusScope
        anchors {
            fill: parent
            leftMargin: dp_24
            rightMargin: dp_24
        }

        ActionBarUrlEditor {
            id: editor
            anchors.fill: parent
            visible: isEditorVisible
            focus: true

            onVisibleChanged: if (visible)
                                  inputFocusScope.forceActiveFocus()

            onAccepted: {
                closeEditor();
                if (prev.length === 0) {
                    addPattern(pattern);
                } else {
                    replacePattern(pattern, prev)
                }
            }

            onCancelled: {
                closeEditor();
                root.cancelled();
            }

            Connections {
                target: appWnd
                onActiveChanged: editor.cancelled();
            }
        }
    }
}
