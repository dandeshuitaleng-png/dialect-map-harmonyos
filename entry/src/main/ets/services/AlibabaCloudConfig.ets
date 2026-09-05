/**
 * Alibaba Cloud service base URL. Configure this at release time, for example
 * https://api.example.com. No account credential or server secret belongs here.
 */
export const ALIBABA_CLOUD_API_BASE_URL: string = 'https://hnp666.me/functions';

export function backendUrl(path: string): string {
  const base = ALIBABA_CLOUD_API_BASE_URL.trim().replace(/\/$/, '');
  return base.length === 0 ? '' : base + path;
}
