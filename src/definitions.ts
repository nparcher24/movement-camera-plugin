export interface MCameraPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
