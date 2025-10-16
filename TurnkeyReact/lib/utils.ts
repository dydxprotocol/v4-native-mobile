import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export const withTimeout = <T>(promise: Promise<T>, timeoutMs = 5000, fallback: T): Promise<T> => {
  return Promise.race([
    promise,
    new Promise<T>((resolve) =>
      setTimeout(() => resolve(fallback), timeoutMs)
    ),
  ]);
};

export const truncateAddress = (
  address: string,
  { prefix = 8, suffix = 4 }: { prefix?: number; suffix?: number } = {}
) => {
  return `${address.slice(0, prefix)}•••${address.slice(-suffix)}`;
};

export const decodeBase64 = <T = any>(encoded: string): T => {
  try {
    const urlDecoded = decodeURIComponent(encoded);

     const decoded =
      typeof window === "undefined"
        ? Buffer.from(urlDecoded, "base64").toString("utf-8")
        : atob(urlDecoded);

    return JSON.parse(decoded);
  } catch (err) {
    console.error("Failed to decode Base64 string:", err);
    throw err;
  }
};