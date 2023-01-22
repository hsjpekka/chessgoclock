import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: clockTile

    property color  bgInTurn: Theme.highlightColor
    property color  bgOutTurn: "transparent"
    property color  bgOver: bgInTurn
    property int    _bonusCount: 0 // counts down from bonusPeriods in systems 3 and 4
    property int    bonusPeriods: 0
    property int    bonusTime: 0 //ms
    property int    _bonusTimeLeft: 0 //ms, bonustime left in systems 2, 3 and 4
    property bool   byoyo: timeSystem > 2.5 && gameTimeLeft <= 0
    property bool   inTurn: false
    property int    moves: 0 // total number of moves
    property int    moveTime: 0 //ms, total time used for the current move
    property string player: "^*^"
    property bool   showPlayer: false
    property alias  running: timer.running
    property int    startHours
    property int    startMs
    property int    _time: 0 //ms, game time spent, <= timeMax
    property bool   timeEnded: false
    property int    timeMax: 0 //ms
    property int    timeSystem: 0
        // 0 - no bonus, 1 - +X s per move (Fischer), 2 - delay before counting (Bronstein),
        // 3 - after game time N x X extras (Byoyomi), 4 - N moves in X s (Canadian Byoyomi)
    property int    totalTime: 0 //ms, total used time
    property color  txtInTurn: Theme.highlightDimmerColor
    property color  txtOutTurn: Theme.highlightColor
    property color  txtOver: txtInTurn

    readonly property bool  atStart: true
    readonly property int   gameTimeLeft: timeMax - _time // ms
    readonly property int   hour: 60*60*1000

    signal clicked()
    signal lost()

    Timer {
        id: timer
        interval: gameTimeLeft > 1400 ? 250 : (_bonusTimeLeft > 1400 ? 250 : 50)
        running: false
        repeat: true
        onTriggered: {
            if (inTurn) {
                updateClock(interval)
            }
        }
    }

    Rectangle {// background
        anchors.fill: parent
        color: timeEnded? bgOver : (inTurn? bgInTurn : bgOutTurn)
    }

    Label {
        id: statsDisplay
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width

        color: timeDisplay.color
        visible: (moves > 0)

        text: qsTr("total time %1, %2 moves").arg(timeTxt).arg(moves)

        property string timeTxt: clockText(totalTime)
    }

    Label {
        id: timeDisplay
        anchors.centerIn: parent

        color: timeEnded? txtOver : (inTurn? txtInTurn : txtOutTurn)
        font.pixelSize: byoyo? Theme.fontSizeHuge*2 : 0.3*parent.height //Theme.fontSizeExtraLarge
        font.bold: byoyo || (timeSystem < 2.5 && gameTimeLeft < 10*1000 && running) || timeEnded
        style: timeEnded? Text.Outline : Text.Raised

        text: showPlayer? player : txt

        property string txt: "--:--"
    }

    Label {
        id: bonusDisplay
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: clockTile.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width

        color: timeDisplay.color
        font.bold: byoyo || (timeSystem === 2 && _bonusTimeLeft > 0 && running)
        font.pixelSize: byoyo? Theme.fontSizeHuge*1.5 : Theme.fontSizeLarge
        style: byoyo? Text.Raised : Text.Normal
        wrapMode: Text.Wrap

        text: "" // "extraTime"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            clockTile.clicked()
        }
    }

    function byoyomi() {
        // if the move takes longer than N*bonusTime, N bonus periods are expended
        // called every clock update
        var result; // if result < 0, game ends

        if (_bonusTimeLeft <= 0) {
            _bonusCount--;
            if (_bonusCount < bonusPeriods)
                _bonusTimeLeft += bonusTime;
        }
        result = _bonusCount - 1;

        return result;
    }

    function canadianByoyomi() {
        // if player has made bonusPeriods moves in bonusTime, a net bonus period set is gained
        // called at the end of a turn
        if ((gameTimeLeft <= 0) && (_bonusTimeLeft > 0) ) {
            _bonusCount--;
            if (_bonusCount <= 0 ) {
                _bonusCount = bonusPeriods;
                _bonusTimeLeft = bonusTime;
            }
        }
        return
    }

    function changePlayer(ms) {
        if (inTurn) {
            inTurn = false;
            stop(ms);
            checkBonus(!atStart);
            writeBonusTimes();            
            moves++;
            writeClock();
        } else {
            checkBonus(atStart);
            start(ms);
        }
        return;
    }

    function checkBonus(startOfTurn) {
        if (timeSystem === 1 && !startOfTurn)
            _time -= bonusTime
        else if (timeSystem === 2 && !startOfTurn)
            _bonusTimeLeft = bonusTime;
        else if (timeSystem === 3 && !startOfTurn)
            _bonusTimeLeft = bonusTime;
        else if (timeSystem === 4 && !startOfTurn)
            canadianByoyomi();
        return;
    }

    function clockText(ms) { //00:00:00, 00:00, or 0.0
        var result = "";
        var hours = Math.floor(ms/1000/60/60);
        var minutes = Math.floor((ms - hours*60*60*1000)/60/1000);
        var seconds = Math.floor((ms - hours*60*60*1000 - minutes*60*1000)/1000);

        if (ms < 0) {
            result = "00:00";
        } else if (ms < 1000) {
            result = "0." + Math.floor(ms/100);
        } else {
            if (hours > 0) {
                if (hours < 10)
                    result = "0";
                result += hours + ":";
            }

            if (minutes < 10) {
                result += "0";
            }
            result += minutes + ":";

            if (seconds < 10) {
                result += "0";
            }

            result += seconds;
        }

        return result;
    }

    function gameLost() {
        timer.stop();

        timeDisplay.txt = "-.-";
        statsDisplay.timeTxt = clockText(totalTime);

        lost();
        return
    }

    function setUp() {
        inTurn = false;
        moves = 0;
        moveTime = 0;
        _time = 0;
        timeEnded = false;
        timer.running = false;
        totalTime = 0;
        if (timeSystem < 1.5)
            _bonusTimeLeft = 0
        else
            _bonusTimeLeft = bonusTime;
        if (timeSystem > 2.5)
            _bonusCount = bonusPeriods;

        writeBonusTimes();
        writeClock();
        return;
    }

    function start(ms) {
        if (!timer.running) {
            inTurn = true;
            startHours = Math.floor(ms/hour);
            startMs = ms - startHours*hour;
            timer.start();
        }
        return;
    }

    function stop(ms) {
        var dt;
        if (timer.running) {
            timer.stop();
            dt = ms - (startHours*hour + startMs);
            updateClock(dt - moveTime);
            statsDisplay.timeTxt = clockText(totalTime);
            moveTime = 0;
        }
        return;
    }

    function updateClock(dt) {
        var result;

        moveTime += dt; //timeStep
        totalTime += dt;

        result = updateGameTime(dt);

        if (result < 0) { // lost with time
            writeBonusTimes();
            gameLost();
        } else {
            writeBonusTimes();
            writeClock();
        }

        return
    }

    function updateGameTime(dt) {
        var result = 0; //if result <= 0, game ends

        if (timeSystem <= 1) { // total time or time increment
            _time += dt;
            result = gameTimeLeft;
        } else if (timeSystem === 2) { // free time at start
            if (_bonusTimeLeft > 0) {
                _bonusTimeLeft -= dt;
                if (_bonusTimeLeft < 0) {
                    _time -= _bonusTimeLeft;
                }
            }
            else
                _time += dt;
            result = gameTimeLeft;
        } else { // byoyomi's after game time is over
            _time += dt;
            result = gameTimeLeft + 1; // in case _time === timeMax
            if (gameTimeLeft < 0) {
                if (gameTimeLeft >= -dt) {
                    _bonusTimeLeft -= -gameTimeLeft; // -dt <= gameTimeLeft < 0
                } else
                    _bonusTimeLeft -= dt;
                if (timeSystem === 3)
                    result = byoyomi()
                else if (timeSystem === 4)
                    result = _bonusTimeLeft;
            }
        }

        return result;
    }

    function writeBonusTimes() {
        var txt = "";

        if (timeSystem === 0) {
            txt = qsTr("total time")
        } else if (timeSystem === 1) {
            txt = qsTr("increment") + " " + (bonusTime/1000).toFixed(0) + " s ";
        } else if (timeSystem === 2) {
            txt = qsTr("delay") + " " + (_bonusTimeLeft/1000).toFixed(0) + " s ";
        } else if (timeSystem === 3) {
            txt = clockText(_bonusTimeLeft) + " (" + _bonusCount + "/" + bonusPeriods + ")";
        } else if (timeSystem === 4) {
            txt = _bonusCount + " @ "  + clockText(_bonusTimeLeft);
        }

        bonusDisplay.text = txt;

        return txt;
    }

    function writeClock() {
        var txt = clockText(gameTimeLeft);
        timeDisplay.txt = txt;

        return txt;
    }
}
