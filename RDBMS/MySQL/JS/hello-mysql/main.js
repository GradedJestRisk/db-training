var mysql = require('mysql');

var con = mysql.createConnection({
    host: "172.17.0.2",
    user: "pedro",
    password: "barbar"
});

con.connect(function (err) {

    if (err) throw err;
    console.log("Connected to MySQL ");

    con.query("USE test_db", function (err, result) {
        if (err) throw err;
        console.log("Connected to schema test_db");
        console.log("Raw result");
        console.log(result)
    });

    con.query("SELECT * FROM foo", function (err, result, fields) {

        if (err) throw err;

        console.log("Raw fields");
        console.log(fields);

        console.log("ResultSet contains the following fields");
        for (const field of fields) {
            console.log("Field: " + field.name);
        }

        console.log("Raw result");
        console.log(result);

        console.log("1st line");
        console.log(result[0]);

        console.log("ResultSet contains the following data");
        for (const record of result) {
            console.log("Result: id ", record.foo_id, ", name = ", record.foo_name);
        }


    });

});