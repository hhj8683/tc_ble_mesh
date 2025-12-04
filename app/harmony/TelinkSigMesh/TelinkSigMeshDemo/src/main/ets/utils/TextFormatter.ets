import { bytesToHex, OtaProtocol, OtaSetting } from "telinksigmeshlib";

export class TextFormatter {
  info = ""

  formatOtaSetting(otaSetting: OtaSetting): string {
    this.appendTitle("\tservice: ");
    if (otaSetting.serviceUUID != null) {
      this.appendContent(otaSetting.serviceUUID.toString());
    } else {
      this.appendContent("[use default(1912)]");
    }

    this.appendTitle("\n\tcharacteristic: ");
    if (otaSetting.characteristicUUID != null) {
      this.appendContent(otaSetting.characteristicUUID.toString());
    } else {
      this.appendContent("[use default(2B12)]");
    }
    this.appendTitle("\n\tread interval: ");
    this.appendContent(otaSetting.readInterval + "");
    this.appendTitle("\n\tbin path: ");
    if (otaSetting.firmwarePath != null) {
      this.appendContent(otaSetting.firmwarePath);
    } else {
      this.appendContent("error - file not selected");
    }

    // secure boot
    this.appendTitle("\n\tsecure boot: ");
    this.appendContent(otaSetting.secureBootEnable + "");

    if (otaSetting.secureBootEnable) {
      this.appendTitle("\n\trun code description file: ");
      this.appendContent(otaSetting.descriptorPath);
    }

    this.appendTitle("\n\tsend firmware index: ");
    this.appendContent(otaSetting.sendFwIndex + "");
    if (otaSetting.sendFwIndex) {
      this.appendTitle("\n\t\tfirmware index: ");
      this.appendContent(otaSetting.fwIndex.toString(16).padStart(2, '0'));
    }

    let isLegacyProtocol = otaSetting.protocol == OtaProtocol.Legacy;
    this.appendTitle("\n\tprotocol: ");
    this.appendContent(isLegacyProtocol ? "Legacy" : "Extend");

    if (!isLegacyProtocol) {
      this.appendTitle("\n\tversion compare: ");
      this.appendContent(otaSetting.versionCompare + "");

      this.appendTitle("\n\tbin version: ");
      this.appendContent(otaSetting.firmwareVersion);

      this.appendTitle("\n\tpdu length: ");
      this.appendContent(otaSetting.pduLength + "");
    }
    return this.info
  }

  private appendTitle(title: string) {
    this.info += title
    // this.info += `<p style="font-size: 35px;text-align: center;font-weight: bold; color: 'gray'">${title}</p>`
  }

  private appendContent(content: string) {
    this.info += content
    // this.info += ("<font size=‘13’ color = '#0E1E59'>") + (content) + ("</font><br>"); // <br>
    // this.info += `<p style="font-size: 35px;text-align: center;font-weight: bold; color: '#0E1E59'">${content}</p>`
  }
}
