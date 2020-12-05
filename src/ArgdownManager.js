// See the following Argdown documentation
//  - https://argdown.org/argdown-core/classes/argdownapplication.html
//  - https://argdown.org/guide/using-argdown-in-your-application.html
//  - https://argdown.org/guide/embedding-your-maps-in-a-webpage.html

import autoBind from 'auto-bind';
import * as Argdown from '@argdown/core';
import { SyncDotToSvgExportPlugin } from './SyncDotToSvgExportPlugin';

const fail = (message) => JSON.stringify({ success: false, error: message });
const success = () => JSON.stringify({ success: true, error: '' });

const createArgdownApp = () => {
  const argdown = new Argdown.ArgdownApplication();
  argdown.addPlugin(new Argdown.ParserPlugin(), 'parse-input');
  argdown.addPlugin(new Argdown.DataPlugin(), 'build-model');
  argdown.addPlugin(new Argdown.ModelPlugin(), 'build-model');
  argdown.addPlugin(new Argdown.RegroupPlugin(), 'build-model');
  argdown.addPlugin(new Argdown.PreselectionPlugin(), 'build-map');
  argdown.addPlugin(new Argdown.StatementSelectionPlugin(), 'build-map');
  argdown.addPlugin(new Argdown.ArgumentSelectionPlugin(), 'build-map');
  argdown.addPlugin(new Argdown.MapPlugin(), 'build-map');
  argdown.addPlugin(new Argdown.GroupPlugin(), 'build-map');
  argdown.addPlugin(new Argdown.ClosedGroupPlugin(), 'transform-closed-groups');
  argdown.addPlugin(new Argdown.ColorPlugin(), 'colorize');
  argdown.addPlugin(new Argdown.HtmlExportPlugin(), 'export-html');
  argdown.addPlugin(new Argdown.JSONExportPlugin(), 'export-json');
  argdown.addPlugin(new Argdown.DotExportPlugin(), 'export-dot');
  argdown.addPlugin(new Argdown.GraphMLExportPlugin(), 'export-graphml');
  // argdown.addPlugin(new Argdown.SyncDotToSvgExportPlugin(), 'export-svg');
  argdown.addPlugin(new SyncDotToSvgExportPlugin(), 'export-svg');
  argdown.addPlugin(new Argdown.HighlightSourcePlugin(), 'highlight-source');
  argdown.addPlugin(new Argdown.WebComponentExportPlugin(), 'export-web-component');

  // See node_modules/@argdown/core/dist/argdown.js for all default processes
  argdown.defaultProcess = [
    'parse-input',
    'build-model',
    'build-map',
    'transform-closed-groups',
    'colorize',
    'export-dot',
    'export-svg',
    'highlight-source',
    'export-web-component'
  ];

  return argdown;
};

export default class ArgdownManager {
  constructor() {
    autoBind(this);

    this.argdown = createArgdownApp();
    this.overrideWebComponentPlugin();

    this.logLevel = process.env.NODE_ENV === 'production' ? 'error' : 'warning';
  }

  applySettings(settings) {
    this.overrideWebComponentPlugin(settings.webComponent);
    this.overrideGroupPlugin(settings.group);
    this.overridePreselectionPlugin(settings.selection);
  }

  overridePlugin(p) {
    const inst = new p.plugin(p.settings);
    this.argdown.replacePlugin(inst.name, inst, p.stage);
  }

  overrideWebComponentPlugin(settings) {
    this.overridePlugin({
      plugin: Argdown.WebComponentExportPlugin,
      stage: 'export-web-component',
      settings: Object.assign(
        {
          initialView: 'map',
          useArgVu: true,
          addGlobalStyles: false,
          addWebComponentScript: false,
          addWebComponentPolyfill: false
        },
        settings
      )
    });
  }

  overrideGroupPlugin(settings) {
    this.overridePlugin({ plugin: Argdown.GroupPlugin, stage: 'build-map', settings });
  }

  overridePreselectionPlugin(settings) {
    this.overridePlugin({ plugin: Argdown.PreselectionPlugin, stage: 'build-map', settings });
  }

  async loadArgument() {
    if (!this.argument) {
      const response = await fetch('./assets/argument.ad');
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
      process: this.argdown.defaultProcess,
      logLevel: this.logLevel
    });

    if (result.lexerErrors?.length > 0) return fail(this.lexerErrors.map((e) => `${e.message}\n`));
    if (!result.webComponent) return fail('Argdown WebComponent creation failed.');

    this.webComponent = result.webComponent;
    return success();
  }

  mountAtDomId(id) {
    try {
      if (!this.webComponent) throw 'WebComponent has not been built yet!';
      const domNode = document.getElementById(id);
      if (!domNode) throw `DOM node with id "${id}" does not exist.`;
      domNode.innerHTML = this.webComponent;
    } catch (e) {
      console.error(e);
    }
  }
}
