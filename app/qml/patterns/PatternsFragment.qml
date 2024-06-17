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
    ActionBar {
        id: actionBar
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: dp_50
        z: 1

        onAddPattern: {
            Settings.addPattern(pattern);
//            openForNew();   // Open for the next pattern.
        }

        onReplacePattern: Settings.replacePattern(prev, pattern)
    }

    PatternsList {
        id: patternsList
        anchors {
            left: parent.left
            right: parent.right
            top: actionBar.bottom
            topMargin: dp_10
            bottom: parent.bottom
        }
        patterns: Settings.patternStrings
        enabled: !actionBar.isEditorVisible && Settings.linkHammerEnabled
        onEditPattern: actionBar.openForEdit(pattern)
        onDeletePattern: Settings.removePattern(pattern)
    }
}
