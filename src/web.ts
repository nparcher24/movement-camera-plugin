import { WebPlugin } from '@capacitor/core';

import type { MCameraPlugin } from './definitions';

export class MCameraWeb extends WebPlugin implements MCameraPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
