.pragma library

function timeSystemTxt(system) {
    var txt = ""
    if (system === 1)
        txt = qsTr("increment (Fisher)")
    else if (system === 2)
        txt = qsTr("delay (Bronstein)")
    else if (system === 3)
        txt = qsTr("X s N times (byo-yomi)")
    else if (system === 4)
        txt = qsTr("X moves in N s (Canadian byo-yomi)")
    else
        txt = qsTr("total time")

    return txt
}

function timeSystemExtras(system, periods) {
    var txt = ""
    if (system === 1) {
        txt = qsTr("increment per move")
    } else if (system === 2) {
        txt = qsTr("delay per move")
    } else if (system === 3) {
        txt = qsTr("%1 times").arg(periods)
    } else if (system === 4) {
        txt = qsTr("time for %1 moves").arg(periods)
    } else {
        txt = qsTr("no extra time")
    }

    return txt

}
