import { registerPlugin } from '@capacitor/core';

import type { MCameraPlugin } from './definitions';

const MCamera = registerPlugin<MCameraPlugin>('MCamera', {
  web: () => import('./web').then(m => new m.MCameraWeb()),
});

export * from './definitions';
export { MCamera };
