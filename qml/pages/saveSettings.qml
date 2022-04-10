import QtQuick 2.0
import Sailfish.Silica 1.0
import "../utils/database.js" as DataB
import "../utils/scripts.js" as Scripts

Dialog {
    id: page
    allowedOrientations: defaultAllowedOrientations //Orientation.All
    canAccept: (gameName == "" && layoutName == "") ? false : true

    property alias activeTextColor: activeClockColor.color
    property alias activeBgColor: activeClockBox.color
    property alias passiveTextColor: passiveClockColor.color
    property alias passiveBgColor: passiveClockBox.color
    property color transparent: "transparent"
    property int timeSystem //0 - no extras, 1 - time increment, 2 - delay, 3 - byo-yomi, 4 - canadian byo-yomi
    property alias gameName: gameNameTxt.text
    property alias layoutName: layoutNameTxt.text
    property int hours1
    property int mins1
    property int secs1
    property int hours2
    property int mins2
    property int secs2

    property bool equals

    property int bonusT1
    property int bonusT2

    property int bonusPeriods1
    property int bonusPeriods2

    property bool useSounds
    property alias soundFile: soundFileLabel.value

    property bool modifyName: false
    property int gameNbr
    property int layoutNbr

    SilicaFlickable {
        id: flickable
        anchors.fill: page
        height: page.height
        contentHeight: column.height

        Column {
            id: column
            spacing: 0

            DialogHeader {
                title: qsTr("Save settings") //qsTr("Player 1")
                width: page.width
            }

            ComboBox {
                id: actionSelector
                label: qsTr("action")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("save as")
                    }
                    MenuItem {
                        text: qsTr("modify name")
                    }
                }
                onCurrentIndexChanged: {
                    if (currentIndex === 0)
                        modifyName = false
                    else if (currentIndex === 1)
                        modifyName = true

                }
            }

            Row {
                x: Theme.horizontalPageMargin

                Text {
                    id: comboWidth
                    text: actionSelector.label
                    color: transparent
                }

                Label {
                    text: qsTr("Clear the name-field to avoid creating a new setting.")
                    color: Theme.highlightColor
                    width: page.width - comboWidth.width - 2*Theme.horizontalPageMargin
                    visible: !modifyName //&& ((gameNameTxt.text != "") || (layoutNameTxt.text != ""))
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                }
            }

            Row {
                TextField {
                    id: gameNameTxt
                    width: page.width - clearGameName.width - Theme.horizontalPageMargin
                    label: qsTr("game name")
                    placeholderText: qsTr("game setup name")
                }

                IconButton {
                    id: clearGameName
                    icon.source: "image://theme/icon-m-clear"
                    height: Theme.fontSizeExtraLarge
                    width: height
                    onClicked: gameNameTxt.text = ""
                }

            }

            DetailItem{
                id: timeSystemLabel
                label: qsTr("time system")                
            }

            DetailItem{
                label: equals ? qsTr("game time") : qsTr("game time, player %1").arg("1")
                value: qsTr("%1 h %2 min %3 s").arg(hours1).arg(mins1).arg(secs1)
            }

            DetailItem {
                id: bonusPeriods1Label
            }

            DetailItem{
                label: qsTr("game time, player %1").arg("2")
                value: qsTr("%1 h %2 min %3 s").arg(hours2).arg(mins2).arg(secs2)
                visible: !equals
            }

            DetailItem {
                id: bonusPeriods2Label
                visible: !equals
            }

            Row {

                TextField {
                    id: layoutNameTxt
                    width: page.width - clearLayoutName.width - Theme.horizontalPageMargin
                    label: qsTr("layout name")
                    placeholderText: qsTr("layout name")
                }

                IconButton {
                    id: clearLayoutName
                    icon.source: "image://theme/icon-m-clear"
                    height: Theme.fontSizeExtraLarge
                    width: height
                    onClicked: layoutNameTxt.text = ""
                }
            }

            // active clock
            Item {
                id: activeClockRow
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: activeClockBox.height

                Label {
                    text: qsTr("in turn")
                    color: Theme.secondaryHighlightColor
                    anchors {
                        right: parent.horizontalCenter
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id: activeClockBox
                    height: activeClockColor.height + 2*Theme.paddingMedium
                    width: activeClockColor.width + 2*Theme.paddingLarge
                    anchors {
                        left: parent.horizontalCenter
                        leftMargin: Theme.paddingMedium
                    }

                    border.width: 1
                    border.color: (color === transparent) ? Theme.highlightColor : color
                    radius: Theme.paddingMedium
                }

                Label {
                    id: activeClockColor
                    text: "20:14"
                    font.pixelSize: Theme.fontSizeExtraLarge
                    anchors.horizontalCenter: activeClockBox.horizontalCenter
                    anchors.verticalCenter: activeClockBox.verticalCenter
                }
            }

            // passive clock font color
            Item {
                id: passiveClockRow
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: passiveClockBox.height

                Label {
                    text: qsTr("out of turn")
                    color: Theme.secondaryHighlightColor
                    anchors {
                        right: parent.horizontalCenter
                        rightMargin: Theme.paddingMedium
                        verticalCenter: parent.verticalCenter
                    }
                }

                Rectangle {
                    id: passiveClockBox
                    height: passiveClockColor.height + 2*Theme.paddingMedium
                    width: passiveClockColor.width + 2*Theme.paddingLarge
                    anchors.left: parent.horizontalCenter
                    anchors.leftMargin: Theme.paddingMedium
                    border.width: 1
                    border.color: (color === transparent) ? Theme.highlightColor : color
                    radius: Theme.paddingMedium
                }

                Label {
                    id: passiveClockColor
                    text: "19:27"
                    font.pixelSize: Theme.fontSizeExtraLarge
                    anchors.horizontalCenter: passiveClockBox.horizontalCenter
                    anchors.verticalCenter: passiveClockBox.verticalCenter
                }
            }

            DetailItem {
                label: qsTr("clang when game ends")
                value: useSounds
            }

            DetailItem {
                id:soundFileLabel
                label: qsTr("sound file")
            }

        }

        VerticalScrollDecorator {}

    }

    Component.onCompleted: {
        if (gameName === DataB.lastUsed)
            gameName = ""
        if (layoutName === DataB.lastUsed)
            layoutName = ""
        else if (layoutName == "")
            layoutName = gameName
        gameNbr = DataB.whichSet(DataB.gameDb, gameName)
        layoutNbr = DataB.whichSet(DataB.layoutDb, layoutName)
        equals = ((hours1*60 + mins1)*60 + secs1 === (hours2*60 + mins2)*60 + secs2) && (bonusT1 === bonusT2)

        timeSystemLabel.value = Scripts.timeSystemTxt(timeSystem)

        if (bonusT1 > 60)
            bonusPeriods1Label.value = Math.floor(bonusT1/60) + " min " + (bonusT1 - Math.floor(bonusT1/60)*60) + " s"
        else
            bonusPeriods1Label.value = bonusT1 + " s"

        if (bonusT2 > 60)
            bonusPeriods2Label.value = Math.floor(bonusT2/60) + " min " + (bonusT2 - Math.floor(bonusT2/60)*60) + " s"
        else
            bonusPeriods2Label.value = bonusT2 + " s"

        bonusPeriods1Label.label = Scripts.timeSystemExtras(timeSystem, bonusPeriods1)
        bonusPeriods2Label.label = Scripts.timeSystemExtras(timeSystem, bonusPeriods2)
        if (timeSystem === 0) {
            bonusPeriods1Label.value = ""
            bonusPeriods2Label.value = ""
        }

        /*
        if (timeSystem === 1) {
            bonusPeriods1Label.label = qsTr("increment after each move")
        } else if (timeSystem === 2) {
            bonusPeriods1Label.label = qsTr("time counting delay")
        } else if (timeSystem === 3) {
            bonusPeriods1Label.label = qsTr("%1 times").arg(bonusPeriods1)
        } else if (timeSystem === 4) {
            bonusPeriods1Label.label = qsTr("time for %1 moves").arg(bonusPeriods1)
        } else {
            bonusPeriods1Label.label = qsTr("no extra time")
            bonusPeriods1Label.value = ""
        }
        bonusPeriods2Label.label = bonusPeriods1Label.label
        // */

    }

    onAccepted: {
        var t1 = hours1*60*60 + mins1*60 + secs1, t2 = hours2*60*60 + mins2*60 + secs2
        if (gameName === DataB.lastUsed)
            gameName = gameName + "_2"
        if (layoutName === DataB.lastUsed)
            layoutName = layoutName + "_2"
        if (modifyName) {
            if (gameName != "")
                DataB.updateGameSet(gameNbr, gameName, timeSystem, t1, bonusT1, bonusPeriods1,
                                    t2, bonusT2, bonusPeriods2)
            if (layoutName != "")
                DataB.updateLayoutSet(layoutNbr, layoutName, activeTextColor, activeBgColor,
                                      passiveTextColor, passiveBgColor, soundFile, useSounds)
            console.log("modified")
        } else
            console.log("save new/as")
    }
}
