import { hilog } from '@kit.PerformanceAnalysisKit';

class Logger {
  private domain: number;
  private prefix: string;

  constructor(prefix: string) {
    this.prefix = prefix;
    this.domain = 0xFF00;
  }

  debug(...args: string[]): void {
    hilog.debug(this.domain, this.prefix, args[0] ?? '', ...args.slice(1));
  }

  info(...args: string[]): void {
    hilog.info(this.domain, this.prefix, args[0] ?? '', ...args.slice(1));
  }

  warn(...args: string[]): void {
    hilog.warn(this.domain, this.prefix, args[0] ?? '', ...args.slice(1));
  }

  error(...args: string[]): void {
    hilog.error(this.domain, this.prefix, args[0] ?? '', ...args.slice(1));
  }
}

export default new Logger('[BlockGame]');
