.pragma library

var db = null, gameDb = "gameSettings", layoutDb = "layoutSettings" //, keySetNbr = "setNbr"
var gameSettings = [], layoutSettings = []
var lastUsed = "previous", lastUsedNr = 0 // default settings group
var keyName = "setName", keyGame = "bonusType", keyPl1Time = "time1", keyPl2Time = "time2",
        keyPl1Extra = "extra1", keyPl2Extra = "extra2", keyPl1Nbr = "nbr1",
        keyPl2Nbr = "nbr2"
var keyActiveFont = "activeFont", keyActiveBg = "activeBg",
        keyPassiveFont = "passiveFont", keyPassiveBg = "passiveBg", keySound = "soundFile",
        keyUseSound = "useSound"
var setRowFirst, setRowLast
// tables:
// gameSettings & layoutSettings
//   setNbr - int
//   key - (name, game, time1, time2, extra1, extra2, nbr1, nbr2, ...)
//   value - numeric (time1&2, extra1&2 seconds; game, nbr1&2 int; setName string)

// tbl = gameDb || layoutDb
function addValueToList(tbl, set, keyword, value){
    var newSet = {"setNbr": set, "key": keyword, "value": value }

    //console.log(" add to list " + set + " " + keyword + " " + value)

    if (tbl === gameDb) {
        gameSettings.push(newSet)
    } else if (tbl === layoutDb) {
        layoutSettings.push(newSet)
    }

    return tbl.length
}

function createTable (tbl) {

    if(db === null) return;

    try {
        db.transaction(function(tx){
            tx.executeSql("CREATE TABLE IF NOT EXISTS " + tbl +
                          " (setNbr INTEGER, key TEXT, value NUMERIC)");
        });
    } catch (err) {
        console.log("Error creating " + tbl + "-table in database: " + err);
    };

    return
}

function deleteGame(setNr) {
    var ir = gameSettings.length - 1
    //console.log(" - - " + JSON.stringify(gameSettings))
    //console.log(" games " + gameSettings.length)
    while (ir >= 0) {
        if (gameSettings[ir].setNbr === setNr)
            gameSettings.splice(ir, 1)
        ir--
    }
    console.log(" games " + gameSettings.length)

    removeFromTable(gameDb, setNr)

    //console.log(" - - " + JSON.stringify(gameSettings))
    return gameSettings.length
}

function deleteLayout(setNr) {
    var ir = layoutSettings.length - 1
    //console.log(" - - " + JSON.stringify(layoutSettings))
    //console.log(" layouts " + layoutSettings.length)
    while (ir >= 0) {
        if (layoutSettings[ir].setNbr === setNr)
            layoutSettings.splice(ir, 1)
        ir--
    }
    console.log(" layouts " + layoutSettings.length)

    removeFromTable(layoutDb, setNr)

    //console.log(" - - " + JSON.stringify(layoutSettings))
    return layoutSettings.length
}

function doubleQuotes(mj) {
    var dum = "" + mj + ""
    //doubles characters ' and "
    dum = dum.replace(/'/g,"''")
    dum = dum.replace(/"/g,'""')

    return dum
}

function lastSet(tbl) {
    var N, nr = -1

    if (tbl === gameDb) {
        N = gameSettings.rows.length
        if (N > 0)
            nr = gameSettings.rows[N-1].setNbr
        else
            nr = -1
    }
    else if (tbl === layoutDb) {
        N = layoutSettings.rows.length
        if (N > 0)
            nr = layoutSettings.rows[N-1].setNbr
        else
            nr = -1
    }

    return nr
}

function newGameSet(n, name, gameType, time1, extra1, nr1, time2, extra2, nr2) {

    newValue(gameDb, n, keyName, name)
    newValue(gameDb, n, keyGame, gameType)
    newValue(gameDb, n, keyPl1Time, time1)
    newValue(gameDb, n, keyPl1Extra, extra1)
    newValue(gameDb, n, keyPl1Nbr, nr1)
    newValue(gameDb, n, keyPl2Time, time2)
    newValue(gameDb, n, keyPl2Extra, extra2)
    newValue(gameDb, n, keyPl2Nbr, nr2)

    return
}

function newLayoutSet(n, name, ct1, cb1, ct2, cb2, sound, useSound) {

    newValue(layoutDb, n, keyName, name)
    newValue(layoutDb, n, keyActiveFont, ct1)
    newValue(layoutDb, n, keyActiveBg, cb1)
    newValue(layoutDb, n, keyPassiveFont, ct2)
    newValue(layoutDb, n, keyPassiveBg, cb2)
    newValue(layoutDb, n, keySound, sound)
    newValue(layoutDb, n, keyUseSound, useSound)

    return
}

function newValue(tbl, set, keyword, value){
    var newSet = {"setNbr": set, "key": keyword, "value": value }

    //console.log(" new value " + set + " " + keyword + " " + value)

    if(db === null)
        return;

    addValueToList(tbl, set, keyword, value)

    // if value is a string, it must have ' as the first and last character
    if (tbl === layoutDb || keyword === keyName ) {
        value = doubleQuotes(value)
        value = "'" + value + "'"
    }

    try {
        db.transaction(function(tx){
            tx.executeSql("INSERT INTO " + tbl + " (setNbr, key, value)" +
                          " VALUES (" + set + ", '" + keyword + "', " + value + ")" )
        })
    } catch (err) {
        console.log("Error adding " + "(" + keyword + ", " + value + ")" + " to " + tbl + "-table in database: " + err);
    }

    return
}

function openDb(LS) {

    if(db === null)
        try {
            db = LS.openDatabaseSync("chessGoClock", "0.1", "game clock", 100);
        } catch (err) {
            console.log("Error in opening the database: " + err);
        };

    return
}

function readSetNames(tbl) {
    var ir = 0, names = [], data = {"nbr": 0, "name": ""}, table

    if (tbl === gameDb)
        table = gameSettings
    else if (tbl === layoutDb)
        table = layoutSettings

    while (ir < table.length){
        if (table[ir].key === keyName) {
            //console.log(" " + ir + ", " + table[ir].setNbr + ", " + table[ir].key + ", " + table[ir].value)
            data.nbr = table[ir].setNbr
            data.name = table[ir].value
            //names.push(data)
            names.push({"nbr": table[ir].setNbr, "name": table[ir].value})
        }
        ir ++
    }

    console.log( names.length + " sets in " + tbl )

    return names
}

function readTable(tbl) {
    var N = 0, i = 0 // number of rows read
    var dbRows, str

    if(db === null) {
        console.log("Error, database not open.")
        return;
    }

    try {
        db.transaction(function(tx){
            dbRows = tx.executeSql("SELECT * FROM " + tbl)
            N = dbRows.rows.length
        })
    } catch (err) {
        console.log("Error reading " + tbl +"-table in database: " + err)
    };

    console.log("found " + N + " rows in " + tbl)

    if (N>0) {
        for (i = 0; i < N; i++ ){
            if (tbl === layoutDb || dbRows.rows[i].key === keyName ) {
                str = removeDoubleQuotes(dbRows.rows[i].value)
            }
            // newValue(tbl, set, keyword, value)
            addValueToList(tbl, dbRows.rows[i].setNbr, dbRows.rows[i].key, dbRows.rows[i].value)
        }

        //if (tbl === gameDb) {
        //    gameSettings = dbRows.rows
        //} else if (tbl === layoutDb) {
        //    layoutSettings = dbRows.rows
        //}
        /*
        if (tbl === gameDb) {
            gameSettings = tx.executeSql("SELECT * FROM " + tbl)
            N = gameSettings.rows.length
        }
        else if (tbl === layoutDb) {
            layoutSettings = tx.executeSql("SELECT * FROM " + tbl)
            N = layoutSettings.rows.length
        } // */

    }

    return N
}

function readValue(tbl, setNr, key){
    var ir = 0, value, table

    if (tbl === gameDb)
        table = gameSettings
    else if (tbl === layoutDb)
        table = layoutSettings

    while (ir < table.length){
        //if (table.rows[ir].setNbr === setNr && table.rows[ir].key === key ) {
        //    value = table.rows[i].value
        //    ir = table.rows.length
        //}
        if (table[ir].setNbr === setNr && table[ir].key === key ) {
            value = table[ir].value
            ir = table.length
            //console.log("luettu " + value + ", setNbr " + setNr + ", key " + key)
        }

        ir++
    }

    if (ir === table.length) {
        console.log("value not found: " + setNr + ", " + key)
        return -1
    }

    return value
}

function removeDoubleQuotes(str){
    var dum = "" + str + ""
    //doubles characters ' and "
    dum = dum.replace(/''/g,"'")
    dum = dum.replace(/""/g,'"')

    return dum
}

function removeFromTable(tbl, setNr) {

    if(db === null)
        return;

    try {
        db.transaction(function(tx){
            tx.executeSql("DELETE FROM " + tbl + " WHERE setNbr = " + setNr)
        })
    } catch (err) {
        console.log("Error removing set number " + setNr + " from " + tbl + "-table: " + err);
    }

    return
}

function storeGameSettings(name, gameType, time1, extra1, nr1, time2, extra2, nr2) {
    var n = whichSet(gameDb, name)
    //console.log("here game " + n)

    if (n < 0)
        newGameSet(-n, name, gameType, time1, extra1, nr1, time2, extra2, nr2)
    else
        updateGameSet(n, name, gameType, time1, extra1, nr1, time2, extra2, nr2)

    return
}

function storeLayoutSettings(name, atxt, abkg, ptxt, pbkg, alarm, useAlarm) {
    var n = whichSet(layoutDb, name)
    //console.log("here layout " + n)

    if (n < 0)
        newLayoutSet(-n, name, atxt, abkg, ptxt, pbkg, alarm, useAlarm)
    else
        updateLayoutSet(n, name, atxt, abkg, ptxt, pbkg, alarm, useAlarm)

    return
}

function updateGameSet(setNr, name, gameType, time1, extra1, nr1, time2, extra2, nr2) {

    console.log("game " + name + ", type " + gameType + ", t1 " + time1 + ", e1 " + extra1
                + ", n1 " + nr1 + ", t2 " + time2 + ", e2 " + extra2 + ", n2 " + nr2)
    updateValue(gameDb, setNr, keyName, name)
    updateValue(gameDb, setNr, keyGame, gameType)
    updateValue(gameDb, setNr, keyPl1Time, time1)
    updateValue(gameDb, setNr, keyPl1Extra, extra1)
    updateValue(gameDb, setNr, keyPl1Nbr, nr1)
    updateValue(gameDb, setNr, keyPl2Time, time2)
    updateValue(gameDb, setNr, keyPl2Extra, extra2)
    updateValue(gameDb, setNr, keyPl2Nbr, nr2)
    //console.log("valmis " + setNr)

    return
}

function updateLayoutSet(setNr, name, atxt, abkg, ptxt, pbkg, alarm, useAlarm) {

    console.log("layout " + setNr + " " + name + ", af " + atxt + ", ab " + abkg +
                ", pf " + ptxt + ", pb " + pbkg + ", " + alarm + " " + useAlarm)
    updateValue(layoutDb, setNr, keyName, name)
    updateValue(layoutDb, setNr, keyActiveFont, atxt)
    updateValue(layoutDb, setNr, keyActiveBg, abkg)
    updateValue(layoutDb, setNr, keyPassiveFont, ptxt)
    updateValue(layoutDb, setNr, keyPassiveBg, pbkg)
    updateValue(layoutDb, setNr, keySound, alarm)
    updateValue(layoutDb, setNr, keyUseSound, useAlarm)
    //console.log("valmist")

    return
}

function updateValue(tbl, setNr, keyword, value) {
    var i = 0, table

    if(db === null)
        return;

    if (tbl === gameDb)
        table = gameSettings
    else if (tbl === layoutDb)
        table = layoutSettings

    while (i<table.length) {
        if (table[i].setNbr === setNr && table[i].key === keyword) {
            table[i].value = value
            i = table.length
        }
        i++
    }

    // if value is a string, it must have ' as the first and last character
    if (tbl === layoutDb || keyword === keyName) {
        value = doubleQuotes(value)
        value = "'" + value + "'"
    }

    try {
        db.transaction(function(tx){
            tx.executeSql("UPDATE " + tbl + " SET value = " + value +
                          "  WHERE setNbr = " + setNr + " AND key = '" + keyword + "'");
        });
    } catch (err) {
        console.log("Error modifying " + tbl + " -table in database: " + err);
        console.log(" " + tbl + ": " + setNr + ", " + keyword + ", " + value)
    };

    return
}

function whichSet(tbl, name){
    // returns the number of the settings group 'name'
    // or if the group doesn't exist, the next available set number as a negative number
    var table, i=0, N=0, maxSet=0

    if (tbl === gameDb)
        table = gameSettings
    else if (tbl === layoutDb)
        table = layoutSettings

    while(i<table.length){
        if (table[i].key === keyName) {
            if (table[i].setNbr > maxSet)
                maxSet = table[i].setNbr

            if (table[i].value === name) {
                N = table[i].setNbr
                i = table.length
            }
        }

        i++
    }

    // the next available set number        
    if (table.length !== 0 && i === table.length)
        N = -(maxSet + 1)

    //console.log(" " + tbl + ", settings number " + N)

    return N
}
