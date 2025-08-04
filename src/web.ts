import { WebPlugin } from '@capacitor/core';

import type { MetaWearPluginPlugin } from './definitions';

export class MetaWearPluginWeb extends WebPlugin implements MetaWearPluginPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
