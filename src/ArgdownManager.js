// See the following Argdown documentation
//  - https://argdown.org/argdown-core/classes/argdownapplication.html
//  - https://argdown.org/guide/using-argdown-in-your-application.html
//  - https://argdown.org/guide/embedding-your-maps-in-a-webpage.html

import { WebComponentExportPlugin } from '@argdown/core';
import { argdown } from '@argdown/core/dist/argdown';

const argument = `
# Section 1

<a>: Quack! {proponent: Donald Duck}
    - <b>
    + <c>

## Section 2

<b>: D'oh! {proponent: Homer Simpson}

<c>: Pretty, pretty, pretty, pretty good. {proponent: Larry David}

[A Statement]: Good
    <- <a>

[B Statement]: Bad
    <- <b>
    >< [A Statement]
`;

const pluginsToOverride = [
  {
    plugin: WebComponentExportPlugin,
    stage: 'export-web-component',
    settings: {
      initialView: 'map',
      useArgVu: true,
      addGlobalStyles: false,
      addWebComponentScript: false,
      addWebComponentPolyfill: false
    }
  }
];

export default class ArgdownManager {
  constructor() {
    this.argdown = argdown;

    pluginsToOverride.forEach((p) => {
      const inst = new p.plugin(p.settings);
      this.argdown.replacePlugin(p.plugin.name, inst, p.stage);
    });

    this.defaultProcess = this.argdown.defaultProcesses['export-web-component'];
    this.logLevel = process.env.NODE_ENV === 'production' ? 'error' : 'verbose';
  }

  renderWebComponent() {
    return this.argdown.run({
      input: argument,
      process: this.defaultProcess,
      logLevel: this.logLevel
    }).webComponent;
  }
}
