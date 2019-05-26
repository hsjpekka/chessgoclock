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
import QtQuick.LocalStorage 2.0

import "../utils"
import "../utils/database.js" as DataB
import "../utils/scripts.js" as Scripts

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations //Orientation.All// Orientation.Portrait //viewOrientation

    property string alarmFile: "/usr/share/sounds/jolla-ambient/stereo/positive_confirmation.wav"
    property string boardLayoutName: ""
    property int bonus1: 0 //ms, player 1, current bonustime left
    property int bonus2: 0 //ms
    property int bonus10: 0 //ms, player 1, specified bonustime
    property int bonus20: 0 //ms
    property int bonusTimes1: 0 // bonus1 can be used X times / in X moves
    property int bonusTimes10: 0 // specified bonusTimes
    property int bonusTimes2: 0
    property int bonusTimes20: 0
    property int bonusType: 0 // 0 - no bonus, 1 - +X s per move (Fischer), 2 - delay before counting (Bronstein),
                                //3 - after game time N x X extras (Byoyomi), 4 - N moves in X s (Canadian Byoyomi)
    property bool clangAtEnd: false
    property color colorActiveArea: "transparent" // Theme.secondaryColor
    property color colorActiveFont: Theme.secondaryHighlightColor
    property color colorPassiveArea: "transparent"
    property color colorPassiveFont: Theme.highlightColor
    property string clrStrAArea: "transparent"
    property string clrStrATxt: Scripts.secondaryHighlightColor
    property string clrStrPArea: "transparent"
    property string clrStrPTxt: Scripts.highlightColor //in-turn area, text, out area, txt
    property int gameOverWaitTime: 5*1000
    property bool gameRunning: false
    property string gameSetupName: ""
    property int gameTime1 // total used time
    property int gameTime2
    property int hourMs: 60*60*1000 // ms
    property real midSectionSize: pause.height + 2*Theme.paddingSmall
    property int moves1: 0
    property int moves2: 0
    property bool player1turn: true
    property real portraitHeight: clockSize(1)
    property real portraitWidth: clockSize(2)
    //property bool portrait: (page.orientation === Orientation.Portrait || page.orientation === Orientation.PortraitInverted) ? true : false
    property bool tapToReset: false
    property int time01: 30*60*1000 // specified playing time
    property int time02: 30*60*1000
    property int time1: time01 // remaining playing time
    property int time2: time02
    property bool timeEnded: (bonusType < 1.5) ? (time1 <= 0 || time2 <=0) : (
                                (bonusType === 4) ? (bonus1 <= 0 || bonus2 <= 0) :
                                ( (time1 <= 0 && bonus1 <= 0 && bonusTimes1 <= 0) ||
                                 (time2 <= 0 && bonus2 <= 0 && bonusTimes2 <= 0)) )   //( (time1 <= 0 && bonus1 <= 0 && bonusTimes1 <= 0) || (time2 <= 0 && bonus2 <= 0 && bonusTimes2 <= 0) ) ? true : false
    property int timeStep: 100 //ms
    property int turnChangeHours: 0 // qml int is not large enough for Date().getTime()
    property int turnChangeMs: 0 // remains of the getTime()
    //property int viewOrientation: Orientation.All
    //property real xPadding: (isPortrait) ? 0 : (page.width - clockTile1.width - clockTile2.width - midSectionSize)/4
    //property real yPadding: (isPortrait) ? (page.height - clockTile1.height - clockTile2.height - midSectionSize)/4 : 0

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
        var changeTime = new Date().getTime(), usedMs
        var dt

        usedMs = changeTime - turnChangeHours*hourMs - turnChangeMs
        dt = usedMs - Math.floor(usedMs/timeStep)*timeStep // time since the last trigger

        turnChangeHours = Math.floor(changeTime/hourMs)
        turnChangeMs = changeTime - turnChangeHours*hourMs

        if (player1turn)
            updateClock1(dt)
        else
            updateClock2(dt)

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
            //clock1.color = colorActiveFont // Theme.secondaryHighlightColor
            clock1.style = Text.Raised

            clock2.font.bold = false
            //clock2.color = colorPassiveFont // Theme.highlightColor
            clock2.style = Text.Sunken

            if (bonusType > 2.5) {
                if (time1 < 0) {
                    //bonusClock1.height = 0.2*Screen.height
                    bonusClock1.font.pixelSize = Theme.fontSizeHuge*1.5
                    bonusClock1.font.bold = true
                    //bonusClock1.color = clock1.color
                    bonusClock1.style = Text.Raised

                    clock1.font.pixelSize = Theme.fontSizeHuge*2

                    //clock1.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - stats1.height - bonusClock1.height

                }
                if (time2 < 0) {
                    bonusClock2.font.bold = false
                    //bonusClock2.color = clock2.color // Theme.highlightColor
                    bonusClock2.style = Text.Sunken
                }
            }
        } else {
            clock1.font.bold = false
            //clock1.color = colorPassiveFont // Theme.highlightColor
            clock1.style = Text.Sunken

            clock2.font.bold = true
            //clock2.color = colorActiveFont // Theme.secondaryHighlightColor
            clock2.style = Text.Raised

            //if(highlightBackground) {
            //    clock2.color = Theme.highlightDimmerColor
            //}

            if (bonusType > 2.5) {
                if (time2 < 0) {
                    //bonusClock2.height = 0.2*Screen.height
                    bonusClock2.font.pixelSize = Theme.fontSizeHuge*1.5
                    bonusClock2.font.bold = true
                    //bonusClock2.color = clock2.color
                    bonusClock2.style = Text.Raised

                    clock2.font.pixelSize = Theme.fontSizeHuge*2
                    //clock2.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - stats2.height - bonusClock2.height

                }
                if (time1 < 0) {
                    bonusClock1.font.bold = false
                    //bonusClock1.color = clock1.color // Theme.highlightColor
                    bonusClock1.style = Text.Sunken
                }

            }
        }

        if (bonusType == 2) {
            bonusClock1.font.bold = clock1.font.bold
            //bonusClock1.color = clock1.color
            bonusClock2.font.bold = clock2.font.bold
            //bonusClock2.color = clock2.color
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
        } else if (ms < 1000) {
            timeTxt = "0." + Math.floor(ms/100)
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

    function clockSize(dir) {
        var size1 = isPortrait ? page.width : page.height
        var size3 = isPortrait ? (page.height - midSectionSize)/2 : (page.width - midSectionSize)/2
        //console.log("koot " + size1 + " " + size3 + " " + page.height + " " + page.width + " " + midSectionSize)
        return (dir === 1) ? size3 : size1 //Math.min(size1,size3)
    }

    /*//ei käytössä
    function colorTheme() {
        Scripts.themePrimary = Theme.primaryColor
        Scripts.themeSecondary = Theme.secondaryColor
        Scripts.themeHigh = Theme.highlightColor
        Scripts.theme2ndHigh = Theme.secondaryHighlightColor
        Scripts.themeDimmer = Theme.highlightDimmerColor
        Scripts.themeBg = Theme.highlightBackgroundColor
        Scripts.themeDark = Theme.darkPrimaryColor
        Scripts.theme2ndDark = Theme.darkSecondaryColor
        Scripts.themeLight = Theme.lightPrimaryColor
        Scripts.theme2ndLight = Theme.lightSecondaryColor
        //console.log("opacity " + Theme.highlightBackgroundOpacity)
    }
    */

    function gameEnded() {
        showStats()
        gameRunning = false
        setUp()

        return
    }

    function gameLost(player) {
        var clo = player1turn ? clock1 : clock2
        var loser = player1turn ? bonusClock1 : bonusClock2

        clockCounter1.running = false
        clockCounter2.running = false
        gameRunning = false

        clo.text = "-.-"
        clo.style = Text.Outline
        //clo.color = colorActiveFont//Theme.primaryColor

        //loser.color = colorActiveFont //Theme.primaryColor

        showStats()
        //gameEnded()

        if (clangAtEnd)
            alarm.play()

        //console.log("" + timeEnded + ", " + time1 + ", " + bonus1 + ", " + bonusTimes1  + ", " + time2 + ", " + bonus2 + ", " + bonusTimes2)

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

        //console.log("Clocks: system " + bonusType)

        var dialog = pageStack.push(Qt.resolvedUrl("TimeSettings.qml"), {
                                        "hoursPlayer1": hours1, "minsPlayer1": minutes1,
                                        "secsPlayer1": seconds1, "bonusT1": bonus10/1000,
                                        "bonusPeriods1": bonusTimes10,
                                        "hoursPlayer2": hours2, "minsPlayer2": minutes2,
                                        "secsPlayer2": seconds2, "bonusT2": bonus20/1000,
                                        "bonusPeriods2": bonusTimes20,
                                        "timeSystem": bonusType, "useSounds": clangAtEnd,
                                        "soundFile": alarmFile,
                                        "activeTextColor": colorActiveFont,
                                        "activeBgColor": colorActiveArea,
                                        "passiveTextColor": colorPassiveFont,
                                        "passiveBgColor": colorPassiveArea,
                                        "layoutName": boardLayoutName,
                                        "gameSetupName": gameSetupName
                     })

        dialog.accepted.connect(function() {
            var sec = 1000
            gameRunning = false
            bonusType = dialog.timeSystem
            gameSetupName = dialog.gameSetupName

            hours1 = dialog.hoursPlayer1
            minutes1 = dialog.minsPlayer1
            seconds1 = dialog.secsPlayer1
            bonus1 = dialog.bonusT1*sec
            bonus10 = bonus1
            bonusTimes10 = dialog.bonusPeriods1
            bonusTimes1 = bonusTimes10
            time01 = ((hours1*60 + minutes1)*60 + seconds1)*sec
            if (time01 == 0)
                time01 = 1
            time1 = time01

            hours2 = dialog.hoursPlayer2
            minutes2 = dialog.minsPlayer2
            seconds2 = dialog.secsPlayer2
            bonus2 = dialog.bonusT2*sec
            bonus20 = bonus2
            bonusTimes20 = dialog.bonusPeriods2
            bonusTimes2 = bonusTimes20
            time02 = ((hours2*60 + minutes2)*60 + seconds2)*sec
            if (time02 == 0)
                time02 = 1
            time2 = time02

            if (bonusType === 0) {
                bonus1 = 0
                bonus10 = 0
                bonus2 = 0
                bonus20 = 0
            }
            if (bonusType < 2.5) {
                bonusTimes1 = 0
                bonusTimes10 = 0
                bonusTimes2 = 0
                bonusTimes20 = 0
            }


            boardLayoutName = dialog.layoutName
            clangAtEnd = dialog.useSounds
            alarmFile = dialog.soundFile

            setColors(dialog.activeBgColor, dialog.activeTextColor, dialog.passiveBgColor, dialog.passiveTextColor)

            //viewOrientation = dialog.screenOrientation
            clockFonts()

            setUp()

            //storeSettings()

            return
        })

        return
    }

    function readBoardSettings(setupNr) {
        var dum
        DataB.createTable(DataB.layoutDb)

        if (DataB.readTable(DataB.layoutDb) === 0) {
            console.log("layoutDb 0 rows")
            DataB.newLayoutSet(0, DataB.lastUsed, colorActiveFont, colorActiveArea,
                             colorPassiveFont, colorPassiveArea, alarmFile, clangAtEnd)
        } else {
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyActiveBg)
            clrStrAArea = dum
            colorActiveArea = Scripts.strToAmbienceColor(dum)
            //Scripts.strToAmbienceColor(colorActiveArea, dum)
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyActiveFont)
            clrStrATxt = dum
            colorActiveFont = Scripts.strToAmbienceColor(dum)
            //Scripts.strToAmbienceColor(colorActiveFont, dum)
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyPassiveBg)
            clrStrPArea = dum
            colorPassiveArea = Scripts.strToAmbienceColor(dum)
            //Scripts.strToAmbienceColor(colorPassiveArea, dum)
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyPassiveFont)
            clrStrPTxt = dum
            colorPassiveFont = Scripts.strToAmbienceColor(dum)
            //Scripts.strToAmbienceColor(colorPassiveFont, dum)
            alarmFile = DataB.readValue(DataB.layoutDb, setupNr, DataB.keySound)
            clangAtEnd = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyUseSound)
        }

        return
    }

    function readClockSettings(setupNr) {
        var second = 1000
        DataB.createTable(DataB.gameDb)
        //console.log("read time " + setupNr)
        if (DataB.readTable(DataB.gameDb) === 0) {
            // alusta taulukko
            console.log("gameDb 0 riviä")
            DataB.newGameSet(0, DataB.lastUsed, bonusType, time01, bonus10, bonusTimes10,
                             time02, bonus20, bonusTimes20)
        } else {
            time01 = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl1Time)*second
            time1 = time01
            time02 = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl2Time)*second
            time2 = time02
            bonus10 = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl1Extra)*second
            bonus1 = bonus10
            bonus20 = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl2Extra)*second
            bonus2 = bonus20
            bonusTimes10 = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl1Nbr)
            bonusTimes1 = bonusTimes10
            bonusTimes20 = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl2Nbr)
            bonusTimes2 = bonusTimes20

            bonusType = DataB.readValue(DataB.gameDb, setupNr, DataB.keyGame)
            if (bonusType === 0) {
                bonus1 = 0
                bonus10 = 0
                bonus2 = 0
                bonus20 = 0
            }
            if (bonusType < 2.5) {
                bonusTimes1 = 0
                bonusTimes10 = 0
                bonusTimes2 = 0
                bonusTimes20 = 0
            }

            //console.log("peli " + bonusType + ", " + DataB.readValue(DataB.gameDb, setupNr, DataB.keyName) +
            //            ", t1 " + time1/1000 + ", t2 " + time2/1000)
        }

        return
    }

    function readDb() {
        DataB.openDb(LocalStorage)

        readBoardSettings(0)
        readClockSettings(0)

        return

    }

    function refreshColors() {
        colorActiveArea = Scripts.strToAmbienceColor(clrStrAArea)
        colorActiveFont = Scripts.strToAmbienceColor(clrStrATxt)
        colorPassiveArea = Scripts.strToAmbienceColor(clrStrPArea)
        colorPassiveFont = Scripts.strToAmbienceColor(clrStrPTxt)

        return
    }

    function setColors(actBg, actTxt, pasBg, pasTxt) {
        colorActiveFont = actTxt //Scripts.colorToAmbience(colorActiveFont, dialog.activeTextColor)//
        colorActiveArea = actBg //Scripts.colorToAmbience(colorActiveArea, dialog.activeBgColor)//
        colorPassiveFont = pasTxt //Scripts.colorToAmbience(colorPassiveFont, dialog.passiveTextColor)//
        colorPassiveArea = pasBg //Scripts.colorToAmbience(colorPassiveArea, dialog.passiveBgColor)//

        clrStrAArea = Scripts.colorToAmbienceStr(actBg)
        clrStrATxt = Scripts.colorToAmbienceStr(actTxt)
        clrStrPArea = Scripts.colorToAmbienceStr(pasBg)
        clrStrPTxt = Scripts.colorToAmbienceStr(pasTxt)

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
        //bonusClock1.color = colorPassiveFont
        bonusClock1.style = Text.Normal

        bonus2 = bonus20
        bonusTimes2 = bonusTimes20
        bonusClock2.visible = true
        bonusClock2.font.bold = false
        //bonusClock2.color = Theme.primaryColor
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

        //clock1.color = colorPassiveFont//Theme.highlightColor
        clock1.font.bold = false
        clock1.font.overline = false
        clock1.style = Text.Raised
        //clock1.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2)  - stats1.height - bonusClock1.height
        writeClock1()

        //clock2.color = colorPassiveFont//Theme.highlightColor
        clock2.font.bold = false
        clock2.font.overline = false
        clock2.style = Text.Raised
        //clock2.height = 0.5*(Screen.height - column.spacing*4 - midRow.height - 2) - stats2.height - bonusClock2.height
        writeClock2()

        //stats1.text = " "
        //stats2.text = " "

        play.enabled = false

        if (clangAtEnd)
            alarm.stop()

        return
    }

    function setUpFontSizes() {
        //console.log("clocks " + clock1.font.pixelSize + ", " + clock2.font.pixelSize)
        clock1.font.pixelSize= 0.3*Math.min(portraitHeight,portraitWidth)
        clock2.font.pixelSize= 0.3*Math.min(portraitHeight,portraitWidth)
        //console.log("clocks " + clock1.font.pixelSize + ", " + clock2.font.pixelSize)

        if (bonusType < 1.5) {
            bonusClock1.font.pixelSize = Theme.fontSizeMedium
            bonusClock2.font.pixelSize = Theme.fontSizeMedium
        } else {
            bonusClock1.font.pixelSize = Theme.fontSizeLarge
            bonusClock2.font.pixelSize = Theme.fontSizeLarge
        }

        return
    }

    function showStats() {
        stats1.text = qsTr("total time") + " " + clockText(gameTime1) + ", " + moves1 + " " + qsTr("moves")
        stats2.text = qsTr("total time") + " " + clockText(gameTime2) + ", " + moves2 + " " + qsTr("moves")

        return
    }

    function startGame(player) {
        var startingTime = new Date().getTime()
        turnChangeHours = Math.floor(startingTime/hourMs)
        turnChangeMs = startingTime - turnChangeHours*hourMs

        if ((clockCounter1.running == false) && (clockCounter2.running == false) &&
                (time1 > 0) && (time2 > 0)) {
            clock1.text = clockText(time1)
            clock2.text = clockText(time2)
            if (player == 1) {
                player1turn = true
                clockCounter1.start()
            }
            else {
                player1turn = false
                clockCounter2.start()
            }

            clockFonts()

            play.enabled = false

        }

        gameRunning = true

        return
    }

    /*
    function storeSettings() {
        DataB.updateGameSet(gameSetupName, bonusType, time01/1000, bonus10, bonusTimes10,
                            time02/1000, bonus20, bonusTimes20)
        DataB.updateLayoutSet(boardLayoutName, colorActiveFont, colorActiveArea,
                              colorPassiveFont, colorPassiveArea, alarmFile, clangAtEnd)
        return
    }
    // */

    function updateClock1(dt) {
        var result

        gameTime1 += dt //timeStep

        result = updateGameTime(dt)

        if (result <= 0) {
            writeExtraTime()
            gameLost(1)

            gameOverTimer.start()
        } else {
            writeExtraTime()
            writeClock1()
        }

        return
        /*
        if (bonusType < 1.5) {
            time1 -= dt //timeStep
            result = time1
        } else if (bonusType < 2.5) {
            if (bonus1 > 0)
                bonus1 -= dt //timeStep
            else
                time1 -= dt //timeStep
            result = time1
        } else {
            time1 -= timeStep
            result = time1 + 0.2
            if (time1 < 0) {
                if (time1 > -1.5*dt) //timeStep
                    clockFonts()
                bonus1 -= dt //timeStep
                if (bonusType < 3.5)
                    result = byoyomi(dt)
                else
                    result = bonus1
            }

        }

        gameTime1 += dt //timeStep
        return result
        // */
    }

    function updateClock2(dt) {
        var result

        gameTime2 += dt //timeStep

        result = updateGameTime(dt)

        if (result <= 0) {
            writeExtraTime()
            gameLost(2)

            gameOverTimer.start()
        } else {
            writeExtraTime()
            writeClock2()
        }

        return
        /*
        if (bonusType < 1.5) {
            time2 -= dt //timeStep
            result = time2
        } else if (bonusType < 2.5) {
            if (bonus2 > 0)
                bonus2 -= dt //timeStep
            else
                time2 -= dt //timeStep
            result = time2
        } else {
            time2 -= dt //timeStep
            result = time2 + 0.2
            if (time2 < 0) {
                if (time2 > -1.5*dt) //timeStep
                    clockFonts()
                bonus2 -= dt //timeStep
                if (bonusType < 3.5)
                    result = byoyomi(dt)
                else
                    result = bonus2
            }

        }

        gameTime2 += dt //timeStep
        return result
        // */
    }

    function updateGameTime(dt) {
        var result = 0
        if (bonusType < 1.5) {
            if (player1turn) {
                time1 -= dt //timeStep
                result = time1
            }
            else {
                time2 -= dt
                result = time2
            }
        } else if (bonusType < 2.5) {
            if (player1turn) {
                if (bonus1 > 0)
                    bonus1 -= dt //timeStep
                else
                    time1 -= dt //timeStep
                result = time1
            } else {
                if (bonus2 > 0)
                    bonus2 -= dt //timeStep
                else
                    time2 -= dt //timeStep
                result = time2
            }

        } else {
            if (player1turn) {
                time1 -= timeStep
                result = time1 + 1.5*timeStep // avoids problems related to time = 0 & bonustimes > 0
                if (time1 < 0) {
                    if (time1 > -1.5*dt) // change fonts once during a game
                        clockFonts()
                    bonus1 -= dt //timeStep
                    if (bonusType < 3.5)
                        result = byoyomi(dt)
                    else
                        result = bonus1
                }
            } else {
                time2 -= timeStep
                result = time2 + 1.5*timeStep
                if (time2 < 0) {
                    if (time2 > -1.5*dt) //timeStep
                        clockFonts()
                    bonus2 -= dt //timeStep
                    if (bonusType < 3.5)
                        result = byoyomi(dt)
                    else
                        result = bonus2
                }
            }
        }

        return result
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

    Timer {
        id: clockCounter1
        interval: timeStep
        running: false
        repeat: true
        onTriggered: {
            if (player1turn) {
                updateClock1(timeStep)
                /*
                if (updateClock1(timeStep) <= 0) {
                    writeExtraTime()
                    gameLost(1)

                    gameOverTimer.start()
                } else {
                    writeExtraTime()
                    writeClock1()
                } // */
            }
        }
    }

    Timer {
        id: clockCounter2
        interval: timeStep
        running: false
        repeat: true
        onTriggered: {
            if (!player1turn) {
                updateClock2(timeStep)
                /*
                if (updateClock2(timeStep) <= 0) {
                    writeExtraTime()
                    gameLost(2)

                    gameOverTimer.start()
                } else {
                    writeExtraTime()
                    writeClock2()
                } // */
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
        height: isPortrait ? portraitHeight : portraitWidth //clockSize()
        width: isPortrait ? portraitWidth : portraitHeight
        x: 0
        y: 0

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

        Rectangle {
            anchors.fill: parent
            color: ( (player1turn && gameRunning) || timeEnded )? colorActiveArea : colorPassiveArea
        }

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
            color: clock1.color

        }

        Label {
            id: clock1
            //anchors.top: bonusClock1.bottom
            anchors.horizontalCenter: clockTile1.horizontalCenter
            y: 0.5*(clockTile1.height - height)

            text: writeClock1()
            color: ( (player1turn && gameRunning) || timeEnded )? colorActiveFont : colorPassiveFont

            font.pixelSize: 0.3*Math.min(portraitHeight,portraitWidth) //Theme.fontSizeExtraLarge
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
            //text: ""
            text: qsTr("total time") + " " + clockText(gameTime1) + ", " + moves1 + " " + qsTr("moves")
            rotation: (isPortrait) ? 180 : 0
            width: clockTile1.width
            horizontalAlignment: Text.AlignHCenter
            color: clock1.color
            visible: !(clockCounter1.running || clockCounter2.running)
        }

        MouseArea {
            id: clock1mouse
            anchors {
                fill: parent
                margins: Theme.paddingSmall
            }
            onClicked: {
                //console.log(" clicked " + tapToReset + " " + clockCounter.running + " " + gameOverTimer.running)

                if (tapToReset)
                    setUp()
                else {
                    //if (clockCounter.running) {
                    if (gameRunning) {
                        if (player1turn){
                            clockCounter2.start()
                            clockCounter1.stop()
                            changePlayer()
                        }
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
        x: (page.isPortrait) ? 0 : clockTile1.width
        y: (page.isPortrait) ? clockTile1.height : 0
        height: (page.isPortrait) ? midSectionSize : page.height
        width: (page.isPortrait) ? page.width : midSectionSize

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()
            }
        }

        Rectangle {
            id: sepa1
            x: (page.isPortrait) ? Theme.paddingLarge : 0// 0.1*page.width
            y: (page.isPortrait) ? 0 : Theme.paddingLarge
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
                if (!(clockCounter1.running || clockCounter2.running))
                    openSettingsDialog()

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()

            }
        }

        IconButton {
            id: endGame
            x: (isPortrait) ? settings.x + settings.width + Theme.paddingMedium: 0.5*(midSectionSize - width)
            y: (isPortrait) ? 0.5*(midSectionSize - height) : settings.y - height
            icon.source: "image://theme/icon-l-clear"
            onPressAndHold: {
                //Remorse.popupAction(page, qsTr("resetting clocks"), function() {
                    gameEnded()
                //})
            }

            enabled: !(clockCounter1.running || clockCounter2.running) //&& gameRunning
        }

        Label {
            id: playTime1
            text: clockText(time01) + ( time01 === time02 ? "" : " - " + clockText(time02))
            x: (isPortrait) ? endGame.x + endGame.width : 0.5*(midSectionSize-height)
            y: (isPortrait) ? 0.5*(midSectionSize-height) : pause.y + pause.height
            width: isPortrait ? pause.x - endGame.x - endGame.width : endGame.y - pause.y - pause.height
            rotation: isPortrait ? 0 : -90
            transform: Translate {
                x: (playTime1.rotation != 0) ? -0.5*(playTime1.width - playTime1.height) : 0
                y: (playTime1.rotation != 0) ? 0.5*(playTime1.width - playTime1.height) : 0
            }

            color: Theme.secondaryColor
            horizontalAlignment: TextInput.AlignHCenter
        }

        IconButton {
            id: pause
            x: (isPortrait) ? page.width - Theme.paddingLarge - play.width - width - Theme.paddingMedium : 0.5*(settingsTile.width - width)
            y: (isPortrait) ? 0.5*(settingsTile.height - height) : play.y + play.height + Theme.paddingMedium
            icon.source: "image://theme/icon-l-pause"
            onPressAndHold: {
                clockCounter1.stop()
                clockCounter2.stop()
                play.enabled = true

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()

                showStats()
            }

            enabled: (clockCounter1.running || clockCounter2.running)
        }

        IconButton {
            id: play
            x: (isPortrait) ? page.width - Theme.paddingLarge - width : 0.5*(settingsTile.width - width)
            y: (isPortrait) ? 0.5*(settingsTile.height - height) : Theme.paddingLarge

            icon.source: "image://theme/icon-l-play"
            onClicked: {
                if (!tapToReset) {
                    if (player1turn)
                        clockCounter1.start()
                    else
                        clockCounter2.start()
                    enabled = false
                    gameRunning = true
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
        height: isPortrait ? portraitHeight : portraitWidth
        width: isPortrait ? portraitWidth : portraitHeight
        x: (isPortrait) ? 0 : (settingsTile.x + midSectionSize)
        y: (isPortrait) ? (settingsTile.y + midSectionSize) : 0

        Rectangle {
            anchors.fill: parent
            color: ( (!player1turn && gameRunning) || timeEnded )? colorActiveArea : colorPassiveArea
        }

        Label {
            id: stats2
            anchors.top: clockTile2.top
            anchors.horizontalCenter: clockTile2.horizontalCenter
            //text: ""
            text: qsTr("total time") + " " + clockText(gameTime2) + ", " + moves2 + " " + qsTr("moves")
            width: clockTile2.width
            horizontalAlignment: Text.AlignHCenter
            color: clock2.color
            visible: !(clockCounter1.running || clockCounter2.running)
        }

        Label {
            id: clock2
            anchors.horizontalCenter: clockTile2.horizontalCenter
            y: 0.5*(clockTile2.height - height)
            text: writeClock2()
            color: ( (!player1turn && gameRunning) || timeEnded )? colorActiveFont : colorPassiveFont

            font.pixelSize: 0.3*Math.min(portraitHeight,portraitWidth)
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
            text: "" // "Extra time"
            color: clock2.color

            font.pixelSize: Theme.fontSizeMedium
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
                    //if (clockCounter.running) {
                    if (gameRunning) {
                        if (!player1turn){
                            clockCounter1.start()
                            clockCounter2.stop()
                            changePlayer()
                        }
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

    Item { // reacts to Ambience changes during game
        id: ambienceColors
        anchors.top: parent.top
        anchors.left: parent.left
        height: prClr.height
        width: parent.width

        Text {
            id: prClr
            anchors.top: parent.top
            anchors.left: parent.left
            text: ""
            color: Theme.primaryColor
            onColorChanged:{
                //console.log("=== priClr === " + color + ", " + Theme.primaryColor)
                refreshColors()
            }
        }

        Text {
            id: sdClr
            anchors.top: prClr.top
            anchors.left: prClr.right
            text: ""
            color: Theme.secondaryColor
            onColorChanged:{
                //console.log("=== 2ndClr === " + color + ", " + Theme.secondaryColor)
                refreshColors()
            }
        }

        Text {
            id: hlClr
            anchors.top: prClr.top
            anchors.left: sdClr.right
            text: ""
            color: Theme.highlightColor
            onColorChanged:{
                //console.log("=== hlClr === " + color + ", " + Theme.highlightColor)
                refreshColors()
            }
        }

        Text {
            id: shClr
            anchors.top: prClr.top
            anchors.left: hlClr.right
            text: ""
            color: Theme.secondaryHighlightColor
            onColorChanged:{
                //console.log("=== shClr === " + color + ", " + Theme.secondaryHighlightColor)
                refreshColors()
            }
        }

        Text {
            id: diClr
            anchors.top: prClr.top
            anchors.left: shClr.right
            text: ""
            color: Theme.highlightDimmerColor
            onColorChanged:{
                //console.log("=== diClr === " + color + ", " + Theme.highlightDimmerColor)
                refreshColors()
            }
        }

        Text {
            id: hbClr
            anchors.top: prClr.top
            anchors.left: diClr.right
            text: ""
            color: Theme.highlightBackgroundColor
            onColorChanged:{
                //console.log("=== hbClr === " + color + ", " + Theme.highlightBackgroundColor)
                refreshColors()
            }
        }

        Text {
            id: dpClr
            anchors.top: prClr.top
            anchors.left: hbClr.right
            text: ""
            color: Theme.darkPrimaryColor
            onColorChanged:{
                //console.log("=== dpClr === " + color + ", " + Theme.darkPrimaryColor)
                refreshColors()
            }
        }

        Text {
            id: dsClr
            anchors.top: prClr.top
            anchors.left: dpClr.right
            text: ""
            color: Theme.darkSecondaryColor
            onColorChanged:{
                //console.log("=== dsClr === " + color + ", " + Theme.darkSecondaryColor)
                refreshColors()
            }
        }

        Text {
            id: lpClr
            anchors.top: hbClr.top
            anchors.left: dsClr.right
            text: ""
            color: Theme.lightPrimaryColor
            onColorChanged:{
                //console.log("=== lpClr === " + color + ", " + Theme.lightPrimaryColor)
                refreshColors()
            }
        }

        Text {
            id: lsClr
            anchors.top: hbClr.top
            anchors.left: lpClr.right
            text: ""
            color: Theme.lightSecondaryColor
            onColorChanged:{
                //console.log("=== lsClr === " + color + ", " + Theme.lightSecondaryColor)
                refreshColors()
            }
        }

    }

    ScreenBlank { //prevents screen from locking and turning off
        id: unblankScreen
        enabled: clockCounter1.running || clockCounter2.running
    }

    Audio {
        id: alarm
        source: alarmFile        
    }

    Component.onCompleted: {
        //colorTheme()
        //console.log("Clocks completing")
        readDb()
        setUp()
    }

}
