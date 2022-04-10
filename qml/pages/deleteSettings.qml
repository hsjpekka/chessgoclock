import QtQuick 2.0
import Sailfish.Silica 1.0
import "../utils/database.js" as DataB
import "../utils/scripts.js" as Scripts

Page {
    id: page
    allowedOrientations: defaultAllowedOrientations //Orientation.All
    signal closing

    property alias activeTextColor: activeClockColor.color
    property alias activeBgColor: activeClockBox.color
    property alias passiveTextColor: passiveClockColor.color
    property alias passiveBgColor: passiveClockBox.color
    //property int timeSystem //0 - no extras, 1 - time increment, 2 - delay, 3 - byo-yomi, 4 - canadian byo-yomi
    property int gameNbr: -1
    property string gameName: ""
    property int layoutNbr: -1
    property string layoutName: ""
    property color transparent: "transparent"
    property bool equals: true

    property bool useSounds
    property alias soundFile: soundFileLabel.value

    function clearGameFields() {
        timeSystemLabel.value = ""
        gameTime1.value = ""
        bonusPeriods1Label.value = ""
        gameTime2.value = ""
        bonusPeriods2Label.value = ""

        return
    }

    function clearLayoutFields() {
        activeClockBox.color = transparent
        activeClockColor.color = Theme.secondaryHighlightColor
        passiveClockBox.color = transparent
        passiveClockColor.color = Theme.secondaryHighlightColor
        soundFileLabel.value = ""

        return
    }

    function deleteGame() {
        //var setNr = DataB.whichSet(DataB.gameDb, gameName)
        var setNr
        if (cbTimeSetups.currentItem == null) {
            if (comboGameList.count > 0) {
                setNr = comboGameList.get(0).nr
            } else
                setNr = 0
        } else
            setNr = cbTimeSetups.currentItem.number

        DataB.deleteGame(setNr)
        return
    }

    function deleteLayout() {
        var setNr = 0 //= DataB.whichSet(DataB.layoutDb, layoutName)
        if (cbStoredLayouts.currentItem == null) {
            if (comboLayoutList.count > 0) {
                setNr = comboLayoutList.get(0).nr
            } else
                setNr = 1
        } else
            setNr = cbStoredLayouts.currentItem.number

        DataB.deleteLayout(setNr)
        return
    }

    function readBoardSettings(setNr) {
        var dum
        //console.log("deleteSettings " + setNr)
        if( setNr < 0) {
            console.log("board setup " + setNr + " doesn't exist")
        } else {
            layoutName = DataB.readValue(DataB.layoutDb, setNr, DataB.keyName)
            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyActiveBg)
            if (dum === -1) {
                activeBgColor = Theme.primaryColor
                console.log("board setup " + setNr + " activeBgColor doesn't exist")
            } else {
                //console.log("deleteSettings: activeBg " + dum)
                activeBgColor = dum
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyActiveFont)
            if (dum === -1) {
                activeTextColor = Theme.primaryColor
                console.log("board setup " + setNr + " activeTextColor doesn't exist")
            } else {
                activeTextColor = dum
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyPassiveBg)
            if (dum === -1) {
                passiveBgColor = Theme.primaryColor
                console.log("board setup " + setNr + " passiveBgColor doesn't exist")
            } else {
                passiveBgColor = dum
            }

            dum = DataB.readValue(DataB.layoutDb, setNr, DataB.keyPassiveFont)
            if (dum === -1) {
                passiveTextColor = Theme.primaryColor
                console.log("board setup " + setNr + " passiveTextColor doesn't exist")
            } else {
                passiveTextColor = dum
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
        var timeSystem, time1, time2, h1, m1, s1, h2, m2, s2, dum
        var bonusT1, bonusP1, bonusT2, bonusP2

        if( setNr < 0) {
            console.log("game setup " + setNr + " doesn't exist")
        } else {
            gameName = DataB.readValue(DataB.gameDb, setNr, DataB.keyName)
            time1 = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl1Time)
            if (time1 < 0) {
                time1 = 0
                console.log("game setup " + setNr + " time1 doesn't exist")
            }
            h1 = Math.floor(time1/60/60)
            m1 = Math.floor((time1 - h1*60*60)/60)
            s1 = time1 - h1*60*60 - m1*60
            gameTime1.value = qsTr("%1 h %2 min %3 s").arg(h1).arg(m1).arg(s1)

            time2 = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl2Time)
            if (time2 < 0) {
                time2 = 0
                console.log("game setup " + setNr + " time2 doesn't exist")
            }
            h2 = Math.floor(time2/60/60)
            m2 = Math.floor((time2 - h2*60*60)/60)
            s2 = time2 - h2*60*60 - m2*60
            gameTime2.value = qsTr("%1 h %2 min %3 s").arg(h2).arg(m2).arg(s2)

            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyGame)
            timeSystem = (dum < 0) ? 0 : dum
            timeSystemLabel.value = Scripts.timeSystemTxt(timeSystem)

            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl1Nbr)
            bonusP1 = (dum < 0) ? 0 : dum
            bonusPeriods1Label.label = Scripts.timeSystemExtras(timeSystem, bonusP1)
            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl1Extra)
            bonusT1 = (dum < 0) ? 0 : dum
            bonusPeriods1Label.value = Math.floor(bonusT1/60) + " min " + (bonusT1 - Math.floor(bonusT1/60)*60) + " s"

            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl2Nbr)
            bonusP2 = (dum < 0) ? 0 : dum
            bonusPeriods2Label.label = Scripts.timeSystemExtras(timeSystem, bonusP2)
            dum = DataB.readValue(DataB.gameDb, setNr, DataB.keyPl2Extra)
            bonusT2 = (dum < 0) ? 0 : dum
            bonusPeriods2Label.value = Math.floor(bonusT2/60) + " min " + (bonusT2 - Math.floor(bonusT2/60)*60) + " s"

            if (time1 === time2 && bonusP1 === bonusP2 && bonusT1 === bonusT2)
                equals = true
            else
                equals = false

            //console.log("peli " + bonusType + ", ")
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
        comboGameList.clear()
        readStoredGameNames()
        cbTimeSetups.currentIndex = -1
    }

    function refreshComboLayout() {
        comboLayoutList.clear()
        readStoredLayoutNames()
        cbStoredLayouts.currentIndex = -1
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: page
        height: page.height
        contentHeight: column.height

        PullDownMenu {            
            MenuItem {
                text: qsTr("delete game setup %1").arg(gameName)
                onClicked: {
                    remorse.execute(qsTr("deleting %1").arg(gameName), function() {
                        deleteGame()
                        refreshComboGame()
                        clearGameFields()
                    })
                }
                enabled: (cbTimeSetups.currentIndex >= 0) ? true : false
            }
            MenuItem {
                text: qsTr("delete layout setup %1").arg(layoutName)
                onClicked: {
                    remorse.execute(qsTr("deleting %1").arg(layoutName), function() {
                        deleteLayout()
                        refreshComboLayout()
                    })
                }
                enabled: (cbStoredLayouts.currentIndex >= 0) ? true : false
            }
        }

        RemorsePopup {
            id: remorse
        }

        Column {
            id: column
            spacing: 0
            width: page.width

            PageHeader {
                title: qsTr("Delete setups") //qsTr("Player 1")
                //width: page.width
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
                width: parent.width
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
                        setNbr = currentItem.number
                        readClockSettings(setNbr)
                        //console.log("" + setNbr + " " + currentItem.text)
                    }

                }
            }

            DetailItem{
                id: timeSystemLabel
                label: qsTr("time system")
            }

            DetailItem{
                id: gameTime1
                label: equals ? qsTr("game time") : qsTr("game time, player %1").arg("1")
            }

            DetailItem {
                id: bonusPeriods1Label
            }

            DetailItem{
                id: gameTime2
                label: qsTr("game time, player %1").arg("2")
                visible: !equals
            }

            DetailItem {
                id: bonusPeriods2Label
                visible: !equals
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
                width: parent.width
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
                        setNbr = currentItem.number
                        readBoardSettings(setNbr)
                        //console.log("" + setNbr + " " + currentItem.text)
                    }

                    //console.log("" + currentItem.text)
                }
            }

            // active clock
            Item {
                id: activeClockRow
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: activeClockBox.height

                Rectangle {
                    id: activeClockBox
                    height: activeClockColor.height + 2*Theme.paddingMedium
                    width: activeClockColor.width + 2*Theme.paddingLarge
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: transparent
                    border.width: 1
                    border.color: (color === transparent) ? Theme.highlightColor : color
                    radius: Theme.paddingMedium
                }

                Label {
                    id: activeClockColor
                    text: (cbStoredLayouts.currentIndex < 0) ? "-- --" : "14:53"
                    color: Theme.secondaryHighlightColor
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

                Rectangle {
                    id: passiveClockBox
                    height: passiveClockColor.height + 2*Theme.paddingMedium
                    width: passiveClockColor.width + 2*Theme.paddingLarge
                    color: transparent
                    anchors.horizontalCenter: parent.horizontalCenter
                    border.width: 1
                    border.color: (color === transparent) ? Theme.highlightColor : color
                    radius: Theme.paddingMedium
                }

                Label {
                    id: passiveClockColor
                    text: (cbStoredLayouts.currentIndex < 0) ? "-- --" : "08:33"
                    color: Theme.secondaryHighlightColor
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
                id: soundFileLabel
                label: qsTr("sound file")
            }

        }

        VerticalScrollDecorator {}

    }

    Component.onCompleted: {
        refreshComboGame()
        refreshComboLayout()
        if (layoutNbr >= 0) {
            var i = 0
            while (i < comboLayoutList.count) {
                if (comboLayoutList.get(i).nr === layoutNbr) {
                    cbStoredLayouts.currentIndex = i
                    layoutName = comboLayoutList.get(i).menuText
                    i = comboLayoutList.count
                }
                i++
            }
            //readBoardSettings(layoutNbr)
        }
        if (gameNbr >= 0) {
            //readClockSettings(gameNbr)
            i = 0
            while (i < comboGameList.count) {
                if (comboGameList.get(i).nr === gameNbr) {
                    cbTimeSetups.currentIndex = i
                    gameName = comboGameList.get(i).menuText
                    i = comboGameList.count
                }
                i++
            }
        }

    }

    Component.onDestruction:
        closing()

}
