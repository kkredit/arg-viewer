import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

// Argdown: see https://argdown.org/argdown-core/classes/argdownapplication.html
// and https://argdown.org/guide/using-argdown-in-your-application.html
import {
  ArgdownApplication,
  ParserPlugin,
  ModelPlugin,
  ColorPlugin,
  HtmlExportPlugin
} from '@argdown/core';
const app = new ArgdownApplication();
const parserPlugin = new ParserPlugin();
app.addPlugin(parserPlugin, 'parse-input');
const modelPlugin = new ModelPlugin();
app.addPlugin(modelPlugin, 'build-model');
const colorPlugin = new ColorPlugin();
app.addPlugin(colorPlugin, 'build-model');
const htmlExportPlugin = new HtmlExportPlugin();
app.addPlugin(htmlExportPlugin, 'export-html');
const input = `
# Section 1

<a>: Quack! {proponent: Donald Duck}
    - <b>
    + <c>

## Section 2

<b>: D'oh! {proponent: Homer Simpson}

<c>: Pretty, pretty, pretty, pretty good. {proponent: Larry David}
`;
const request = {
  input,
  process: ['parse-input', 'build-model', 'export-html'],
  logLevel: 'verbose'
};
const response = app.run(request);
document.getElementById('map').innerHTML = response.html;

Elm.Main.init({
  node: document.getElementById('root')
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
