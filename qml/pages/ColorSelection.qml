/****************************************************************************************
**
** Copyright Pekka Marjamäki
**
** The file is made from Sailfish Silica ColorPickerPage & ColorPicker:
**      Copyright (C) 2013 Jolla Ltd.
**      Contact: Joona Petrell <joona.petrell@jollamobile.com>
** by adding option to select the theme colors and transparency.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: colorDialog

    //property alias color: standardColors.color
    property color colour
    property alias colors: standardColors.colors
    property alias title: header.title

    signal colorClicked(color colour)

    allowedOrientations: defaultAllowedOrientations //Orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + ambienceTxt.height + themeColors.height +
                       colorsTxt.height + standardColors.height

        VerticalScrollDecorator {}

        PageHeader {
            id: header
            //% "Choose color"
            title: qsTrId("components-he-choose_color")
        }

        Label {
            id: ambienceTxt
            text: qsTr("ambience")
            anchors.top: header.bottom
            color: Theme.highlightColor
            x: Theme.horizontalPageMargin
        }

        ColorGrid { //ColorPicker {
            id: themeColors
            anchors.top : ambienceTxt.bottom
            colors: ["transparent", Theme.primaryColor, Theme.secondaryColor,
                Theme.highlightDimmerColor, Theme.highlightColor,
                Theme.secondaryHighlightColor, Theme.highlightBackgroundColor
                ]
            columns: (Math.floor(width / Theme.itemSizeHuge) < 4) ? 4 : Math.floor(width / Theme.itemSizeHuge)
            onColorClicked: colorDialog.colorClicked(themeColors.color)
        }

        Label {
            id: colorsTxt
            text: qsTr("other")
            anchors.top: themeColors.bottom
            color: Theme.highlightColor
            x: Theme.horizontalPageMargin
        }

        ColorGrid { //ColorPicker {
            id: standardColors
            anchors.top: colorsTxt.bottom // header.bottom
            columns: (Math.floor(width / Theme.itemSizeHuge) < 4) ? 4 : Math.floor(width / Theme.itemSizeHuge)
            colors: ["black", "white", "brown", "gray", "#e60003",
                "#e6007c", "#e700cc", "#9d00e7", "#7b00e6", "#5d00e5", "#0077e7",
                "#01a9e7", "#00cce7", "#00e696", "#00e600", "#99e600", "#e3e601",
                "#e5bc00", "#e78601"]
            onColorClicked: colorDialog.colorClicked(standardColors.color)

        }

    }
}
