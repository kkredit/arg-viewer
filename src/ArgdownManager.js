// Argdown: see https://argdown.org/argdown-core/classes/argdownapplication.html
// and https://argdown.org/guide/using-argdown-in-your-application.html
import {
  ArgdownApplication,
  ParserPlugin,
  ModelPlugin,
  ColorPlugin,
  HtmlExportPlugin
} from '@argdown/core';

const argument = `
# Section 1

<a>: Quack! {proponent: Donald Duck}
    - <b>
    + <c>

## Section 2

<b>: D'oh! {proponent: Homer Simpson}

<c>: Pretty, pretty, pretty, pretty good. {proponent: Larry David}
`;

export default class ArgdownManager {
  constructor(logLevel = 'verbose') {
    this.argdown = new ArgdownApplication();
    this.plugins = [
      { plugin: ParserPlugin, stage: 'parse-input' },
      { plugin: ModelPlugin, stage: 'build-model' },
      { plugin: ColorPlugin, stage: 'color-model' },
      { plugin: HtmlExportPlugin, stage: 'export-html' }
    ];

    this.plugins.forEach((p) => {
      const inst = new p.plugin();
      this.argdown.addPlugin(inst, p.stage);
    });

    this.logLevel = logLevel;
  }

  render() {
    const process = this.plugins.map((p) => p.stage);
    return this.argdown.run({ input: argument, process, logLevel: this.logLevel });
  }
}
