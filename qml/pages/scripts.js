function timeSystemTxt(number) {
    var txt = ""
    if (number === 1)
        txt = qsTr("time increment (Fisher)")
    else if (number === 2)
        txt = qsTr("time delay (Bronstein)")
    else if (number === 3)
        txt = qsTr("byo-yomi")
    else if (number === 4)
        txt = qsTr("canadian byo-yomi")
    else
        txt = qsTr("no extra time")

    return txt
}
