// See the following Argdown documentation
//  - https://argdown.org/argdown-core/classes/argdownapplication.html
//  - https://argdown.org/guide/using-argdown-in-your-application.html
//  - https://argdown.org/guide/embedding-your-maps-in-a-webpage.html

import autoBind from 'auto-bind';
import { GroupPlugin, PreselectionPlugin, WebComponentExportPlugin } from '@argdown/core';
import { argdown } from '@argdown/core/dist/argdown';
import variants from './argMapVariants';

export default class ArgdownManager {
  constructor() {
    autoBind(this);

    this.argdown = argdown;
    this.variants = variants;
    this.setVariant('contrib');
    this.overrideWebComponentPlugin();

    this.defaultProcess = this.argdown.defaultProcesses['export-web-component'];
    this.logLevel = process.env.NODE_ENV === 'production' ? 'error' : 'verbose';
  }

  setVariant(variantName) {
    if (this.currentVariant === variantName) return;
    const variant = this.variants[variantName];
    if (!variant) throw `Variant "${variant}" does not exist`;

    this.currentVariant = variantName;
    this.overrideGroupPlugin(variant.group);
    this.overridePreselectionPlugin(variant.selection);
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
    const response = await fetch('./argument.ad');
    this.argument = await response.text();
  }

  renderWebComponent() {
    if (!this.argument) throw 'Argument not loaded yet';
    return this.argdown.run({
      input: this.argument,
      process: this.defaultProcess,
      logLevel: this.logLevel
    }).webComponent;
  }

  renderInId(id) {
    const domNode = document.getElementById(id);
    if (!domNode) throw `DOM node with id "${id}" does not exist`;
    domNode.innerHTML = this.renderWebComponent();
  }
}
