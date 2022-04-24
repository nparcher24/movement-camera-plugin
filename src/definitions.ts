export interface MCameraPlugin {
  /**
   * Starts the ML Model, the camera, and displays it on the screen behind the ionic content
   *
   * @param options - An options object that currently only includes: a hex color string for the lines to show on the screen
   * @returns nothing.
   *
   */
  showCamera(options: { lineColor: string }): void;

  /**
   * Stops the camera from showing; deallocs the used memory and removes it from the native view stack
   *
   *
   */
  stopCamera(): void;

}
