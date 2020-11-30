import './main.css';
import ArgdownManager from './ArgdownManager';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const am = new ArgdownManager();

const elmApp = Elm.Main.init({
  node: document.getElementById('root')
});

elmApp.ports.updateMap.subscribe((settingsJson) =>
  am.loadArgument().then(() => elmApp.ports.updateStatus.send(am.renderWebComponent(settingsJson)))
);

elmApp.ports.mountMapAtId.subscribe((id) => am.mountAtDomId(id));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
