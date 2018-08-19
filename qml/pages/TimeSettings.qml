/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Pekka Marjamäki <hsjpekka@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Dialog {
//Page {
    id: page
    allowedOrientations: Orientation.All
    //anchors.fill: parent

    property string ambientPath: "/usr/share/sounds/jolla-ambient/stereo/"
    property int bonusPeriods1: 0
    property int bonusPeriods2: 0
    property string bonusPeriodTxt: ""
    property int bonusT1: 0
    property int bonusT2: 0
    property int bonusType: 0 // 0 - no bonus, 1 - secs per move (Fischer), 2 - delay before counting (Bronstein), 3 - n x XX sec ylityksiä (Byoyomi), 4 - n x siirtoja XX sekunnissa (Canadian Byo.)
    property bool bonusVisible: false
    property bool equals: true
    property int hoursPlayer1: 0
    property int hoursPlayer2: 0
    property int minsPlayer1: 0
    property int minsPlayer2: 0
    property string ringtonesPath: "/usr/share/sounds/jolla-ringtones/stereo/"
    //property int screenOrientation: Orientation.All
    property int secsPlayer1: 0
    property int secsPlayer2: 0
    property string txtPlaceHolder: ""
    property int sliderWidth: page.width*0.8
    property string soundFile: ambientPath + "positive_confirmation.wav" // ringtonesPath + "jolla-calendar-alarm.ogg"
    property bool useSounds: false

    SilicaFlickable {
        id: flickable
        anchors.fill: page
        height: page.height
        contentHeight: column.height

        Column {
            id: column
            spacing: 0

            DialogHeader {
                title: "" //qsTr("Player 1")
                width: page.width
                //visible: false
            }

            /*
            ComboBox {
                id: viewOrientation
                label: qsTr("orientation")
                currentIndex: 0
                menu: ContextMenu {
                    MenuItem { text: qsTr("dynamic") }
                    MenuItem { text: qsTr("portrait") }
                    MenuItem { text: qsTr("landscape") }
                }
                onCurrentIndexChanged: {
                    switch (currentIndex) {
                    case 0:
                        screenOrientation = Orientation.All
                        break
                    case 1:
                        screenOrientation = Orientation.PortraitMask
                        break
                    case 2:
                        screenOrientation = Orientation.LandscapeMask
                        break
                    }
                }

            }
            // */

            ComboBox {
                id: cbBonus
                width: page.width
                label: qsTr("time system")

                currentIndex: bonusType

                onCurrentIndexChanged: {
                    bonusType = currentIndex
                    bonusVisible = bonusType > 0.5 ? true : false
                    if (bonusType == 1) {
                        if (bonusT1 == 0)
                            bonusT1 = 5
                        if (bonusT2 == 0)
                            bonusT2 = 5
                        txtPlaceHolder = qsTr("increment per move") + " [s]"
                    } else if (bonusType == 2) {
                        if (bonusT1 == 0)
                            bonusT1 = 5
                        if (bonusT2 == 0)
                            bonusT2 = 5
                        txtPlaceHolder = qsTr("delay per move") + " [s]"
                    } else {
                        if (bonusType == 3) {
                            if (bonusT1 < 1)
                                bonusT1 = 15
                            if (bonusPeriods1 < 1)
                                bonusPeriods1 = 3
                            if (bonusT2 < 1)
                                bonusT2 = 15
                            if (bonusPeriods2 < 1)
                                bonusPeriods2 = 3
                        } else {
                            if (bonusT1 < 1)
                                bonusT1 = 5*60
                            if (bonusPeriods1 < 1)
                                bonusPeriods1 = 20
                            if (bonusT2 < 1)
                                bonusT2 = 5*60
                            if (bonusPeriods2 < 1)
                                bonusPeriods2 = 20
                        }

                        txtPlaceHolder = qsTr("time period") + " [s]"
                    }

                }

                menu: ContextMenu {
                    MenuItem { text: qsTr("total time") }
                    MenuItem { text: qsTr("increment") +  " (Fisher)" }
                    MenuItem { text: qsTr("delay") + " (Bronstein)" }
                    MenuItem { text: qsTr("X s N times") +  "(Byo-yomi)" }
                    MenuItem { text: qsTr("N moves in X secs (Canadian %1)").arg("Byo-yomi") }
                }
            }

            Slider {
                id: hours1
                width: sliderWidth
                value: hoursPlayer1
                minimumValue: 0
                maximumValue: 24
                stepSize: 1
                valueText: value.toFixed(0) + " h"
            }

            Slider {
                id: mins1
                width: sliderWidth
                value: minsPlayer1
                minimumValue: 0
                maximumValue: 60
                stepSize: 1
                valueText: value.toFixed(0) + " min"
            }

            Slider {
                id: secs1
                width: sliderWidth
                value: secsPlayer1
                minimumValue: 0
                maximumValue: 60
                stepSize: 1
                valueText: value.toFixed(0) + " s"
            }

            TextField {
                id: txtBonus1
                text: bonusT1 == 0 ? "" : bonusT1
                width: sliderWidth - 2*Theme.paddingLarge
                placeholderText: txtPlaceHolder
                label: txtPlaceHolder
                validator: IntValidator{}
                inputMethodHints: Qt.ImhDigitsOnly
                x: Theme.paddingLarge
                visible: bonusVisible
                onTextChanged: {
                    bonusT1 = text*1.0
                }
            }

            Slider {
                id: txtBonusPeriods1
                width: sliderWidth
                value: bonusPeriods1
                minimumValue: 1
                maximumValue: 60
                stepSize: 1
                visible: bonusType > 2.5
                valueText: bonusType < 3.5 ? ( value.toFixed(0) + " " + qsTr("time periods")) : qsTr("%1 moves in %2 s").arg(value.toFixed(0)).arg(txtBonus1.text)
            }

            TextSwitch {
                id: equalTimes
                checked: equals
                text: qsTr("time") + " 1" +  (checked ? " = " : " ≠ ") + qsTr("time") + " 2"
            }

            Slider {
                id: hours2
                width: sliderWidth
                value: hoursPlayer2
                minimumValue: 0
                maximumValue: 24
                stepSize: 1
                visible: !equalTimes.checked
                valueText: value.toFixed(0) + " h"
            }

            Slider {
                id: mins2
                width: sliderWidth
                value: minsPlayer2
                minimumValue: 0
                maximumValue: 60
                stepSize: 1
                visible: !equalTimes.checked
                valueText: value.toFixed(0) + " min"
            }

            Slider {
                id: secs2
                width: sliderWidth
                value: secsPlayer2
                minimumValue: 0
                maximumValue: 60
                stepSize: 1
                visible: !equalTimes.checked
                valueText: value.toFixed(0) + " s"
            }

            TextField {
                id: txtBonus2
                text: bonusT2 == 0 ? "" : bonusT2
                width: sliderWidth - 2*Theme.paddingLarge
                placeholderText: txtPlaceHolder
                label: txtPlaceHolder
                validator: IntValidator{}
                inputMethodHints: Qt.ImhDigitsOnly
                visible: equalTimes.checked ? false : bonusVisible
                x: Theme.paddingLarge
            }

            Slider {
                id: txtBonusPeriods2
                width: sliderWidth
                value: bonusPeriods2
                minimumValue: 1
                maximumValue: 60
                stepSize: 1
                visible: equalTimes.checked ? false : (bonusType > 2.5 ? true : false)
                valueText: bonusType < 3.5 ? ( value.toFixed(0) + " " + qsTr("time periods")) : qsTr("%1 moves in %2 s").arg(value.toFixed(0)).arg(txtBonus2.text)
            }

            TextSwitch {
                id: soundSwitch
                checked: useSounds
                text: useSounds? qsTr("clangs when time is over") : qsTr("remains silent")
                onClicked: useSounds = !useSounds
            }

            Row {
                id: fileRow
                x: Theme.paddingLarge
                spacing: Theme.paddingSmall

                TextField {
                    id: txtSound
                    text: soundFile
                    width: page.width - fileRow.x - Theme.paddingLarge - changeSound.width - fileRow.spacing
                    visible: useSounds
                }

                IconButton {
                    id: changeSound
                    icon.source: "image://theme/icon-m-folder"
                    visible: useSounds
                    onClicked: {
                        pageStack.push(filePicker)
                    }
                }


            }

            Label {
                text: qsTr("version %1").arg(1.2)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                x: 0.5*(page.width - width)
            }
        }

        VerticalScrollDecorator {}

    }

    Component {
        id: filePicker
        FilePickerPage {
            nameFilters: [ '*.wav', '*.ogg', '*.oga', '*.mp3']
            onSelectedContentPropertiesChanged: {
                soundFile = selectedContentProperties.filePath
            }
        }
    }

    Component.onCompleted: {
        equals = ((hoursPlayer1*60 + minsPlayer1)*60 + secsPlayer1 === (hoursPlayer2*60 + minsPlayer2)*60 + secsPlayer2) && (bonusT1 === bonusT2)
        equalTimes.checked = equals

        /*
        if (screenOrientation === Orientation.All)
            viewOrientation.currentIndex = 0
        else if (screenOrientation === Orientation.PortraitMask)
            viewOrientation.currentIndex = 1
        else if (screenOrientation === Orientation.LandscapeMask)
            viewOrientation.currentIndex = 2
        // */
    }

    onAccepted: {
        hoursPlayer1 = hours1.value
        minsPlayer1 = mins1.value
        secsPlayer1 = secs1.value
        bonusT1 = txtBonus1.text*1.0
        bonusPeriods1 = txtBonusPeriods1.value

        if (equalTimes.checked) {
            hoursPlayer2 = hoursPlayer1
            minsPlayer2 = minsPlayer1
            secsPlayer2 = secsPlayer1
            bonusT2 = bonusT1
            bonusPeriods2 = bonusPeriods1
        } else {
            hoursPlayer2 = hours2.value
            minsPlayer2 = mins2.value
            secsPlayer2 = secs2.value
            bonusT2 = txtBonus2.text*1.0
            bonusPeriods2 = txtBonusPeriods2.value
        }

    }
}
