export class OtaStatusCode {
  /**
   * ota success
   */
  public static SUCCESS = 0x00;
  /**
   * ota started
   */
  public static STARTED = 0x01;
  /**
   * ota busy status when call {@link com.telink.ota.ble.OtaController#startOta(OtaSetting)}
   * at previous ota running
   */
  public static BUSY = 0x04;
  /**
   * ota busy status when call {@link com.telink.ota.ble.OtaController#startOta(OtaSetting)}
   * at previous ota running
   */
  public static RESEND_PACKET = 0x05;
  /**
   * ota params err
   */
  public static FAIL_PARAMS_ERR = 0x10;
  /**
   * connection interrupt when ota running
   */
  public static FAIL_CONNECTION_INTERRUPT = 0x11;
  /**
   * version compare err
   */
  public static FAIL_VERSION_RSP_ERROR = 0x12;
  /**
   * version compare err
   */
  public static FAIL_VERSION_COMPARE_ERR = 0x13;
  /**
   * send command err
   */
  public static FAIL_PACKET_SENT_ERR = 0x14;
  /**
   * send command timeout
   */
  public static FAIL_PACKET_SENT_TIMEOUT = 0x15;
  /**
   * ota flow timeout
   */
  public static FAIL_FLOW_TIMEOUT = 0x16;
  /**
   * not connected
   */
  public static FAIL_UNCONNECTED = 0x18;
  /**
   * service not found
   */
  public static FAIL_SERVICE_NOT_FOUND = 0x19;
  /**
   * service not found
   */
  public static FAIL_CHARACTERISTIC_NOT_FOUND = 0x1A;
  /**
   * check selected firmware bin error
   */
  public static FAIL_FIRMWARE_CHECK_ERR = 0x1B;
  /**
   * firmware version request timeout
   */
  public static FAIL_FW_VERSION_REQ_TIMEOUT = 0x1C;
  /**
   * received notification err
   */
  public static FAIL_OTA_RESULT_NOTIFICATION = 0x1D;
  /**
   * received notification err
   */
  public static FAIL_DESCRIPTOR_CHECK_ERR = 0x1E;

  /**
   * is ota failed
   */
  public static isFailed(code: number): boolean {
    return code >= 0x10;
  }

  /**
   * @return is ota complete
   */
  public static isComplete(code: number): boolean {
    return OtaStatusCode.isFailed(code) || code == OtaStatusCode.SUCCESS;
  }
}
