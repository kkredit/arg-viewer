// From @argdown/core/dist-esm/plugins/SyncDotToSvgExportPlugin.js
// License MIT

import vizRenderStringSync from '@aduh95/viz.js/sync';
import defaultsDeep from 'lodash.defaultsdeep';
import { checkResponseFields, isObject, mergeDefaults, GraphvizEngine } from '@argdown/core';

const defaultSettings = {
  removeProlog: true,
  engine: GraphvizEngine.DOT
};

export class SyncDotToSvgExportPlugin {
  constructor(config) {
    this.name = 'SyncDotToSvgExportPlugin';

    this.prepare = (request) => {
      mergeDefaults(this.getSettings(request), this.defaults);
    };

    this.run = (request, response) => {
      const requiredResponseFields = ['dot'];
      checkResponseFields(this, response, requiredResponseFields);
      let { engine, nop, removeProlog } = this.getSettings(request);
      response.svg = vizRenderStringSync(response.dot, {
        engine,
        nop,
        format: 'svg'
      });
      if (removeProlog) {
        response.svg = response.svg.replace(
          /<\?[ ]*xml[\S ]+?\?>[\s]*<\![ ]*DOCTYPE[\S\s]+?\.dtd\"[ ]*>/,
          ''
        );
      }
      return response;
    };

    this.defaults = defaultsDeep({}, config, defaultSettings);
  }

  getSettings(request) {
    if (isObject(request.vizJs)) {
      return request.vizJs;
    } else {
      request.vizJs = {};
      return request.vizJs;
    }
  }
}
