import './main.css';
import ArgdownManager from './ArgdownManager';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const am = new ArgdownManager();
document.getElementById('map').innerHTML = am.renderWebComponent();

Elm.Main.init({
  node: document.getElementById('root')
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
