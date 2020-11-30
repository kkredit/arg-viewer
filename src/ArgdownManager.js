// See the following Argdown documentation
//  - https://argdown.org/argdown-core/classes/argdownapplication.html
//  - https://argdown.org/guide/using-argdown-in-your-application.html
//  - https://argdown.org/guide/embedding-your-maps-in-a-webpage.html

import autoBind from 'auto-bind';
import { GroupPlugin, PreselectionPlugin, WebComponentExportPlugin } from '@argdown/core';
import { argdown } from '@argdown/core/dist/argdown';

const fail = (message) => JSON.stringify({ success: false, error: message });
const success = () => JSON.stringify({ success: true, error: '' });

export default class ArgdownManager {
  constructor() {
    autoBind(this);

    this.argdown = argdown;
    this.overrideWebComponentPlugin();

    this.defaultProcess = this.argdown.defaultProcesses['export-web-component'];
    this.logLevel = process.env.NODE_ENV === 'production' ? 'error' : 'verbose';
  }

  applySettings(settings) {
    this.overrideGroupPlugin(settings.group);
    this.overridePreselectionPlugin(settings.selection);
  }

  overridePlugin(p) {
    const inst = new p.plugin(p.settings);
    this.argdown.replacePlugin(p.plugin.name, inst, p.stage);
  }

  overrideWebComponentPlugin() {
    this.overridePlugin({
      plugin: WebComponentExportPlugin,
      stage: 'export-web-component',
      settings: {
        initialView: 'map',
        useArgVu: true,
        addGlobalStyles: false,
        addWebComponentScript: false,
        addWebComponentPolyfill: false
      }
    });
  }

  overrideGroupPlugin(settings) {
    this.overridePlugin({ plugin: GroupPlugin, stage: 'build-map', settings });
  }

  overridePreselectionPlugin(settings) {
    this.overridePlugin({ plugin: PreselectionPlugin, stage: 'build-map', settings });
  }

  async loadArgument() {
    if (!this.argument) {
      const response = await fetch('./argument.ad');
      this.argument = await response.text();
    }
  }

  renderWebComponent(settingsJson) {
    if (!this.argument) return fail('Argument not loaded yet.');

    try {
      const settings = JSON.parse(settingsJson);
      this.applySettings(settings);
    } catch (e) {
      return fail('Failed to parse settings JSON.');
    }

    const result = this.argdown.run({
      input: this.argument,
      process: this.defaultProcess,
      logLevel: this.logLevel
    });

    if (result.lexerErrors.length > 0) return fail(this.lexerErrors.map((e) => `${e.message}\n`));
    if (!result.webComponent) return fail('Argdown WebComponent creation failed.');

    this.webComponent = result.webComponent;
    return success();
  }

  mountAtDomId(id) {
    if (!this.webComponent) throw 'WebComponent has not been built yet!';
    const domNode = document.getElementById(id);
    if (!domNode) throw `DOM node with id "${id}" does not exist.`;
    domNode.innerHTML = this.webComponent;
  }
}
