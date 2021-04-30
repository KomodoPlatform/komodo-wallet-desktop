import QtQuick 2.15
import QtQuick.LocalStorage 2.15

ListModel {
    id: control
    property string dbName: "Test00000"
    property string description: ""
    property string version: "1.0"
    property string tableName: "Test12"
    property string columns: "id INTEGER PRIMARY KEY,nom TEXT, prenom TEXT"
    property string tableStructure: "%1(%2)".arg(tableName).arg(columns)
    property var db: LocalStorage.openDatabaseSync(dbName, version, description, 1000000);
    function selectAll() {
        control.clear()
        db.transaction(function(tx){
            var rs = tx.executeSql('SELECT * FROM '+tableName);
            for (var i = 0; i < rs.rows.length; i++) {
                control.append(rs.rows.item(i))
            }
        })
    }
    function removeByIndex(index) {
        let el = control.get(index)
        db.transaction(function(tx){
            tx.executeSql("DELETE FROM %1 WHERE id=%2".arg(tableName).arg(el.id))
            control.remove(index)
        })
    }


    function updateByIndex(index, data) {
        let el = control.get(index)
        db.transaction(function(tx){
            tx.executeSql("UPDATE %1 SET %3 WHERE id=%2".arg(tableName).arg(el.id).arg(data))
        })
    }

    function formatToJSON(data) {
        let tableCol = ""
        let tableData = ""
        for(var el in data){
            tableCol+=el+","
            tableData+="'%1',".arg(data[el])
        }
        return [tableCol.slice(0,-1), tableData.slice(0,-1)]
    }

    function insert(data) {
        let formated = formatToJSON(data)
        db.transaction(function(tx){
            tx.executeSql('INSERT INTO %1(%2) VALUES(%3)'.arg(tableName).arg(formated[0]).arg(formated[1]))
        })
    }

    Component.onCompleted: {
        db.transaction(function(tx){
            tx.executeSql('CREATE TABLE IF NOT EXISTS '+tableStructure)
        })
        selectAll()
    }
}
