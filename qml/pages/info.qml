import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations //Orientation.All // screenOrientation

    property string version: "1.4"
    property bool totalTimeVisible: false
    property bool timeIncrementVisible: false
    property bool delayVisible: false
    property bool byoyomiVisible: false
    property bool canadianByoyomiVisible: false

    SilicaFlickable {
        anchors.fill: page
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            width: page.width

            PageHeader {
                title: qsTr("ChessGoClock")
            }

            Item {
                height: totalTimeButton.height
                width: page.width

                IconButton{
                    id: totalTimeButton
                    icon.source: totalTimeVisible? "image://theme/icon-m-down" : "image://theme/icon-m-right"
                    onClicked: {
                        totalTimeVisible = !totalTimeVisible
                    }

                }

                Label {
                    x: totalTimeButton.x + totalTimeButton.width + Theme.paddingMedium
                    anchors.verticalCenter: totalTimeButton.verticalCenter
                    text: qsTr("total time")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        totalTimeVisible = !totalTimeVisible
                    }
                }
            }

            TextArea {
                id: totalTimeText
                width: page.width
                visible: totalTimeVisible
                text: qsTr("no modifications to the available time")
                readOnly: true
            }

            Item {
                height: timeIncrementButton.height
                width: page.width

                IconButton{
                    id: timeIncrementButton
                    icon.source: timeIncrementVisible? "image://theme/icon-m-down" : "image://theme/icon-m-right"
                    onClicked: {
                        timeIncrementVisible = !timeIncrementVisible
                    }

                }

                Label {
                    x: timeIncrementButton.x + timeIncrementButton.width + Theme.paddingMedium
                    anchors.verticalCenter: timeIncrementButton.verticalCenter
                    text: qsTr("increment")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        timeIncrementVisible = !timeIncrementVisible
                    }
                }
            }

            TextArea {
                width: page.width
                visible: timeIncrementVisible
                text: qsTr("the available time increases after each move by the specified amount of time")
                readOnly: true
            }

            Item {
                height: delayButtom.height
                width: page.width

                IconButton{
                    id: delayButtom
                    icon.source: delayVisible? "image://theme/icon-m-down" : "image://theme/icon-m-right"
                    onClicked: {
                        delayVisible = !delayVisible
                    }

                }

                Label {
                    x: delayButtom.x + delayButtom.width + Theme.paddingMedium
                    anchors.verticalCenter: delayButtom.verticalCenter
                    text: qsTr("delay")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        delayVisible = !delayVisible
                    }
                }
            }

            TextArea {
                width: page.width
                visible: delayVisible
                text: qsTr("during each turn, the available time is counted down after the specified amount of time has passed")
                readOnly: true
            }

            Item {
                height: byoyomiButton.height
                width: page.width

                IconButton{
                    id: byoyomiButton
                    icon.source: byoyomiVisible? "image://theme/icon-m-down" : "image://theme/icon-m-right"
                    onClicked: {
                        byoyomiVisible = !byoyomiVisible
                    }

                }

                Label {
                    x: byoyomiButton.x + byoyomiButton.width + Theme.paddingMedium
                    anchors.verticalCenter: byoyomiButton.verticalCenter
                    text: "byo-yomi"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        byoyomiVisible = !byoyomiVisible
                    }
                }
            }

            TextArea {
                width: page.width
                visible: byoyomiVisible
                text: qsTr("After the main time has run out, the player has the given number of time periods. After each move, the number of full-time periods that the player took is subtracted. For example, if the player has three 30-second time periods and takes 30-59 seconds to make a move, the player loses one time period. With 60–89 seconds, the player loses two time periods, and so on. If the player takes less than 30 seconds, the timer resets without subtracting any periods. Using up the last period means that the player has lost.")
                readOnly: true
            }

            Item {
                height: canadianByoyomiButton.height
                width: page.width

                IconButton{
                    id: canadianByoyomiButton
                    icon.source: canadianByoyomiVisible? "image://theme/icon-m-down" : "image://theme/icon-m-right"
                    onClicked: {
                        canadianByoyomiVisible = !canadianByoyomiVisible
                    }

                }

                Label {
                    x: canadianByoyomiButton.x + canadianByoyomiButton.width + Theme.paddingMedium
                    anchors.verticalCenter: canadianByoyomiButton.verticalCenter
                    text: qsTr("Canadian byo-yomi")
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        canadianByoyomiVisible = !canadianByoyomiVisible
                    }
                }
            }

            TextArea {
                width: page.width
                visible: canadianByoyomiVisible
                text: qsTr("After the main time has run out, the player must make the given number of moves in the given time.")
                readOnly: true
            }

            Label {
                text: qsTr("version %1").arg(version)
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                x: 0.5*(page.width - width)
            }

        }
    }

}
