export interface MCameraPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  showCamera(options: { testValue: string }): void;
  updateUI(data: { goodReps: number, time: number, badReps: number }): void;
}
