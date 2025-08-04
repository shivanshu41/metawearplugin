import { registerPlugin } from '@capacitor/core';
import type { MetaWearPluginPlugin } from './definitions';

const MetaWear = registerPlugin<MetaWearPluginPlugin>('MetaWearPlugin');

export * from './definitions';
export { MetaWear };
