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
import QtMultimedia 5.0

import "../utils"

Page {
    id: page
    allowedOrientations: Orientation.All //viewOrientation

    property string alarmFile: "/usr/share/sounds/jolla-ambient/stereo/positive_confirmation.wav"
    property int bonus1: 0 //ms
    property int bonus2: 0 //ms
    property int bonus10: 0 //ms
    property int bonus20: 0 //ms
    property int bonusTimes1: 0
    property int bonusTimes10: 0
    property int bonusTimes2: 0
    property int bonusTimes20: 0
    property int bonusType: 0 // 0 - no bonus, 1 - +X s per move (Fischer), 2 - delay before counting (Bronstein),
                                //3 - after game time N x X extras (Byoyomi), 4 - N moves in X s (Canadian Byoyomi)
    property bool clangAtEnd: false
    property int gameOverWaitTime: 5*1000
    property int gameTime1 // total used time
    property int gameTime2
    property real midSectionSize: pause.height + 2*Theme.paddingSmall
    property int moves1: 0
    property int moves2: 0
    property bool player1turn: true
    //property bool portrait: (page.orientation === Orientation.Portrait || page.orientation === Orientation.PortraitInverted) ? true : false
    property bool tapToReset: false
    property real tileSize: clockSize()
    property int time01: 30*60*1000
    property int time02: 30*60*1000
    property int time1: time01
    property int time2: time02
    property int timeStep: 100 //ms
    //property int viewOrientation: Orientation.All
    property real xPadding: (isPortrait) ? 0 : (page.width - clockTile1.width - clockTile2.width - midSectionSize)/4
    property real yPadding: (isPortrait) ? (page.height - clockTile1.height - clockTile2.height - midSectionSize)/4 : 0

    function byoyomi() {
        var result

        if (player1turn) {
            if (bonus1 < 0) {
                bonusTimes1 -= 1
                if (bonusTimes1 > 0)
                    bonus1 = bonus10
            }
            result = bonusTimes1
        } else {
            if (bonus2 < 0) {
                bonusTimes2 -= 1
                if (bonusTimes2 > 0)
                    bonus2 = bonus20
            }
            result = bonusTimes2
        }

        return result
    }

    //called when changing turn
    function canadianByoyomi() {
        var tulos
        if (!player1turn) {
            if ((bonus2 > 0) && (time2 < 0)) { // don't update if game is over
                bonusTimes2 -= 1 // one out of bonusTimes20 moves done
                if (bonusTimes2 <= 0) { // if all moves done in bonus2-time, start over again
                    bonus2 = bonus20
                    bonusTimes2 = bonusTimes20
                }
            }
            tulos = bonus2
        } else {
            if ((bonus1 > 0) && (time1 < 0)) {
                bonusTimes1 -= 1
                if (bonusTimes1 <= 0) {
                    bonus1 = bonus10
                    bonusTimes1 = bonusTimes10
                }
            }
            tulos = bonus1
        }

        return tulos
    }

    function changePlayer() {

        if (bonusType == 1) {
            if (player1turn)
                time1 += bonus1
            else
                time2 += bonus2
        } else if (bonusType == 2) {
            if (player1turn)
                bonus1 = bonus10
            else
                bonus2 = bonus20
        } else if (bonusType == 3) {
            if (player1turn)
                bonus1 = bonus10
            else
                bonus2 = bonus20
        } else if (bonusType == 4)
            canadianByoyomi()

        writeExtraTime()
        if (player1turn) {
            moves1 += 1
            writeClock1()
        } else {
            moves2 += 1
            writeClock2()
        }

        player1turn = !player1turn
        clockFonts()

        return
    }

    function clockFonts() {
        if (player1turn) {
            clock1.font.bold = true
            clock1.color = Theme.secondaryHighlightColor
            clock1.style = Text.Raised

            clock2.font.bold = false
            clock2.color = Theme.highlightColor
            clock2.style = Text.Sunken

            if (bonusType > 2.5) {
                if (time1 < 0) {
                    //bonusClock1.height = 0.2*Screen.height
                    bonusClock1.font.pixelSize = Theme.fontSizeHuge*1.5
                    bonusClock1.font.bold = true
                    bonusClock1.color = Theme.secondaryHighlightColor
                    bonusClock1.style = Text.Raised

                    clock1.font.pixelSize = Theme.fontSizeHuge*2

                    //clock1.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - stats1.height - bonusClock1.height

                }
                if (time2 < 0) {
                    bonusClock2.font.bold = false
                    bonusClock2.color = Theme.highlightColor
                    bonusClock2.style = Text.Sunken
                }
            }
        } else {
            clock1.font.bold = false
            clock1.color = Theme.highlightColor
            clock1.style = Text.Sunken

            clock2.font.bold = true
            clock2.color = Theme.secondaryHighlightColor
            clock2.style = Text.Raised

            if (bonusType > 2.5) {
                if (time2 < 0) {
                    //bonusClock2.height = 0.2*Screen.height
                    bonusClock2.font.pixelSize = Theme.fontSizeHuge*1.5
                    bonusClock2.font.bold = true
                    bonusClock2.color = Theme.secondaryHighlightColor
                    bonusClock2.style = Text.Raised

                    clock2.font.pixelSize = Theme.fontSizeHuge*2
                    //clock2.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - stats2.height - bonusClock2.height

                }
                if (time1 < 0) {
                    bonusClock1.font.bold = false
                    bonusClock1.color = Theme.highlightColor
                    bonusClock1.style = Text.Sunken
                }

            }
        }

        return
    }

    function clockText(ms) {
        var timeTxt = ""
        var hours = Math.floor(ms/1000/60/60)
        var minutes = Math.floor((ms - hours*60*60*1000)/60/1000)
        var seconds = Math.floor((ms - hours*60*60*1000 - minutes*60*1000)/1000)

        if (ms < 0) {
            timeTxt = "00:00"
        } else {
            if (hours > 0) {
                if (hours < 10)
                    timeTxt = "0"
                timeTxt += hours + ":"
            }

            if (minutes < 10) {
                timeTxt += "0"
            }
            timeTxt += minutes

            //if (hours == 0) {
            timeTxt += ":"

            if (seconds < 10) {
                timeTxt += "0"
            }

            timeTxt += seconds

        }

        return timeTxt
    }

    function clockSize() {
        var size1 = isPortrait ? page.width : page.height
        var size3 = isPortrait ? (page.height - midSectionSize)/2 : (page.width - midSectionSize)/2
        //console.log("koot " + size1 + " " + size3 + " " + page.height + " " + page.width + " " + midSectionSize)
        return Math.min(size1,size3)
    }

    function gameLost(player) {
        var clo = player1turn ? clock1 : clock2
        var loser = player1turn ? bonusClock1 : bonusClock2

        clockCounter.running = false

        clo.text = "0.0"
        clo.style = Text.Outline
        clo.color = Theme.primaryColor

        loser.color = Theme.primaryColor

        stats1.text = qsTr("total time") + " " + clockText(gameTime1) + ", " + moves1 + " " + qsTr("moves")
        stats2.text = qsTr("total time") + " " + clockText(gameTime2) + ", " + moves2 + " " + qsTr("moves")

        if (clangAtEnd)
            alarm.play()

        return
    }

    function openSettingsDialog() {
        var hours1, minutes1, seconds1, hours2, minutes2, seconds2
        var sec = 1000, min = 60*sec, h = 60*min

        hours1 = Math.floor(time01/h)
        minutes1 = Math.floor((time01-hours1*h)/min)
        seconds1 = Math.floor((time01-hours1*h-minutes1*min)/sec)

        hours2 = Math.floor(time02/h)
        minutes2 = Math.floor((time02-hours2*h)/min)
        seconds2 = Math.floor((time02-hours2*h-minutes2*min)/sec)

        var dialog = pageStack.push(Qt.resolvedUrl("TimeSettings.qml"), {
                        hoursPlayer1: hours1,
                        minsPlayer1: minutes1,
                        secsPlayer1: seconds1,
                        bonusT1: bonus10/1000,

                                        bonusPeriods1: bonusTimes10,
                        hoursPlayer2: hours2,
                        minsPlayer2: minutes2,
                        secsPlayer2: seconds2,
                        bonusT2: bonus20/1000,
                        bonusPeriods2: bonusTimes20,
                        bonusType: bonusType,
                        useSounds: clangAtEnd,
                        soundFile: alarmFile//,
                        //screenOrientation: viewOrientation
                     })

        dialog.accepted.connect(function() {
            hours1 = dialog.hoursPlayer1
            minutes1 = dialog.minsPlayer1
            seconds1 = dialog.secsPlayer1
            bonus1 = dialog.bonusT1*1000
            bonus10 = bonus1
            bonusTimes10 = dialog.bonusPeriods1
            bonusTimes1 = bonusTimes10
            time01 = ((hours1*60 + minutes1)*60 + seconds1)*1000
            time1 = time01

            hours2 = dialog.hoursPlayer2
            minutes2 = dialog.minsPlayer2
            seconds2 = dialog.secsPlayer2
            bonus2 = dialog.bonusT2*1000
            bonus20 = bonus2
            bonusTimes20 = dialog.bonusPeriods2
            bonusTimes2 = bonusTimes20
            time02 = ((hours2*60 + minutes2)*60 + seconds2)*1000
            time2 = time02


            bonusType = dialog.bonusType
            clangAtEnd = dialog.useSounds
            alarmFile = dialog.soundFile

            //viewOrientation = dialog.screenOrientation
            //console.log("asento " + viewOrientation + " leveys " + page.width + " korkeus " + page.height)
            setUp()

            return
        })

        return
    }

    function startGame(player) {
        if ((clockCounter.running == false) && (time1 > 0) && (time2 > 0)) {
            clock1.text = clockText(time1)
            clock2.text = clockText(time2)
            if (player == 1)
                player1turn = true
            else
                player1turn = false

            clockFonts()
            clockCounter.start()

            play.enabled = false

        }

        return
    }

    function setUp() {
        tapToReset = false

        gameTime1 = 0
        moves1 = 0
        time1 = time01
        gameTime2 = 0
        moves2 = 0
        time2 = time02

        bonus1 = bonus10
        bonusTimes1 = bonusTimes10
        bonusClock1.visible = true
        bonusClock1.font.bold = false
        bonusClock1.color = Theme.primaryColor
        bonusClock1.style = Text.Normal

        bonus2 = bonus20
        bonusTimes2 = bonusTimes20
        bonusClock2.visible = true
        bonusClock2.font.bold = false
        bonusClock2.color = Theme.primaryColor
        bonusClock2.style = Text.Normal

        setUpFontSizes()

        if (bonusType == 0) {
            //bonusClock1.height = 0.1*Screen.height
            bonusClock1.text = " "

            //bonusClock2.height = 0.1*Screen.height
            bonusClock2.text = " "

        } else if (bonusType == 1) {
            //bonusClock1.height = 0.1*Screen.height
            bonusClock1.text = qsTr("adding %1 s per move").arg(bonus1/1000)
            //bonusClock2.height = 0.1*Screen.height
            bonusClock2.text = qsTr("adding %1 s per move").arg(bonus2/1000)
        } else if (bonusType == 2) {
            bonusClock1.text = qsTr("delay") + " " + bonus1/1000 + " s "
            //bonusClock1.height = 0.15*Screen.height
            bonusClock2.text = qsTr("delay") + " " + bonus2/1000 + " s "
            //bonusClock2.height = 0.15*Screen.height
        } else if (bonusType == 3) {
            bonusClock1.text = qsTr("after main time") + " " + bonusTimes10 + " x " + bonus10/1000 + " s"
            //bonusClock1.height = 0.2*Screen.height
            bonusClock2.text = qsTr("after main time") + " " + bonusTimes20 + " x " + bonus20/1000 + " s"
            //bonusClock2.height = 0.2*Screen.height
        } else if (bonusType == 4) {
            bonusClock1.text = qsTr("after main time %1 moves in %2 s").arg(bonusTimes10).arg(bonus10/1000)
            //bonusClock1.height = 0.2*Screen.height
            bonusClock2.text = qsTr("after main time %1 moves in %2 s").arg(bonusTimes20).arg(bonus20/1000)
            //bonusClock2.height = 0.2*Screen.height
        }

        clock1.color = Theme.highlightColor
        clock1.font.bold = false
        clock1.font.overline = false
        clock1.style = Text.Raised
        //clock1.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2)  - stats1.height - bonusClock1.height
        writeClock1()

        clock2.color = Theme.highlightColor
        clock2.font.bold = false
        clock2.font.overline = false
        clock2.style = Text.Raised
        //clock2.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - stats2.height - bonusClock2.height
        writeClock2()

        stats1.text = " "
        stats2.text = " "

        play.enabled = false

        if (clangAtEnd)
            alarm.stop()

        return
    }

    function setUpFontSizes() {
        if (bonusType < 1.5) {
            bonusClock1.font.pixelSize = Theme.fontSizeMedium
            bonusClock2.font.pixelSize = Theme.fontSizeMedium
        } else {
            bonusClock1.font.pixelSize = Theme.fontSizeLarge
            bonusClock2.font.pixelSize = Theme.fontSizeLarge
        }
        return
    }

    function updateClock1() {
        var result                

        if (bonusType < 1.5) {
            time1 -= timeStep
            result = time1
        } else if (bonusType < 2.5) {
            if (bonus1 > 0)
                bonus1 -= timeStep
            else
                time1 -= timeStep
            result = time1
        } else {
            time1 -= timeStep
            result = time1 + 0.2
            if (time1 < 0) {
                if (time1 > -1.5*timeStep)
                    clockFonts()
                bonus1 -= timeStep
                if (bonusType < 3.5)
                    result = byoyomi()
                else
                    result = bonus1
            }

        }

        gameTime1 += timeStep
        return result
    }

    function updateClock2() {
        var result

        if (bonusType < 1.5) {
            time2 -= timeStep
            result = time2
        } else if (bonusType < 2.5) {
            if (bonus2 > 0)
                bonus2 -= timeStep
            else
                time2 -= timeStep
            result = time2
        } else {
            time2 -= timeStep
            result = time2 + 0.2
            if (time2 < 0) {
                if (time2 > -1.5*timeStep)
                    clockFonts()
                bonus2 -= timeStep
                if (bonusType < 3.5)
                    result = byoyomi()
                else
                    result = bonus2
            }

        }

        gameTime2 += timeStep
        return result
    }

    function writeExtraTime() {
        var txt = ""
        var extra = player1turn ? bonus1 : bonus2
        var max = player1turn ? bonusTimes10 : bonusTimes20
        var count = player1turn ? bonusTimes1 : bonusTimes2

        if (bonusType == 2) {
            txt = qsTr("delay") + " " + (extra/1000).toFixed(0) + " s "
        } else if (bonusType == 3) {
            txt = clockText(extra) + " (" + count + "/" + max + ")"
        } else if (bonusType == 4) {
            //txt = qsTr("%1 moves in").arg(count) + " " + clockText(extra)
            txt = count + "  -  "  + clockText(extra)
        }

        if (bonusType > 1.5) {
            if (player1turn)
                bonusClock1.text = txt
            else
                bonusClock2.text = txt
        }

        return txt
    }

    function writeClock1() {
        var txt = clockText(time1)

        clock1.text = txt

        return txt
    }

    function writeClock2() {
        var txt = clockText(time2)

        clock2.text = txt

        return txt
    }

    Timer {
        id: clockCounter
        interval: timeStep
        running: false
        repeat: true
        onTriggered: {
            if (player1turn) {
                if (updateClock1() <= 0) {
                    writeExtraTime()
                    gameLost(1)

                    gameOverTimer.start()
                } else {
                    writeExtraTime()
                    writeClock1()
                }
            } else {
                if (updateClock2() <= 0) {
                    writeExtraTime()
                    gameLost(2)

                    gameOverTimer.start()
                } else {
                    writeExtraTime()
                    writeClock2()
                }
            }
        }
    }

    Timer {
        id: gameOverTimer
        interval: gameOverWaitTime
        running: false
        repeat: false
        onTriggered: {
            tapToReset = true
            play.enabled = true
        }
    }

    Item { // clock1
        //height: bonusClock1.height + clock1.height + stats1.height
        id: clockTile1
        height: tileSize //clockSize()
        width: height
        x: (isPortrait) ? 0.5*(page.width - width) : xPadding
        y: (isPortrait) ? yPadding : 0.5*(page.height - height)

        state: isPortrait ? "vertical" : "horizontal"
        states: [
            State {
                name: "horizontal"

                AnchorChanges {
                    target: bonusClock1
                    anchors.top: undefined
                    anchors.bottom: clockTile1.bottom
                }

                AnchorChanges {
                    target: stats1
                    anchors.top: clockTile1.top
                    anchors.bottom: undefined
                }
            },

            State {
                name: "vertical"

                AnchorChanges {
                    target: bonusClock1
                    anchors.top: clockTile1.top
                    anchors.bottom: undefined
                }

                AnchorChanges {
                    target: stats1
                    anchors.top: undefined
                    anchors.bottom: clockTile1.bottom
                }
            }
        ]  // */

        Label {
            id: bonusClock1
            //x: clockTile1.x
            //y: (isPortrait) ? (0.5*(clockTile1.height - clock1.height) - height)/2 : 0.5*(page.height - height)
            //y: (isPortrait) ? (0.5*(clockTile1.height - clock1.height) - height)/2 + height : (0.5*(clockTile1.height - clock1.height) - height)/2
            anchors.top: clockTile1.top
            anchors.horizontalCenter: clockTile1.horizontalCenter
            text: "" // "extraTime"

            font.pixelSize: Theme.fontSizeMedium
            //height: 0
            horizontalAlignment: Text.AlignHCenter
            rotation: (isPortrait) ? 180 : 0
            verticalAlignment: Text.AlignVCenter
            width: clockTile1.width
            wrapMode: Text.Wrap

        }

        Label {
            id: clock1
            //anchors.top: bonusClock1.bottom
            anchors.horizontalCenter: clockTile1.horizontalCenter
            y: 0.5*(clockTile1.height - height)

            text: writeClock1()

            font.pixelSize: 0.3*clockTile1.width //Theme.fontSizeExtraLarge
            height: clockTile1.heigt - stats1.height - bonusClock1.height
            horizontalAlignment: Text.AlignHCenter
            rotation: (isPortrait) ? 180 : 0
            verticalAlignment: Text.AlignVCenter
            width: clockTile1.width
            wrapMode: Text.NoWrap

        }

        Label {
            id: stats1
            anchors.bottom: clockTile1.bottom
            anchors.horizontalCenter: clockTile1.horizontalCenter
            //y: (isPortrait) ? clockTile1.height - height - 0.5*(clockTile1.height - clock1.y - clock1.height) : (0.5*(clockTile1.height - clock1.height) - height)/2
            text: ""
            rotation: (isPortrait) ? 180 : 0
            width: clockTile1.width
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            id: clock1mouse
            anchors.fill: parent
            onClicked: {
                console.log(" clicked " + tapToReset + " " + clockCounter.running + " " + gameOverTimer.running)

                if (tapToReset)
                    setUp()
                else {
                    if (clockCounter.running) {
                        if (player1turn)
                            changePlayer()
                    } else {
                        if (!gameOverTimer.running)
                            startGame(2)
                    }

                }

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()

            }

        }

    }

    Item { // settings
        id: settingsTile
        x: (page.isPortrait) ? 0 : clockTile1.width + 2*xPadding
        y: (page.isPortrait) ? clockTile1.height + 2*yPadding : 0
        height: (page.isPortrait) ? midSectionSize : page.height
        width: (page.isPortrait) ? page.width : midSectionSize
        //*
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("alue")
                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()
            }
        }// */

        Rectangle {
            id: sepa1
            x: (page.isPortrait) ? Theme.paddingLarge : 0// 0.1*page.width
            y: (page.isPortrait) ? 0 : Theme.paddingLarge
            //height: (page.isPortrait) ? 1 : page.height - 2*Theme.paddingLarge
            //width: (page.isPortrait) ? page.width - 2*Theme.paddingLarge : 1
            width: 1
            height: page.isPortrait ? page.width - 2*Theme.paddingLarge : page.height - 2*Theme.paddingLarge
            rotation: page.isPortrait ? 90 : 0
            transform: Translate {
                x: (sepa1.rotation != 0) ? 0.5*sepa1.height : 0
                y: (sepa1.rotation != 0) ? -0.5*sepa1.height : 0
            }

            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.highlightColor }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        IconButton {
            id: settings
            icon.source: "image://theme/icon-m-developer-mode"
            x: (isPortrait) ? Theme.paddingLarge : 0.5*(midSectionSize - width)
            y: (isPortrait) ? 0.5*(midSectionSize - height) : page.height - height - Theme.paddingLarge //- width //settingsTile.y + 2 : page.height
            onClicked: {
                if (!clockCounter.running)
                    openSettingsDialog()

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()

            }
        }

        Label {
            id: playTime1
            text: clockText(time01) + ( time01 === time02 ? "" : " - " + clockText(time02))
            x: (isPortrait) ? settings.x + settings.width : 0.5*(midSectionSize-height)
            y: (isPortrait) ? 0.5*(midSectionSize-height) : 0.5*(settings.y + pause.y + pause.height - height)
            width: isPortrait ? pause.x- settings.x - settings.width : settings.y - pause.y - pause.height
            rotation: isPortrait ? 0 : -90
            transform: Translate {
                x: (playTime1.rotation != 0) ? -0.5*(playTime1.width - playTime1.height) : 0
                //y: (playTime1.rotation != 0) ? -0.5*width : 0
            }

            color: Theme.secondaryColor
            horizontalAlignment: TextInput.AlignHCenter
        }

        /*
        TextField {
            id: playTime1
            rotation: (page.isPortrait) ? 0 : 270
            x: (isPortrait) ? 0.5*(pause.x - width) : 2 - height // settingsTile.x + 2
            y: (isPortrait) ? 2 : 0.5*(page.height + pause.y + pause.height - height) //- width //settingsTile.y + 2 : page.height
            //width: Theme.fontSizeMedium*10
            text: qsTr("settings") + " " + x + " " + y
            label: clockText(time01) + ( time01 === time02 ? "" : " - " + clockText(time02))
            readOnly: true
            horizontalAlignment: TextInput.AlignHCenter

            property int hours1: 0
            property int minutes1: 30
            property int seconds1: 0
            property int hours2: 0
            property int minutes2: 30
            property int seconds2: 0

            onClicked: {
                if (!clockCounter.running)
                    openSettingsDialog()

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()

            }
        } // */

        IconButton {
            id: pause
            x: (isPortrait) ? page.width - Theme.paddingLarge - 2*width - Theme.paddingMedium : 0.5*(settingsTile.width - width)
            y: (isPortrait) ? 0.5*(settingsTile.height - height) : Theme.paddingLarge + Theme.paddingMedium + height
            icon.source: "image://theme/icon-l-pause"
            onPressAndHold: {
                    clockCounter.stop()
                    play.enabled = true

                    if (clangAtEnd && gameOverTimer.running)
                        alarm.stop()
                }

            enabled: clockCounter.running
        }

        IconButton {
            id: play
            x: (isPortrait) ? page.width - Theme.paddingLarge - width : 0.5*(settingsTile.width - width)
            y: (isPortrait) ? 0.5*(settingsTile.height - height) : Theme.paddingLarge

            icon.source: "image://theme/icon-l-play"
            onClicked: {
                if (!tapToReset) {
                    clockCounter.start()
                    enabled = false
                } else {
                    setUp()
                }

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()

            }

            enabled: false
        }

        Rectangle {
            id: sepa2
            x: (page.isPortrait) ? Theme.paddingLarge : midSectionSize - 1// 0.1*page.width
            y: (page.isPortrait) ? midSectionSize - 1 : Theme.paddingLarge
            //height: (page.isPortrait) ? 1 : page.height - 2*Theme.paddingLarge
            //width: (page.isPortrait) ? page.width - 2*Theme.paddingLarge : 1
            width: 1
            height: page.isPortrait ? page.width - 2*Theme.paddingLarge : page.height - 2*Theme.paddingLarge
            rotation: page.isPortrait ? 90 : 0
            transform: Translate {
                x: (sepa2.rotation != 0) ? 0.5*sepa2.height : 0
                y: (sepa2.rotation != 0) ? -0.5*sepa2.height : 0
            }

            gradient: Gradient {
                GradientStop { position: 0; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.highlightColor }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

    }

    Item { // clock2
        id: clockTile2
        height: tileSize
        width: height
        x: (isPortrait) ? 0.5*(page.width - width) : (settingsTile.x + midSectionSize + xPadding)
        y: (isPortrait) ? (settingsTile.y + midSectionSize + yPadding) : 0.5*(page.height - height)
        //height: bonusClock2.height + clock2.height + stats2.height

        Label {
            id: stats2
            //y: (0.5*(clockTile2.height - clock2.height) - height)/2
            anchors.top: clockTile2.top
            anchors.horizontalCenter: clockTile2.horizontalCenter
            text: ""
            width: clockTile2.width
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: clock2
            anchors.horizontalCenter: clockTile2.horizontalCenter
            y: 0.5*(clockTile2.height - height)
            text: writeClock2()

            font.pixelSize: 0.3*clockTile2.width
            height: clockTile2.heigt - stats2.height - bonusClock2.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: clockTile2.width
            wrapMode: Text.NoWrap

        }

        Label {
            id: bonusClock2
            anchors.bottom: clockTile2.bottom
            anchors.horizontalCenter: clockTile2.horizontalCenter
            //y: 0.5*(clockTile2.height + clock2.height) + 0.5*(clockTile2.height - clock2.y - clock2.height - height)
            text: "" // "Extra time"

            font.pixelSize: Theme.fontSizeMedium
            //height: 0.25*clockTile2.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            width: clockTile2.width
            wrapMode: Text.Wrap

        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (tapToReset)
                    setUp()
                else {
                    if (clockCounter.running) {
                        if (!player1turn)
                            changePlayer()
                    } else {
                        if (!gameOverTimer.running)
                            startGame(1)
                    }

                }

                if (clangAtEnd && gameOverTimer.running){
                    alarm.stop()
                }

            }
        }

    }

    ScreenBlank { //prevents screen from locking and turning off
        id: unblankScreen
        enabled: clockCounter.running
    }

    Audio {
        id: alarm
        source: alarmFile        
    }

    Component.onCompleted: {
        setUp()
    }

}
