//.pragma library
var primaryColor = "Theme.primaryColor"
var secondaryColor = "Theme.secondaryColor"
var highlightColor = "Theme.highlightColor"
var secondaryHighlightColor = "Theme.secondaryHighlightColor"
var dimmerColor = "Theme.highlightDimmerColor"
var backgroundColor = "Theme.highlightBackgroundColor"
var darkPrimaryColor = "Theme.darkPrimaryColor"
var darkSecondaryColor = "Theme.darkSecondaryColor"
var lightPrimaryColor = "Theme.lightPrimaryColor"
var lightSecondaryColor = "Theme.lightSecondaryColor"

function isSameColor(clr1, clr2){
    var result = false, str1 = "" + clr1 + "", str2 = "" + clr2 + "", n

    n = str1.localeCompare(str2)
    if (n === 0)
        result = true

    //console.log("?? " + str1 + " = " + str2 + "? " + n )
    return result
}

function colorToAmbienceStr(clr) {
    var colour

    // for some colors clr == Theme.xxxColor does not work, but comparing strings works
    if (isSameColor(clr, Theme.primaryColor))//isSameColor(clr, themePrimary))
        colour = primaryColor
    else if (isSameColor(clr, Theme.secondaryColor))//isSameColor(clr, themeSecondary))
        colour = secondaryColor
    else if (isSameColor(clr, Theme.highlightDimmerColor))//isSameColor(clr, themeDimmer)) //if (clr === themeDimmer)
        colour = dimmerColor
    else if (isSameColor(clr, Theme.highlightColor))//isSameColor(clr, themeHigh)) //if (clr === themeHigh)
        colour = highlightColor
    else if (isSameColor(clr, Theme.secondaryHighlightColor))//isSameColor(clr, theme2ndHigh)) //if (clr === theme2ndHigh)
        colour = secondaryHighlightColor
    else if (isSameColor(clr, Theme.highlightBackgroundColor))//isSameColor(clr, themeBg)) //if (clr === themeBg)
        colour = backgroundColor
    else if (isSameColor(clr, Theme.darkPrimaryColor))//isSameColor(clr, themeDark)) //if (clr === themeDark)
        colour = darkPrimaryColor
    else if (isSameColor(clr, Theme.darkSecondaryColor))//isSameColor(clr, theme2ndDark)) //if (clr === theme2ndDark)
        colour = darkSecondaryColor
    else if (isSameColor(clr, Theme.lightPrimaryColor))//isSameColor(clr, themeLight)) //if (clr === themeLight)
        colour = lightPrimaryColor
    else if (isSameColor(clr, Theme.lightSecondaryColor))//isSameColor(clr, theme2ndLight)) //if (clr === theme2ndLight)
        colour = lightSecondaryColor
    else
        colour = clr

    //console.log("colour " + colour + " " + clr)
    return colour
}

function strToAmbienceColor(clr) {
    var colour

    if (clr === primaryColor)
        colour = Theme.primaryColor
    else if (clr === secondaryColor)
        colour = Theme.secondaryColor
    else if (clr === highlightColor)
        colour = Theme.highlightColor
    else if (clr === secondaryHighlightColor)
        colour = Theme.secondaryHighlightColor
    else if (clr === dimmerColor)
        colour = Theme.highlightDimmerColor
    else if (clr === backgroundColor)
        colour = Theme.highlightBackgroundColor
    else if (clr === darkPrimaryColor)
        colour = Theme.darkPrimaryColor
    else if (clr === darkSecondaryColor)
        colour = Theme.darkSecondaryColor
    else if (clr === lightPrimaryColor)
        colour = Theme.lightPrimaryColor
    else if (clr === lightSecondaryColor)
        colour = Theme.lightSecondaryColor
    else
        colour = clr

    //console.log("str: " + clr + ", color: " + colour)

    return colour
}

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
