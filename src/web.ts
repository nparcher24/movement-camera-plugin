import { WebPlugin } from '@capacitor/core';

import type { MCameraPlugin } from './definitions';

export class MCameraWeb extends WebPlugin implements MCameraPlugin {
  showCamera(options: { testValue: string; }): void {
    console.log("SHOWCAMERA WAS CALLED");
    console.log(options)
  }

  updateUI(data: { goodReps: number; time: number; badReps: number; }): void {
    console.log('UPDATEUI WAS CALLED');
    console.log(data);
  }

  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

}
