import { bundleManager } from "@kit.AbilityKit";


export  function getAppVersion() {
  return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
}

/**
 * 格式化时间为 yyyy-MM-dd'T'HH:mm:ssXXX 格式
 * @param date 要格式化的日期对象
 * @returns 格式化后的时间字符串
 */
export function formatDateToISOString(date: Date): string {
  // 获取年月日时分秒
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  const seconds = date.getSeconds().toString().padStart(2, '0');

  const timezoneOffset = date.getTimezoneOffset();
  const absOffset = Math.abs(timezoneOffset);
  const offsetHours = Math.floor(absOffset / 60).toString().padStart(2, '0');
  const offsetMinutes = (absOffset % 60).toString().padStart(2, '0');

  let timezoneString = ""
  if (timezoneOffset === 0) {
    timezoneString = 'Z'
  } else {
    const sign = timezoneOffset > 0 ? '-' : '+';
    timezoneString = `${sign}${offsetHours}:${offsetMinutes}`;
  }

  return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}${timezoneString}`;
}