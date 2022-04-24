import { WebPlugin } from '@capacitor/core';

import type { MCameraPlugin } from './definitions';

export class MCameraWeb extends WebPlugin implements MCameraPlugin {

  showCamera(options: { lineColor: string }): void {
    console.log("SHOW CAMERA, Options: ", options);
  }

  stopCamera(): void {
    console.log("STOP CAMERA")
  }

}
