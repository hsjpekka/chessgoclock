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

import "../utils"


Page {
    id: page

    property int time01: 30*60*1000
    property int time02: 30*60*1000
    property int time1: time01
    property int time2: time02
    property int gameTime1 // total used time
    property int gameTime2
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
    property int timeStep: 100 //ms
    property int gameOverWaitTime: 3*1000
    property bool clock1running: true
    property bool tapToReset: false

    function byoyomi(player) {
        var result

        if (player === 1) {
            if (bonus1 < 0) {
                bonusTimes1 -= 1
                bonus1 = bonus10
            }
            result = bonusTimes1
        } else {
            if (bonus2 < 0) {
                bonusTimes2 -= 1
                bonus2 = bonus20
            }
            result = bonusTimes2
        }

        return result
    }

    //called when changing turn
    function canadianByoyomi(player) {
        var tulos
        if (player === 2) {
            if (bonus2 > 0) { // don't update if game is over
                bonusTimes2 -= 1 // one out of bonusTimes20 moves done
                if (bonusTimes2 <= 0) { // if all moves done in bonus2-time, start over again
                    bonus2 = bonus20
                    bonusTimes2 = bonusTimes20
                }
            }
            tulos = bonus2
        } else {
            if (bonus1 > 0) {
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

    function changeToClock1() {
        if ((clockCounter.running == false) && (time1 > 0) && (time2 > 0)) {
            clockCounter.start()
            clock1.text = clockText(time1)
            clock2.text = clockText(time2)
        } else {
            if (!clock1running) {
                if (bonusType == 1)
                    time2 += bonus2
                else if (bonusType == 2)
                    bonus2 = bonus20
                else if (bonusType == 3)
                    bonus2 = bonus20
                else if (bonusType == 4)
                    canadianByoyomi(2)

                writeBonus2()
                writeClock2()
            }
        }

        clock1running = true
        clockFonts()

        return
    }

    function changeToClock2() {
        if ((clockCounter.running == false) && (time1 > 0) && (time2 > 0)) {
            clockCounter.start()
            clock1.text = clockText(time1)
            clock2.text = clockText(time2)
        } else {
            if (clock1running) {
                if (bonusType == 1)
                    time1 += bonus1
                else if (bonusType == 2)
                    bonus1 = bonus10
                else if (bonusType == 3)
                    bonus1 = bonus10
                else if (bonusType == 4)
                    canadianByoyomi(1)

                writeBonus1()
                writeClock1()
            }
        }

        clock1running = false
        clockFonts()

        return
    }

    function clockFonts() {
        if (clock1running) {
            clock1.font.bold = true
            clock1.color = Theme.secondaryHighlightColor
            clock1.style = Text.Raised

            clock2.font.bold = false
            clock2.color = Theme.highlightColor
            clock2.style = Text.Sunken

            if (bonusType > 2.5) {
                if (time1 < 0) {
                    bonusClock1.height = 0.2*Screen.height
                    bonusClock1.font.pixelSize = Theme.fontSizeHuge
                    bonusClock1.font.bold = true
                    bonusClock1.color = Theme.secondaryHighlightColor
                    bonusClock1.style = Text.Raised

                    clock1.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - bonusClock1.height

                    if (time2 < 0) {
                        bonusClock2.font.bold = false
                        bonusClock2.color = Theme.highlightColor
                        bonusClock2.style = Text.Sunken
                    }
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
                    bonusClock2.height = 0.2*Screen.height
                    bonusClock2.font.pixelSize = Theme.fontSizeHuge
                    bonusClock2.font.bold = true
                    bonusClock2.color = Theme.secondaryHighlightColor
                    bonusClock2.style = Text.Raised

                    clock2.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - bonusClock2.height

                    if (time1 < 0) {
                        bonusClock1.font.bold = false
                        bonusClock1.color = Theme.highlightColor
                        bonusClock1.style = Text.Sunken
                    }
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

    function gameLost(player) {
        var clo = player == 1 ? clock1 : clock2
        var bon = player == 1 ? bonusClock1 : bonusClock2

        clockCounter.running = false

        if (bonusType > 2.5) {
            bon.text = "0"
            clo.text = qsTr("lost")
        } else {
            clo.text = "0.0"
            clo.style = Text.Outline
            clo.color = Theme.primaryColor

            bon.visible = true
            bon.text = qsTr("lost")
        }

        bonusClock1.text += " - " + qsTr("total time") + " " + clockText(gameTime1)
        bonusClock2.text += " - " + qsTr("total time") + " " + clockText(gameTime2)

        return
    }

    function setUp() {
        tapToReset = false

        gameTime1 = 0
        time1 = time01
        gameTime2 = 0
        time2 = time02

        bonus1 = bonus10
        bonusTimes1 = bonusTimes10
        bonusClock1.font.pixelSize = Theme.fontSizeMedium
        bonusClock1.visible = true
        bonusClock1.height = 0.1*Screen.height

        bonus2 = bonus20
        bonusTimes2 = bonusTimes20
        bonusClock2.font.pixelSize = Theme.fontSizeMedium
        bonusClock2.visible = true
        bonusClock2.height = 0.1*Screen.height

        if (bonusType == 0) {
            bonusClock1.visible = false
            bonusClock1.text = ""
            //bonusClock1.height = 0

            bonusClock2.visible = false
            bonusClock2.text = ""
            //bonusClock2.visible = false
            //bonusClock2.height = 0

        } else if (bonusType == 1) {
            bonusClock1.text = qsTr("adding") + " " + bonus1/1000 + " s " + qsTr("per move")
            bonusClock2.text = qsTr("adding") + " " + bonus2/1000 + " s " + qsTr("per move")
        } else if (bonusType == 2) {
            bonusClock1.text = qsTr("delay") + " " + bonus1/1000 + " s "
            bonusClock1.height = 0.15*Screen.height
            bonusClock1.font.pixelSize = Theme.fontSizeLarge

            bonusClock2.text = qsTr("delay") + " " + bonus2/1000 + " s "
            bonusClock2.height = 0.15*Screen.height
            bonusClock2.font.pixelSize = Theme.fontSizeLarge
        } else if (bonusType == 3) {
            bonusClock1.text = qsTr("after base time") + " " + bonusTimes10 + " x " + bonus10/1000 + " s"
            bonusClock1.font.pixelSize = Theme.fontSizeLarge
            bonusClock2.text = qsTr("after base time") + " " + bonusTimes10 + " x " + bonus10/1000 + " s"
        } else if (bonusType == 4) {
            bonusClock1.text = qsTr("after base time %1 moves in %2 s").arg(bonusTimes10).arg(bonus10/1000)
            bonusClock2.text = qsTr("after base time %1 moves in %2 s").arg(bonusTimes10).arg(bonus10/1000)
        }

        clock1.color = Theme.highlightColor
        clock1.font.bold = false
        clock1.font.overline = false        
        clock1.style = Text.Raised
        clock1.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 8) - bonusClock1.height
        writeClock1()

        clock2.color = Theme.highlightColor
        clock2.font.bold = false
        clock2.font.overline = false
        clock2.style = Text.Raised
        clock2.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 8) - bonusClock2.height
        writeClock2()

        play.enabled = false

        return
    }

    function updateClock1() {
        var result                

        //console.log("updateClock1-0 " + bonusType )

        if (bonusType < 1.5) {
            time1 -= timeStep
            result = time1
        } else if (bonusType < 2.5) {
            if (bonus1 > 0)
                bonus1 -= timeStep
            else
                time1 -= timeStep
            result = time1
            //console.log("updateClock1-2 " + bonus1 + " ")
        } else {
            time1 -= timeStep
            result = time1 + 0.2
            if (time1 < 0) {
                bonus1 -= timeStep
                if (bonusType < 3.5)
                    result = byoyomi(1)
                else
                    result = bonus1
            }

        }

        gameTime1 += timeStep
        return result
    }

    function updateClock2() {
        time2 = time2 - timeStep

        gameTime2 += timeStep
        return time2
    }

    function writeBonus1() {
        var txt = ""

        if (bonusType == 2) {
            txt = qsTr("delay") + " " + (bonus1/1000).toFixed(0) + " s "
        } else if (bonusType == 3) {
            txt = (bonus1/1000).toFixed(0) + " s (/" + bonus10/1000 + " * " + bonusTimes1 + ")"
        } else if (bonusType == 4) {
            txt = (bonus1/1000).toFixed(0) + " s " + qsTr("in %1 moves").arg(bonusTimes1)
        }

        if (bonusType > 1.5) {
            bonusClock1.text = txt
        }

        return txt
    }

    function writeBonus2() {
        var txt =""

        if (bonusType == 2) {
            txt = qsTr("delay") + " " + (bonus2/1000).toFixed(0) + " s "
        } else if (bonusType == 3) {
            txt = (bonus2/1000).toFixed(0) + " s (/" + bonus20/1000 + " * " + bonusTimes2 + ")"
        } else if (bonusType == 4) {
            txt = (bonus2/1000).toFixed(0) + " s " + qsTr("in %1 moves").arg(bonusTimes2)
        }

        if (bonusType > 1.5) {
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
            if (clock1running) {
                if (updateClock1() <= 0) {
                    gameLost(1)

                    gameOverTimer.start()
                } else {
                    writeBonus1()
                    writeClock1()
                }
            } else {
                if (updateClock2() <= 0) {
                    gameLost(2)

                    gameOverTimer.start()
                } else {
                    writeBonus2()
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

    SilicaFlickable {
        anchors.fill: parent

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            Item {
                width: page.width
                height: bonusClock1.height + clock1.height

                Column {
                    spacing: 0
                    Label {
                        id: bonusClock1
                        text: writeBonus1()

                        font.pixelSize: Theme.fontSizeMedium
                        height: 0.15*Screen.height
                        horizontalAlignment: Text.AlignHCenter
                        rotation: 180
                        verticalAlignment: Text.AlignVCenter
                        width: page.width
                        wrapMode: Text.Wrap

                    }

                    Label {
                        id: clock1
                        text: writeClock1()

                        font.pixelSize: 0.28*page.width //Theme.fontSizeExtraLarge
                        height: 0.5*(Screen.height - column.spacing*2 - midRow.height) - bonusClock1.height
                        horizontalAlignment: Text.AlignHCenter
                        rotation: 180
                        verticalAlignment: Text.AlignVCenter
                        width: page.width
                        wrapMode: Text.Wrap

                    }

                }

                MouseArea {
                    id: clock1mouse
                    anchors.fill: parent
                    onClicked: {
                        if (tapToReset)
                            setUp()
                        else
                            changeToClock2()
                    }

                }

            }

            Rectangle {
                height: 1
                width: page.width - 2*Theme.paddingLarge
                x: Theme.paddingLarge // 0.1*page.width
            }

            Row {
                id: midRow
                spacing: Theme.paddingLarge
                //x: Theme.paddingLarge // 0.1*page.width

                    //ValueButton {
                TextField {
                        id: playTime1
                        property int hours1: 0
                        property int minutes1: 30
                        property int seconds1: 0
                        property int hours2: 0
                        property int minutes2: 30
                        property int seconds2: 0

                        function openSettingsDialog() {
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
                                            bonusType: bonusType
                                         })

                            dialog.accepted.connect(function() {
                                hours1 = dialog.hoursPlayer1
                                minutes1 = dialog.minsPlayer1
                                seconds1 = dialog.secsPlayer1
                                bonus1 = dialog.bonusT1*1000
                                bonus10 = bonus1
                                bonusTimes10 = dialog.bonusPeriods1
                                bonusTimes1 = bonusTimes10
                                hours2 = dialog.hoursPlayer2
                                minutes2 = dialog.minsPlayer2
                                seconds2 = dialog.secsPlayer2
                                bonus2 = dialog.bonusT2*1000
                                bonus20 = bonus2
                                bonusTimes20 = dialog.bonusPeriods2
                                bonusTimes2 = bonusTimes20
                                bonusType= dialog.bonusType

                                time01 = ((hours1*60 + minutes1)*60 + seconds1)*1000
                                time02 = ((hours2*60 + minutes2)*60 + seconds2)*1000
                                time1 = time01
                                time2 = time02
                                text = clockText(time01) + ( time01 === time02 ? "" : " - " + clockText(time02))
                                setUp()
                            })
                        }

                        width: Theme.fontSizeMedium*10
                        text: clockText(time01) + ( time01 === time02 ? "" : " - " + clockText(time02)) // textField
                        readOnly: true // TextField
                        horizontalAlignment: TextInput.AlignHCenter //TextField
                        labelVisible: false
                        onClicked: {
                            if (!clockCounter.running)
                                openSettingsDialog()
                        }
                    }

                    IconButton {
                        id: pause
                        icon.source: "image://theme/icon-l-pause"
                        onPressAndHold: {
                            clockCounter.stop()
                            play.enabled = true
                        }

                        enabled: clockCounter.running
                    }

                    IconButton {
                        id: play
                        icon.source: "image://theme/icon-l-play"
                        onClicked: {
                            if (!tapToReset) {
                                clockCounter.start()
                                enabled = false
                            } else {
                                setUp()
                            }
                        }

                        enabled: false
                    }

                }

            Rectangle {
                height: 1
                width: page.width - 2*Theme.paddingLarge
                x: Theme.paddingLarge
            }

            Item {
                width: page.width
                height: bonusClock2.height + clock2.height

                Column {
                    spacing: 0
                    Label {
                            id: clock2
                            text: writeClock2()

                            font.pixelSize: 0.28*page.width //Theme.fontSizeExtraLarge
                            height: 0.5*(Screen.height - column.spacing*2 - midRow.height) - bonusClock2.height
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            width: page.width
                            wrapMode: Text.Wrap
                            //x: Theme.paddingLarge

                        }


                    Label {
                        id: bonusClock2
                        text: writeBonus2()

                        font.pixelSize: Theme.fontSizeMedium
                        height: 0.15*Screen.height
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        width: page.width
                        wrapMode: Text.Wrap

                    }


                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (tapToReset)
                            setUp()
                        else
                            changeToClock1()
                    }
                }


            }
        }

    }

    ScreenBlank {
        enabled: true
    }

    Component.onCompleted: {
        setUp()
    }
}

