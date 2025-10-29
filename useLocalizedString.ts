import { useEffect, useState } from 'react';
import { SharedNativeModule } from './SharedNativeModule'; 

const localizationCache = new Map<string, string>();

export function useLocalizedString(
  key: string,
  params: Record<string, string> = {}
): string | null {
  const cacheKey = `${key}:${JSON.stringify(params)}`;
  const [value, setValue] = useState<string | null>(
    localizationCache.get(cacheKey) ?? null
  );

  useEffect(() => {
    let isMounted = true;

    // If cached, skip fetching
    if (localizationCache.has(cacheKey)) return;

    (async () => {
      try {
        const result = await SharedNativeModule.localize(key, params);
        localizationCache.set(cacheKey, result); 
        if (isMounted) setValue(result);
      } catch (err) {
        console.error(`Localization failed for key "${key}":`, err);
      }
    })();

    return () => {
      isMounted = false;
    };
  }, [cacheKey, key, JSON.stringify(params)]);

  return value;
}