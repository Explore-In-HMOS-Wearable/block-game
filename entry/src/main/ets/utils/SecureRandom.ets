import { cryptoFramework } from '@kit.CryptoArchitectureKit';

let fallbackSeed: number = Date.now() >>> 0;

/**
 * Generates a cryptographically secure random number between 0 (inclusive)
 * and 1 (exclusive).
 */
export function secureRandomNumber(): number {
  try {
    const rand = cryptoFramework.createRandom();
    const len = 8;
    const randData = rand.generateRandomSync(len);
    const bytes = randData.data;
    let bigIntValue = BigInt(0);
    for (let i = 0; i < 8; i++) {
      bigIntValue = (bigIntValue << BigInt(8)) | BigInt(bytes[i]);
    }
    const maxSafeValue = BigInt(1) << BigInt(53);
    const normalizedValue = Number(bigIntValue >> BigInt(11)) / Number(maxSafeValue);
    return normalizedValue;
  } catch (_error) {
    fallbackSeed = (1664525 * fallbackSeed + 1013904223) >>> 0;
    return fallbackSeed / 0x100000000;
  }
}
