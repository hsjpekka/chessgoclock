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

import "../components"
import "../utils/database.js" as DataB
import "../utils/scripts.js" as Scripts

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations

    property string alarmFile: "/usr/share/sounds/jolla-ambient/stereo/positive_confirmation.wav"
    property string boardLayoutName: ""
    property bool   clangAtEnd: true
    property string clrStrAArea: "transparent"
    property string clrStrATxt: Scripts.highlightColor
    property string clrStrPArea: "transparent"
    property string clrStrPTxt: Scripts.secondaryHighlightColor
    property color  colorActiveArea: "transparent"
    property color  colorActiveFont: Theme.highlightColor
    property color  colorPassiveArea: "transparent"
    property color  colorPassiveFont: Theme.secondaryHighlightColor
    property bool   gameOn: player1.running || player2.running
    property int    gameOverWaitTime: 5*1000
    property bool   gameOver: false
    property string gameSetupName: ""
    property string stateWhenLandscape: stateHorizontal
    property string stateWhenPortrait: stateVertical
    property bool   tapToReset: false

    readonly property var orientationsAllowed: defaultAllowedOrientations
    readonly property string stateHorizontal: "horizontal"
    readonly property string stateVertical: "vertical"

    Component.onCompleted: {
        readDb()
        setupBoard()
    }

    Timer {
        id: gameOverTimer
        interval: gameOverWaitTime
        running: false
        repeat: false
        onTriggered: {
            tapToReset = true
            player1.enabled = true
            player2.enabled = true            
        }
    }

    ClockView {
        id: player1
        bgInTurn: colorActiveArea
        bgOutTurn: colorPassiveArea
        player: "_1_"
        rotation: 180
        timeSystem: 0
        timeMax: 10*60*1000 // ms
        txtInTurn: colorActiveFont
        txtOutTurn: colorPassiveFont

        state: isPortrait ? stateWhenPortrait : stateWhenLandscape
        states: [
            State {
                name: stateHorizontal

                AnchorChanges {
                    target: player1
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: settingsTile.right
                        right: parent.right
                    }
                }

                PropertyChanges {
                    target: player1
                    rotation: 0
                }
            },

            State {
                name: stateVertical

                AnchorChanges {
                    target: player1
                    anchors {
                        top: parent.top
                        bottom: settingsTile.top
                        left: parent.left
                        right: parent.right
                    }
                }

                PropertyChanges {
                    target: player1
                    rotation: 180
                }
            }
        ]

        onClicked: {
            if (tapToReset) {
                setupBoard()
            } else {
                if (player1.totalTime === 0 && player2.totalTime === 0) { // don't rotate the clock during game
                    fixClockOrientation(true);
                }
                changeToPlayer(2)
            }
            /*
            if (tapToReset)
                resetBoard()
            else {
                var now = new Date().getTime()
                if (gameOn) {
                    if (inTurn){
                        player1.changePlayer(now)
                        if (!gameOver)
                            player2.changePlayer(now)
                    }
                } else {
                    if (!gameOverTimer.running) { // continue after a pause
                        player2.start(now)
                    }
                }
            }

            if (clangAtEnd && gameOverTimer.running)
                alarm.stop()
            // */
        }

        onLost: {
            outOfTime();
            /*
            gameOver = true
            player1.enabled = false
            player2.enabled = false
            player1.timeEnded = true
            player2.timeEnded = true
            gameOverTimer.start()
            if (clangAtEnd)
                alarm.play()
            // */
        }
    }

    Item {
        id: settingsTile
        anchors.centerIn: parent
        height: isPortrait? resetGame.height + 2*space : page.height
        width: isPortrait? page.width : resetGame.height + 2*space

        property int space: gameOver? Theme.paddingLarge : Theme.paddingMedium

        Rectangle { // background
            anchors.fill: parent
            color: "black"
            opacity: 0.2
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()
            }
        }

        IconButton {
            id: resetGame
            x: isPortrait? 0.25*parent.width - 0.5*width : 0.5*(parent.width - width)
            y: isPortrait? 0.5*(parent.height - height) : 0.75*parent.height - 0.5*height
            icon.source: "image://theme/icon-m-refresh"
            icon.height: (gameOn || (player1.totalTime === 0 && player2.totalTime === 0))? Theme.iconSizeLarge : Theme.iconSizeExtraLarge
            icon.width: icon.height
            onClicked: {
                if (!gameOn) {
                    resetBoard()
                }
            }

            onPressAndHold: {
                resetBoard()
            }

            enabled: !player1.running && !player2.running

            function resetBoard() {
                player1.enabled = false;
                player2.enabled = false;
                remorse.execute(qsTr("Resetting the clocks"), function () {
                    setupBoard();
                    player1.enabled = true;
                    player2.enabled = true;
                });
                return;
            }
        }

        IconButton {
            id: settings
            icon.source: "image://theme/icon-m-developer-mode"
            anchors.centerIn: parent

            onClicked: {
                if (!player1.running && !player2.running)
                    openSettingsDialog()

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()
            }
            onPressAndHold: {
                player1.showPlayer = true
                player2.showPlayer = true
            }
            onReleased: {
                player1.showPlayer = false
                player2.showPlayer = false
            }
        }

        IconButton {
            id: pause
            x: isPortrait? 0.75*parent.width - 0.5*width : 0.5*(parent.width - width)
            y: isPortrait? 0.5*(parent.height - height) : 0.25*parent.height - 0.5*height
            icon.source: "image://theme/icon-l-pause"
            onPressAndHold: {
                var ms = new Date().getTime()
                player1.stop(ms)
                player2.stop(ms)

                if (clangAtEnd && gameOverTimer.running)
                    alarm.stop()
            }

            enabled: player1.running || player2.running
        }
    }

    ClockView {
        id: player2
        bgInTurn: colorActiveArea
        bgOutTurn: colorPassiveArea
        player: "_2_"
        rotation: 0
        timeSystem: player1.timeSystem
        timeMax: player1.timeMax
        txtInTurn: colorActiveFont
        txtOutTurn: colorPassiveFont

        state: isPortrait ? stateWhenPortrait : stateWhenLandscape
        //state:  ? "vertical" : "horizontal"
        states: [
            State {
                name: stateHorizontal
                //name: "horizontal"

                AnchorChanges {
                    target: player2
                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: settingsTile.left
                    }
                }

                PropertyChanges {
                    target: player2
                    rotation: 0
                }
            },

            State {
                name: stateVertical
                //name: "vertical"

                AnchorChanges {
                    target: player2
                    anchors {
                        top: settingsTile.bottom
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                }

                PropertyChanges {
                    target: player2
                    rotation: 0
                }
            }
        ]

        onClicked: {
            if (tapToReset) {
                setupBoard()
            } else {
                if (player1.totalTime === 0 && player2.totalTime === 0) { // don't rotate the clock during game
                    fixClockOrientation(true);
                }
                changeToPlayer(1);
            }
            /*
            else {
                var now = new Date().getTime()
                if (gameOn) {
                    if (inTurn){
                        player2.changePlayer(now)
                        if (!gameOver)
                            player1.changePlayer(now)
                    }
                } else {
                    if (!gameOverTimer.running) { // continue after a pause
                        player1.start(now)
                    }
                }
            }

            if (clangAtEnd && gameOverTimer.running)
                alarm.stop()
            // */
        }

        onLost: {
            outOfTime();
            /*
            gameOver = true
            player2.enabled = false
            player1.enabled = false
            player1.timeEnded = true
            player2.timeEnded = true
            gameOverTimer.start()
            if (clangAtEnd)
                alarm.play()
            // */
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
        enabled: gameOn
    }

    Audio {
        id: alarm
        source: alarmFile
    }

    RemorsePopup {
        id: remorse
        onCanceled: {
            player1.enabled = true;
            player2.enabled = true;
        }
    }

    function changeToPlayer(next) {
        var current, now, opponent;
        now = new Date().getTime();

        if (next === 2) {
            current = player1;
            opponent = player2;
        } else {
            current = player2;
            opponent = player1;
        }
        if (gameOn) {
            if (current.inTurn){
                current.changePlayer(now);
                if (!gameOver)
                    opponent.changePlayer(now);
            }
        } else {
            if (!gameOverTimer.running && !current.inTurn) { // continue after a pause
                opponent.start(now);
            }
        }

        if (clangAtEnd && gameOverTimer.running)
            alarm.stop();

        return;
    }

    function fixClockOrientation(fixOrientation) {
        if (fixOrientation) {
            page.allowedOrientations = page.orientation
            /*
            if (page.orientation === Orientation.PortraitMask) {
                stateWhenLandscape = stateVertical;
                stateWhenPortrait = stateVertical;
            } else {
                stateWhenLandscape = stateHorizontal;
                stateWhenPortrait = stateHorizontal;
            } // */
        } else {
            page.allowedOrientations = page.orientationsAllowed
            /*
            stateWhenLandscape = stateHorizontal;
            stateWhenPortrait = stateVertical;
            // */
        } // */
        return;
    }

    function outOfTime() {
        gameOver = true;
        player1.enabled = false;
        player2.enabled = false;
        player1.timeEnded = true;
        player2.timeEnded = true;
        gameOverTimer.start();
        if (clangAtEnd)
            alarm.play();
        return;
    }

    function openSettingsDialog() {
        var hours1, minutes1, seconds1, hours2, minutes2, seconds2;
        var sec = 1000, min = 60*sec, h = 60*min;

        hours1 = Math.floor(player1.timeMax/h);
        minutes1 = Math.floor((player1.timeMax-hours1*h)/min);
        seconds1 = Math.floor((player1.timeMax-hours1*h-minutes1*min)/sec);

        hours2 = Math.floor(player2.timeMax/h);
        minutes2 = Math.floor((player2.timeMax-hours2*h)/min);
        seconds2 = Math.floor((player2.timeMax-hours2*h-minutes2*min)/sec);

        var dialog = pageStack.push(Qt.resolvedUrl("TimeSettings.qml"), {
                                    "hoursPlayer1": hours1, "minsPlayer1": minutes1,
                                    "secsPlayer1": seconds1, "bonusT1": player1.bonusTime/1000,
                                    "bonusPeriods1": player1.bonusPeriods,
                                    "hoursPlayer2": hours2, "minsPlayer2": minutes2,
                                    "secsPlayer2": seconds2, "bonusT2": player2.bonusTime/1000,
                                    "bonusPeriods2": player1.bonusPeriods,
                                    "timeSystem": player1.timeSystem, "useSounds": clangAtEnd,
                                    "soundFile": alarmFile,
                                    "activeTextColor": colorActiveFont,
                                    "activeBgColor": colorActiveArea,
                                    "passiveTextColor": colorPassiveFont,
                                    "passiveBgColor": colorPassiveArea,
                                    "layoutName": boardLayoutName,
                                    "gameSetupName": gameSetupName
                     });

        dialog.accepted.connect(function() {
            var sec = 1000;
            gameSetupName = dialog.gameSetupName;

            player1.timeSystem = dialog.timeSystem;
            hours1 = dialog.hoursPlayer1;
            minutes1 = dialog.minsPlayer1;
            seconds1 = dialog.secsPlayer1;
            player1.timeMax = ((hours1*60 + minutes1)*60 + seconds1)*sec;
            player1.bonusTime = dialog.bonusT1*sec;
            player1.bonusPeriods = dialog.bonusPeriods1;

            player2.timeSystem = dialog.timeSystem;
            hours2 = dialog.hoursPlayer2;
            minutes2 = dialog.minsPlayer2;
            seconds2 = dialog.secsPlayer2;
            player2.timeMax = ((hours2*60 + minutes2)*60 + seconds2)*sec;
            player2.bonusTime = dialog.bonusT2*sec;
            player2.bonusPeriods = dialog.bonusPeriods2;

            boardLayoutName = dialog.layoutName;
            clangAtEnd = dialog.useSounds;
            alarmFile = dialog.soundFile;

            setColors(dialog.activeBgColor, dialog.activeTextColor, dialog.passiveBgColor, dialog.passiveTextColor);

            setupBoard();

            return;
        });

        return;
    }

    function readBoardSettings(setupNr) {
        var dum;
        DataB.createTable(DataB.layoutDb);

        if (DataB.readTable(DataB.layoutDb) === 0) {
            console.log("layoutDb 0 rows");
            DataB.newLayoutSet(0, DataB.lastUsed, colorActiveFont, colorActiveArea,
                             colorPassiveFont, colorPassiveArea, alarmFile, clangAtEnd);
        } else {
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyActiveBg);
            clrStrAArea = dum;
            colorActiveArea = Scripts.strToAmbienceColor(dum);
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyActiveFont);
            clrStrATxt = dum;
            colorActiveFont = Scripts.strToAmbienceColor(dum);
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyPassiveBg);
            clrStrPArea = dum;
            colorPassiveArea = Scripts.strToAmbienceColor(dum);
            dum = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyPassiveFont);
            clrStrPTxt = dum;
            colorPassiveFont = Scripts.strToAmbienceColor(dum);
            alarmFile = DataB.readValue(DataB.layoutDb, setupNr, DataB.keySound);
            clangAtEnd = DataB.readValue(DataB.layoutDb, setupNr, DataB.keyUseSound);
        }

        return
    }

    function readClockSettings(setupNr) {
        var second = 1000;
        DataB.createTable(DataB.gameDb);
        if (DataB.readTable(DataB.gameDb) === 0) {
            // alusta taulukko
            console.log("gameDb 0 rows");
            DataB.newGameSet(0, DataB.lastUsed, player1.timeSystem,
                             player1.timeMax, player1.bonusTime, player1.bonusPeriods,
                             player2.timeMax, player2.bonusTime, player2.bonusPeriods);
        } else {
            player1.timeMax = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl1Time)*second;
            player2.timeMax = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl2Time)*second;
            player1.timeSystem = DataB.readValue(DataB.gameDb, setupNr, DataB.keyGame);
            player2.timeSystem = player1.timeSystem;
            if (player1.timeSystem > 0.5) {
                player1.bonusTime = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl1Extra)*second;
                player2.bonusTime = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl2Extra)*second;
                player1.bonusPeriods = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl1Nbr);
                player2.bonusPeriods = DataB.readValue(DataB.gameDb, setupNr, DataB.keyPl2Nbr);
            }
        }

        return
    }

    function readDb() {
        DataB.openDb(LocalStorage);

        readBoardSettings(0);
        readClockSettings(0);

        return;
    }

    function refreshColors() {
        colorActiveArea = Scripts.strToAmbienceColor(clrStrAArea);
        colorActiveFont = Scripts.strToAmbienceColor(clrStrATxt);
        colorPassiveArea = Scripts.strToAmbienceColor(clrStrPArea);
        colorPassiveFont = Scripts.strToAmbienceColor(clrStrPTxt);
        return;
    }

    function setColors(actBg, actTxt, pasBg, pasTxt) {
        colorActiveFont = actTxt;
        colorActiveArea = actBg;
        colorPassiveFont = pasTxt;
        colorPassiveArea = pasBg;

        clrStrAArea = Scripts.colorToAmbienceStr(actBg);
        clrStrATxt = Scripts.colorToAmbienceStr(actTxt);
        clrStrPArea = Scripts.colorToAmbienceStr(pasBg);
        clrStrPTxt = Scripts.colorToAmbienceStr(pasTxt);
        return;
    }

    function setupBoard() {
        alarm.stop();
        tapToReset = false;
        gameOver = false;
        player1.setUp();
        player2.setUp();
        fixClockOrientation(false);
        return;
    }
}
