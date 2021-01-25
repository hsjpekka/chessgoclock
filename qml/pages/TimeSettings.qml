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
import "../utils/database.js" as DataB
import "../utils/scripts.js" as Scripts

Dialog {
    id: page
    allowedOrientations: defaultAllowedOrientations //Orientation.All // screenOrientation

    property string ambientPath: "/usr/share/sounds/jolla-ambient/stereo/"
    property int bonusPeriods1: 0
    property int bonusPeriods2: 0
    property string bonusPeriodTxt: ""
    property int bonusT1: 0
    property int bonusT2: 0
    property int timeSystem: 0 // 0 - no bonus, 1 - secs per move (Fischer), 2 - delay before counting (Bronstein), 3 - n x XX sec ylityksiä (Byoyomi), 4 - n x siirtoja XX sekunnissa (Canadian Byo.)
    property bool bonusVisible: false
    property alias activeTextColor: activeClockColor.color
    property alias activeBgColor: activeClockBox.color
    property bool equals: true
    property string gameSetupName: "" //name of the time settings
    //property int hoursPlayer1: 0
    property alias hoursPlayer1: hours1.value
    //property int hoursPlayer2: 0
    property alias hoursPlayer2: hours2.value
    property string layoutName: "" //name of the board layout
    //property int minsPlayer1: 0
    //property int minsPlayer2: 0
    property alias minsPlayer1: mins1.value
    property alias minsPlayer2: mins2.value
    property alias passiveTextColor: passiveClockColor.color
    property alias passiveBgColor: passiveClockBox.color
    property string ringtonesPath: "/usr/share/sounds/jolla-ringtones/stereo/"
    //property int screenOrientation: Orientation.All
    //property int secsPlayer1: 0
    //property int secsPlayer2: 0
    property alias secsPlayer1: secs1.value
    property alias secsPlayer2: secs2.value
    property string txtPlaceHolder: ""
    property int sliderWidth: page.width*0.95
    property string soundFile: ambientPath + "positive_confirmation.wav" // ringtonesPath + "jolla-calendar-alarm.ogg"
    property color transparent: "transparent"
    property bool useSounds: false

    function openDeletePage() {
        var gNr=-1, lNr=-1, page
        if (cbTimeSetups.currentItem == null) {
            //if (comboGameList.count > 0)
            //    gNr=1
            //else
            //    gNr = 0
        } else {
            gNr = cbTimeSetups.currentItem.number
        }

        if (cbStoredLayouts.currentItem == null ) {
            //if (comboLayoutList.count > 0)
            //    lNr=1
            //else
            //    lNr = 0
        } else {
            lNr = cbStoredLayouts.currentItem.number
        }

        page = pageStack.push(Qt.resolvedUrl("deleteSettings.qml"), {
                           "gameNbr": gNr,
                           "layoutNbr": lNr
                       })
        page.closing.connect(function() {
            refreshComboGame()
            refreshComboLayout()
        })
    }

    function readBoardSettings(setNr) {
        var dum
        if( setNr < 0) {
            console.log("board setup " + setNr + " doesn't exist")
        } else {
            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyActiveBg)
            if (dum === -1) {
                activeBgColor = transparent
                console.log("board setup " + setNr + " activeBgColor doesn't exist")
            } else {
                console.log("activeBgColor")
                activeBgColor = Scripts.strToAmbienceColor(dum)
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyActiveFont)
            if (dum === -1) {
                activeTextColor = Theme.highlightColor
                console.log("board setup " + setNr + " activeTextColor doesn't exist")
            } else {
                console.log("activeTextColor")
                activeTextColor = Scripts.strToAmbienceColor(dum)
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyPassiveBg)
            if (dum === -1) {
                passiveBgColor = transparent
                console.log("board setup " + setNr + " passiveBgColor doesn't exist")
            } else {
                console.log("passiveBgColor")
                passiveBgColor = Scripts.strToAmbienceColor(dum)
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyPassiveFont)
            if (dum === -1) {
                passiveTextColor = Theme.secondaryHighlightColor
                console.log("board setup " + setNr + " passiveTextColor doesn't exist")
            } else {
                console.log("passiveTextColor")
                passiveTextColor = Scripts.strToAmbienceColor(dum)
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keySound)
            if (dum === -1) {
                console.log("board setup " + setNr + " soundFile doesn't exist")
            } else {
                soundFile = dum
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyUseSound)
            if (dum === -1) {
                console.log("board setup " + setNr + " useSounds doesn't exist")
            } else {
                useSounds = dum
            }
        }

        //console.log("alue " + activeBgColor + ", teksti " + activeTextColor
        //            + ", ääni " + useSounds + " " + soundFile)

        return
    }

    function readClockSettings(setNr) {
        var time1, time2, dum

        if( setNr < 0) {
            console.log("game setup " + setNr + " doesn't exist")
        } else {
            time1 = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl1Time)
            if (time1 < 0) {
                time1 = 0
                console.log("game setup " + setNr + " time1 doesn't exist")
            }
            //console.log(" " + time1)
            hoursPlayer1 = Math.floor(time1/60/60)
            minsPlayer1 = Math.floor((time1 - hoursPlayer1*60*60)/60)
            secsPlayer1 = time1 - hoursPlayer1*60*60 - minsPlayer1*60

            time2 = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl2Time)
            if (time2 < 0) {
                time2 = 0
                console.log("game setup " + setNr + " time2 doesn't exist")
            }
            hoursPlayer2 = Math.floor(time2/60/60)
            minsPlayer2 = Math.floor((time2 - hoursPlayer2*60*60)/60)
            secsPlayer2 = time2 - hoursPlayer2*60*60 - minsPlayer2*60

            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyGame)
            timeSystem = (dum < 0) ? 0 : dum
            cbSystem.currentIndex = timeSystem
            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl1Extra)
            bonusT1 = (dum < 0) ? 0 : dum
            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl2Extra)
            bonusT2 = (dum < 0) ? 0 : dum
            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl1Nbr)
            bonusPeriods1 = (dum < 0) ? 0 : dum
            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl2Nbr)
            bonusPeriods2 = (dum < 0) ? 0 : dum

            equals = (time1 === time2) && (bonusT1 === bonusT2) && (bonusPeriods1 === bonusPeriods2)
            equalTimes.checked = equals

            //console.log("pelityyppi " + timeSystem + ", t1 " + bonusT1 + ", n1" + bonusPeriods1)
        }

        return
    }

    function readStoredGameNames() {
        var nameList = [], i = 1 // the first is not read on purpose
        nameList = DataB.readSetNames(DataB.gameDb) // [{"nbr": 0, "name": ""}]
        //console.log("stored game names " + nameList.length)
        //comboGameList.append({"menuText": "- -" })

        while (i < nameList.length) {
            //console.log(" game " + nameList[i].nbr + " " + nameList[i].name)
            comboGameList.append({"menuText": nameList[i].name, "nr": nameList[i].nbr })
            i++
        }
        //for(i=0; i<4; i++) {
        //    comboLayoutList.append({"menuText": "adds " + i})
        //}

        return i
    }

    function readStoredLayoutNames() {
        //for(i=0; i<4; i++) {
        //    comboLayoutList.append({"menuText": "adds " + i})
        //}
        var nameList = [], i = 1 // the first is not read on purpose
        nameList = DataB.readSetNames(DataB.layoutDb) // [{"nbr": 0, "name": ""}]
        //console.log("stored layout names " + nameList.length)
        //comboLayoutList.append({"menuText": "- -" })

        while (i < nameList.length) {
            //console.log(" layout " + nameList[i].nbr + " " + nameList[i].name)
            comboLayoutList.append({"menuText": nameList[i].name, "nr": nameList[i].nbr})
            i++
        }

        return
    }

    function refreshComboGame() {
        var i = 0
        comboGameList.clear()        
        readStoredGameNames()
        cbTimeSetups.currentIndex = -1
        while(i < comboGameList.count) {
            if (comboGameList.get(i).menuText === gameSetupName)
                cbTimeSetups.currentIndex = i
            i++
        }

        return
    }

    function refreshComboLayout() {
        var i = 0
        comboLayoutList.clear()
        readStoredLayoutNames()
        cbStoredLayouts.currentIndex = -1
        while (i < comboLayoutList.count) {
            if (comboLayoutList.get(i).menuText === layoutName)
                cbStoredLayouts.currentIndex = i

            i++
        }

        return
    }

    function saveName() {
        var dialog = pageStack.push(Qt.resolvedUrl("saveSettings.qml"), {
                                        "activeTextColor": activeTextColor,
                                        "activeBgColor": activeBgColor,
                                        "passiveTextColor": passiveTextColor,
                                        "passiveBgColor": passiveBgColor,
                                        "timeSystem": timeSystem,
                                        "bonusT1": bonusT1,
                                        "bonusT2": (equalTimes.checked ? bonusT1 : bonusT2),
                                        "bonusPeriods1": bonusPeriods1,
                                        "bonusPeriods2": (equalTimes.checked ? bonusPeriods1 : bonusPeriods2),
                                        "soundFile": soundFile,
                                        "useSounds": useSounds,
                                        "hours1": hoursPlayer1,
                                        "mins1": minsPlayer1,
                                        "secs1": secsPlayer1,
                                        "hours2": (equalTimes.checked ? hoursPlayer1 : hoursPlayer2),
                                        "mins2": (equalTimes.checked ? minsPlayer1 : minsPlayer2),
                                        "secs2": (equalTimes.checked ? secsPlayer1 : secsPlayer2),
                                        "gameName": gameSetupName,
                                        "layoutName": layoutName
                                    })
        dialog.accepted.connect( function() {
            if (!dialog.modifyName) {
                //console.log("saving new")
                gameSetupName = dialog.gameName
                layoutName = dialog.layoutName
                storeSettings()
            }
            refreshComboGame()
            refreshComboLayout()
            var i = comboGameList.count - 1
            while (i > -1) {
                if (comboGameList.get(i).name === gameSetupName) {
                    cbTimeSetups.currentIndex = i
                    i = -1
                }
                i--
            }

            var i = comboLayoutList.count - 1
            while (i > -1) {
                if (comboLayoutList.get(i).name === layoutName) {
                    cbStoredLayouts.currentIndex = i
                    i = -1
                }
                i--
            }
        })
    }

    // /*
    function storeSettings() {
        var time1, time2        
        var setNr
        if (gameSetupName != "") {
            time1 = hoursPlayer1*60*60 + minsPlayer1*60 + secsPlayer1
            if (equalTimes.checked) {
                DataB.storeGameSettings(gameSetupName, timeSystem, time1, bonusT1, bonusPeriods1,
                                time1, bonusT1, bonusPeriods1)
            } else {
                DataB.storeGameSettings(gameSetupName, timeSystem, time1, bonusT1, bonusPeriods1,
                                time2, bonusT2, bonusPeriods2)
            }
            //setNr = DataB.whichSet(DataB.gameDb, gameSetupName)
            //if (setNr < 0)
            //    DataB.newGameSet(-setNr, gameSetupName, timeSystem, time1, bonusT1, bonusPeriods1,
            //                     time2, bonusT2, bonusPeriods2)
            //else
            //    DataB.updateGameSet(setNr, gameSetupName, timeSystem, time1, bonusT1, bonusPeriods1,
            //                    time2, bonusT2, bonusPeriods2)
        }

        if (layoutName != "") {
            //setNr = DataB.whichSet(DataB.layoutDb, layoutName)
            //if (setNr < 0)
            //    DataB.newLayoutSet(-setNr, layoutName, activeTextColor, activeBgColor,
            //                       passiveTextColor, passiveBgColor, soundFile, useSounds)
            //else
            //    DataB.updateLayoutSet(setNr, layoutName, activeTextColor, activeBgColor,
            //                      passiveTextColor, passiveBgColor, soundFile, useSounds)
            DataB.storeLayoutSettings(layoutName,
                                      Scripts.colorToAmbienceStr(activeClockColor.color),
                                      Scripts.colorToAmbienceStr(activeClockBox.color),
                                      Scripts.colorToAmbienceStr(passiveClockColor.color),
                                      Scripts.colorToAmbienceStr(passiveClockBox.color),
                                      soundFile, useSounds)
        }

        return
    }
    // */

    SilicaFlickable {
        id: flickable
        anchors.fill: page
        height: page.height
        contentHeight: column.height

        PullDownMenu {
            MenuItem {
                text: qsTr("info")
                onClicked:
                    pageStack.push(Qt.resolvedUrl("info.qml"))
            }

            MenuItem {
                text: qsTr("delete sets")
                onClicked: {
                    openDeletePage()
                }
            }

            MenuItem {
                text: qsTr("save")
                onClicked:
                    saveName()
            }

        }

        Column {
            id: column
            width: page.width
            spacing: 0

            DialogHeader {
                title: qsTr("Clock settings") //qsTr("Player 1")
                width: page.width
                //visible: false
            }

            ListModel {
                id: comboGameList
                ListElement {
                    nr: 0
                    menuText: ""
                }
            }

            ComboBox {
                id: cbTimeSetups
                width: page.width
                label: (comboGameList.count > 0) ? qsTr("stored games") : qsTr("no stored games")
                menu: ContextMenu {
                    id: timeSetupList
                    Repeater {
                        model: comboGameList
                        MenuItem {
                            text: menuText
                            property int number: nr
                        }
                    }
                }

                onCurrentIndexChanged: {
                    var setNbr
                    if (currentIndex >= 0) {
                        //setNbr = DataB.whichSet(DataB.gameDb, currentItem.text)
                        setNbr = currentItem.number
                        gameSetupName = currentItem.text
                        //console.log(" cbTimeSetups " + setNbr + " " + currentItem.text)
                        readClockSettings(setNbr)
                    }

                }
            }

            ListModel {
                id: comboLayoutList
                ListElement {
                    nr: 0
                    menuText: ""
                }
            }

            ComboBox {
                id: cbStoredLayouts
                width: page.width
                label: (comboLayoutList.count > 0)?  qsTr("stored layouts") : qsTr("no stored layouts")

                menu: ContextMenu {
                    Repeater {
                        model: comboLayoutList
                        MenuItem {
                            text: menuText
                            property int number: nr
                        }
                    }
                }

                onCurrentIndexChanged: {
                    var setNbr
                    if (currentIndex >= 0) {
                        //setNbr = DataB.whichSet(DataB.layoutDb, currentItem.text)
                        setNbr = currentItem.number
                        layoutName = currentItem.text
                        readBoardSettings(setNbr)
                        //console.log(" cbStoredLayouts " + setNbr + " " + currentItem.text)
                        //console.log("" + currentItem.text)
                    }
                }
            }

            ComboBox {
                id: cbSystem
                width: page.width
                label: qsTr("time system")

                currentIndex: timeSystem

                onCurrentIndexChanged: {
                    timeSystem = currentIndex
                    bonusVisible = timeSystem > 0.5 ? true : false
                    if (timeSystem == 1) {
                        if (bonusT1 == 0)
                            bonusT1 = 5
                        if (bonusT2 == 0)
                            bonusT2 = 5
                        txtPlaceHolder = Scripts.timeSystemExtras(1, 0) + " [s]"
                    } else if (timeSystem == 2) {
                        if (bonusT1 == 0)
                            bonusT1 = 5
                        if (bonusT2 == 0)
                            bonusT2 = 5
                        txtPlaceHolder = Scripts.timeSystemExtras(2) + " [s]"
                    } else {
                        if (timeSystem == 3) {
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
                    MenuItem { text: Scripts.timeSystemTxt(0) }
                    MenuItem { text: Scripts.timeSystemTxt(1) }
                    MenuItem { text: Scripts.timeSystemTxt(2) }
                    MenuItem { text: Scripts.timeSystemTxt(3) }
                    MenuItem { text: Scripts.timeSystemTxt(4) }
                }
            }

            Label {
                text: qsTr("player %1").arg("1")
                color: Theme.highlightColor
                x: Theme.horizontalPageMargin
                visible: !equalTimes.checked
            }

            Slider {
                id: hours1
                width: parent.width //sliderWidth
                //value: hoursPlayer1
                minimumValue: 0
                maximumValue: 24
                stepSize: 1
                valueText: value.toFixed(0) + " h"
            }

            Slider {
                id: mins1
                width: parent.width //sliderWidth
                //value: minsPlayer1
                minimumValue: 0
                maximumValue: 60
                stepSize: 1
                valueText: value.toFixed(0) + " min"
            }

            Slider {
                id: secs1
                width: parent.width
                //value: secsPlayer1
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
                EnterKey.onClicked: {
                    focus = false
                }
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
                visible: timeSystem > 2.5
                valueText: timeSystem < 3.5 ? (qsTr("%1 time periods").arg(value.toFixed(0))) : qsTr("%1 moves in a period").arg(value.toFixed(0))
            }

            TextSwitch {
                id: equalTimes
                checked: equals
                text: qsTr("time") + " 1" +  (checked ? " = " : " ≠ ") + qsTr("time") + " 2"
            }

            Label {
                text: qsTr("player %1").arg("2")
                color: Theme.highlightColor
                x: Theme.horizontalPageMargin
                visible: !equalTimes.checked
            }

            Slider {
                id: hours2
                width: sliderWidth
                //value: hoursPlayer2
                minimumValue: 0
                maximumValue: 24
                stepSize: 1
                visible: !equalTimes.checked
                valueText: value.toFixed(0) + " h"
            }

            Slider {
                id: mins2
                width: sliderWidth
                //value: minsPlayer2
                minimumValue: 0
                maximumValue: 60
                stepSize: 1
                visible: !equalTimes.checked
                valueText: value.toFixed(0) + " min"
            }

            Slider {
                id: secs2
                width: sliderWidth
                //value: secsPlayer2
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
                visible: equalTimes.checked ? false : (timeSystem > 2.5 ? true : false)
                valueText: timeSystem < 3.5 ? ( value.toFixed(0) + " " + qsTr("time periods")) : qsTr("%1 moves in %2 s").arg(value.toFixed(0)).arg(txtBonus2.text)
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

            // active clock
            Item {
                id: activeClockRow
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: activeClockText.height + activeClockBg.height
                //property int spacing: (width - activeClockText.width - activeClockBox.width)

                Button {
                    id: activeClockText
                    text: qsTr("in turn clock color")
                    //color: (activeClockColor.color !== "transparent") ? activeClockColor.color : Theme.highlightColor
                    onClicked: {
                        //var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                        var dialog = pageStack.push(Qt.resolvedUrl("ColorSelection.qml"), {
                                                        "title": text
                                                    } )
                        dialog.colorClicked.connect(function(color) {
                            activeClockColor.color = color
                            //console.log("it " + color + " - " + Scripts.colorToAmbienceStr(activeTextColor))
                            //pageStack.pop()
                        })
                    }
                }

                Button {
                    id: activeClockBg
                    text: qsTr("in turn background")
                    //width: activeClockText.width
                    anchors.top: activeClockText.bottom
                    //color: (activeClockBox.color !== "transparent") ? activeClockBox.color : Theme.highlightColor
                    onClicked: {
                        //var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                        var dialog = pageStack.push(Qt.resolvedUrl("ColorSelection.qml"), {
                                                        "title": text
                                                    } )
                        dialog.colorClicked.connect(function(color) {
                            activeClockBox.color = color
                            //console.log("itbg " + Scripts.colorToAmbienceStr(activeBgColor))
                            //pageStack.pop()
                        })
                    }
                }

                Rectangle {
                    id: activeClockBox
                    height: activeClockText.height + activeClockBg.height
                    width: activeClockColor.width + 2*Theme.paddingLarge
                    anchors.right: parent.right
                    border.width: 1
                    border.color: (color === transparent) ? Theme.highlightColor : color
                    radius: Theme.paddingMedium
                }

                Label {
                    id: activeClockColor
                    text: "20:14"
                    anchors.horizontalCenter: activeClockBox.horizontalCenter
                    anchors.verticalCenter: activeClockBox.verticalCenter
                }
            }

            // passive clock
            Item {
                id: passiveClockRow
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: passiveClockText.height + passiveClockBg.height
                //property int spacing: (width - passiveClockText.width - passiveClockBox.width)

                Button {
                    id: passiveClockText
                    text: qsTr("out of turn clock color")
                    //color: (passiveClockColor.color !== "transparent") ? passiveClockColor.color : Theme.highlightColor
                    onClicked: {
                        //var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                        var dialog = pageStack.push(Qt.resolvedUrl("ColorSelection.qml"), {
                                                        "title": text
                                                    } )
                        dialog.colorClicked.connect(function(color) {
                            passiveClockColor.color = color
                            //console.log("ot " + Scripts.colorToAmbienceStr(passiveTextColor))
                            //pageStack.pop()
                        })
                    }
                }

                Button {
                    id: passiveClockBg
                    text: qsTr("out of turn background")
                    //width: passiveClockText.width
                    anchors.top: passiveClockText.bottom
                    //color: (passiveClockBox.color !== "transparent") ? passiveClockBox.color : Theme.highlightColor
                    onClicked: {
                        //var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
                        var dialog = pageStack.push(Qt.resolvedUrl("ColorSelection.qml"), {
                                                        "title": text
                                                    } )
                        dialog.colorClicked.connect(function(color) {
                            passiveClockBox.color = color
                            //console.log("otbg " + Scripts.colorToAmbienceStr(passiveBgColor))
                            //pageStack.pop()
                        })
                    }
                }

                Rectangle {
                    id: passiveClockBox
                    height: activeClockText.height + activeClockBg.height
                    width: passiveClockColor.width + 2*Theme.paddingLarge
                    anchors.right: parent.right
                    border.width: 1
                    border.color: (color === transparent) ? Theme.highlightColor : color
                    radius: Theme.paddingMedium
                }

                Label {
                    id: passiveClockColor
                    text: "20:14"
                    anchors.horizontalCenter: passiveClockBox.horizontalCenter
                    anchors.verticalCenter: passiveClockBox.verticalCenter
                }
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

        refreshComboGame()
        refreshComboLayout()

    }

    onAccepted: {
        bonusT1 = txtBonus1.text*1.0
        bonusPeriods1 = txtBonusPeriods1.value

        if (equalTimes.checked) {
            hoursPlayer2 = hoursPlayer1
            minsPlayer2 = minsPlayer1
            secsPlayer2 = secsPlayer1
            bonusT2 = bonusT1
            bonusPeriods2 = bonusPeriods1
        } else {
            bonusT2 = txtBonus2.text*1.0
            bonusPeriods2 = txtBonusPeriods2.value
        }

        gameSetupName = DataB.lastUsed
        layoutName = DataB.lastUsed
        storeSettings()

    }
}
