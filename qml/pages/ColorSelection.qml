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
    property var clrs1: ["transparent", Theme.primaryColor, Theme.secondaryColor,
        Theme.highlightDimmerColor, Theme.highlightColor,
        Theme.secondaryHighlightColor, Theme.highlightBackgroundColor,
        Theme.darkPrimaryColor, Theme.darkSecondaryColor
        ]
    property var clrs2: ["transparent", Theme.primaryColor, Theme.secondaryColor,
        Theme.highlightDimmerColor, Theme.highlightColor,
        Theme.secondaryHighlightColor, Theme.highlightBackgroundColor,
        Theme.lightPrimaryColor, Theme.lightSecondaryColor
        ]

    signal colorClicked(color colour)

    allowedOrientations: defaultAllowedOrientations //Orientation.All

    /*
    function intToHex(nr) {
        var hex = "", i=0, chrA = 0, strA = "A"
        i = Math.floor(nr/16)
        if (i < 10)
            hex += i
        else {
            chrA = strA.charCodeAt(0) //65
            hex += String.fromCharCode(chrA + i - 10)
        }

        i = nr - i*16
        i = Math.floor(i/16)
        if (i < 10)
            hex += i
        else {
            chrA = strA.charCodeAt(0) //65
            hex += String.fromCharCode(chrA + i - 10)
        }

        return hex
    }
    // */

    function hexColor(r, g, b) {
        var nr = 0, hex = "#"
        nr = parseInt(r)
        if (nr < 16)
            hex += "0"
        hex += nr.toString(16) //intToHex(nr)
        nr = parseInt(g)
        if (nr < 16)
            hex += "0"
        hex += nr.toString(16) //intToHex(nr)
        nr = parseInt(b)
        if (nr < 16)
            hex += "0"
        hex += nr.toString(16) //intToHex(nr)

        return hex
    }

    /*
    function hexToComponents(rgb) {
        var str = "", i = 0, red = "", green = "", blue = "", opa = ""
        str = "#" + rgb
        i = str.length
        blue = str.slice(i-3,i)
        i = i - 2
        green = str.slice(i-3,i)
        i = i - 2
        red = str.slice(i-3,i)
        if (i > 2) {
            i = i - 2
            opa = str.slice(i-3,i)
        }
    } // */

//    /*
    function redComponent(rgb) {
        var val = 0, str = "", i = 0
        str = "#" + rgb
        i = str.length - 4
        str = str.slice(i - 2, i)
        val = parseInt(str, 16)
        console.log("rgb " + str + " red " + val)
        return val
    } // */

    function greenComponent(rgb) {
        var val = 0, str = "", i = 0
        str = "#" + rgb
        i = str.length - 2
        str = str.slice(i - 2, i)
        val = parseInt(str, 16)
        console.log("rgb " + str + " green " + val)
        return val
    }

    function blueComponent(rgb) {
        var val = 0, str = "", i = 0
        str = "#" + rgb
        i = str.length
        str = str.slice(i - 2, i)
        val = parseInt(str, 16)
        console.log("rgb " + str + " blue " + val)
        return val
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: blueSlider.height + blueSlider.y - header.y

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
            colors: (Theme.primaryColor === Theme.darkPrimaryColor) ? clrs2 : clrs1
            columns: (Math.floor(width / Theme.itemSizeHuge) < 4) ? 4 : Math.floor(width / Theme.itemSizeHuge)
            onColorClicked: {
                colorDialog.colorClicked(themeColors.color)
                if (!modifyRgb.checked)
                    pageStack.pop()
                else {
                    redSlider.value = redComponent(themeColors.color)
                    greenSlider.value = greenComponent(themeColors.color)
                    blueSlider.value = blueComponent(themeColors.color)
                }

            }
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
            onColorClicked: {
                colorDialog.colorClicked(standardColors.color)
                if (!modifyRgb.checked)
                    pageStack.pop()
                else {
                    redSlider.value = redComponent(standardColors.color)
                    greenSlider.value = greenComponent(standardColors.color)
                    blueSlider.value = blueComponent(standardColors.color)
                }
            }

        }

        TextSwitch {
            id: modifyRgb
            checked: false
            text: qsTr("modify rgb-color")
            anchors.top: standardColors.bottom
        }

        Rectangle {
            id: sliderColor
            height: Theme.paddingLarge*2
            width: Theme.buttonWidthMedium
            anchors.top: modifyRgb.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.darkSecondaryColor
        }

        Slider {
            id: redSlider
            width: parent.width
            label: qsTr("red")
            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            anchors.top: sliderColor.bottom
            onValueChanged: {
                sliderColor.color = hexColor(redSlider.value, greenSlider.value, blueSlider.value)
            }
            enabled: modifyRgb.checked
        }

        Slider {
            id: greenSlider
            width: parent.width
            label: qsTr("green")
            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            anchors.top: redSlider.bottom
            onValueChanged: {
                //console.log("green " + value)
                sliderColor.color = hexColor(redSlider.value, greenSlider.value, blueSlider.value)
            }
            enabled: modifyRgb.checked
        }

        Slider {
            id: blueSlider
            width: parent.width
            label: qsTr("blue")
            minimumValue: 0
            maximumValue: 255
            stepSize: 1
            anchors.top: greenSlider.bottom
            onValueChanged: {
                //console.log("slider3 " + hexColor(redSlider.value, greenSlider.value, blueSlider.value))
                sliderColor.color = hexColor(redSlider.value, greenSlider.value, blueSlider.value)
            }
            enabled: modifyRgb.checked
        }

    }

    Component.onDestruction: {
        if (modifyRgb.checked === true)
            colorClicked(hexColor(redSlider.value, greenSlider.value, blueSlider.value))
    }
}
