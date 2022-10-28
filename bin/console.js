#!/usr/bin/env node

// yarn add yargs@13.2
// yarn add express
// yarn add chalk@2.4 boxen@4.0

const express = require('express');
const twig = require('twig');
const app = express();

const yaml = require('js-yaml');
const fs   = require('fs');

app.set('views', 'templates');

const Pageres = require('pageres');

const httpPort = 3000

const chalk = require("chalk");
const boxen = require("boxen");

const boxenOptions = {
    padding: 1,
    margin: 1,
    borderStyle: "round",
    borderColor: "green",
    backgroundColor: "#555555"
};

const yargs = require("yargs");

const options = yargs
    .usage("Usage: -n <name>")
    .option("s", { alias: "server", describe: "Run server mode", type: "boolean", demandOption: false })
    .argv;

/*
const greeting = `Hello, ${options.name}!`;
const msgBox = boxen( greeting, boxenOptions );
console.log(msgBox);
*/

app.use('/css', express.static('public/css'));
app.use('/img', express.static('public/img'));
app.use('/js', express.static('public/js'));


app.get('/', (req, res) => {
    res.render('index.html.twig')
    //res.send('Hello World!')
})

app.get('/kneeboard', (req, res) => {
    res.render('kneeboard.html.twig')
    //res.send('Hello World!')
})

/**
 * Load Frequencies from file
 *
 * @param filename
 * @return radioPresets
 */
function loadFrequencies(filename)
{
    try {
        const doc = yaml.load(fs.readFileSync(filename, 'utf8'));
        if(doc.radioPresets === undefined) {
            throw `radioPresets undefined in file ${filename}`;
        }
        return doc.radioPresets;
    } catch (e) {
        console.log(e);
    }
}

app.get('/kneeboard/:page', (req, res) => {

    let frequencies=loadFrequencies('src/radio/radioSettings.yml');

    res.render(`kneeboard/${req.params.page}.html.twig`, {frequencies: frequencies})
    console.log(`render page ${req.params.page}`);
})

app.get('/kneeboard/:page/save', (req, res) => {

    (async () => {
        await new Pageres({delay: 2, filename: 'kneeboard'})
            .src(`http://localhost:${httpPort}/kneeboard/${req.params.page}`, ['600x900'])
            .dest('.')
            .run();

        console.log('Finished generating screenshots!');
    })();

    res.send('done');
    console.log(`render page ${req.params.page}`);
})

if(options.server) {

    app.listen(httpPort, () => {
        console.log(`running http server on port ${httpPort}`)
    })

}
else {

}
//
//
//
