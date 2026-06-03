export function isLikelyMojibake(value: string): boolean {
  if (!value) return false;
  return /[ÃÂÄÅÆÇÐÑØÙÚÛÝÞßæøð]|�/.test(value);
}

export function repairMojibake(value: string): string {
  if (!value) return value;
  if (!isLikelyMojibake(value)) return value;
  try {
    return Buffer.from(value, 'latin1').toString('utf8');
  } catch {
    return value;
  }
}

export function cleanText(value: unknown): string {
  const raw = String(value ?? '').trim();
  if (!raw) return '';
  return repairMojibake(raw).replace(/\s+/g, ' ');
}
