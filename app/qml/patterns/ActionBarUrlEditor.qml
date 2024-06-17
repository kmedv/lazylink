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

Item {
    id: root

    property alias text: input.text
    property string original: ""

    signal accepted(var pattern, var prev)
    signal cancelled

    function reset() {
        text = "";
        original = "";
    }

    CancelButton {
        id: cancelButton
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        onClicked: {
            root.reset();
            root.cancelled();
        }
    }

    TextField {
        id: input

        property bool isUrl: false;

        function checkIsUrl(s) {
            if (s === "")
                return false;
            var regexp = /^(?:\w+\:\/\/)?(?:[\w\-\*]+\.)+[\w\*]+[\/\?]?/
            var res = regexp.test(s);
            return res;
        }

        anchors {
            left: cancelButton.right
            leftMargin: dp_5
            right: saveButton.left
            rightMargin: dp_22
            verticalCenter: parent.verticalCenter
        }

        focus: true

        placeholderText: qsTr("Address")
        background: Item {}
        activeFocusOnPress: true
        echoMode: TextInput.Normal

        font.family: robotoRegular.name
        font.pixelSize: dp_15
        color: "#575765"
        opacity: (length == 0) ? 0.2 : 1.0
        maximumLength: 2048

        onTextChanged: this.isUrl = checkIsUrl(text)
        onVisibleChanged: if (visible)
                              input.forceActiveFocus();
        onAccepted: if (this.isUrl)
                        root.accepted(input.text, root.original)
    }

    SaveButton {
        id: saveButton
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        text: original.length === 0 ? qsTr("Add") : qsTr("Save")
        enabled: input.isUrl
        onClicked: if (input.isUrl)
                       root.accepted(input.text, root.original)
    }
}
