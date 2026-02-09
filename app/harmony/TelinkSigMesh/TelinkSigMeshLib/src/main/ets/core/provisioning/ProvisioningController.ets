/********************************************************************************************************
 * @file ProvisioningController.ets
 *
 * @brief for TLSR chips
 *
 * @author telink
 * @date Sep. 30, 2017
 *
 * @par Copyright (c) 2017, Telink Semiconductor (Shanghai) Co., Ltd. ("TELINK")
 *
 *          Licensed under the Apache License, Version 2.0 (the "License");
 *          you may not use this file except in compliance with the License.
 *          You may obtain a copy of the License at
 *
 *              http://www.apache.org/licenses/LICENSE-2.0
 *
 *          Unless required by applicable law or agreed to in writing, software
 *          distributed under the License is distributed on an "AS IS" BASIS,
 *          WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *          See the License for the specific language governing permissions and
 *          limitations under the License.
 *******************************************************************************************************/

import { ProvisioningDevice } from '../../entity/ProvisioningDevice';
import { bytesEquals, bytesToHex, bytesToHexString, bytesToString, hexToBytes } from '../../utils/ArrayUtils';
import { generateRandom, isCertSupported, isPvRecordSupported } from '../../utils/MeshUtils';
import { ProvisioningCapabilityPDU } from './pdu/ProvisioningCapabilityPDU';
import { ProvisioningInvitePDU } from './pdu/ProvisioningInvitePDU';
import { ProvisioningPDU } from './pdu/ProvisioningPDU';
import { ProvisioningPubKeyPDU } from './pdu/ProvisioningPubKeyPDU';
import { ProvisioningRecordRequestPDU } from './pdu/ProvisioningRecordRequestPDU';
import { ProvisioningRecordsGetPDU } from './pdu/ProvisioningRecordsGetPDU';
import { ProvisioningRecordsListPDU } from './pdu/ProvisioningRecordsListPDU';
import { ProvisioningStartPDU } from './pdu/ProvisioningStartPDU';
import { ProvisioningBridge } from './ProvisioningBridge';
import { log, log as log_m, loge, LOG_LEVEL_WARN } from '../../utils/MeshLogger'
import {
    aesCmac,
    ccm,
    checkCertificate,
    checkCertificateByCa,
    generateECDH,
    generateKeyPair,
    generateSalt,
    getPublicKeyInCert,
    getStaticOOBInCert,
    hMacSha256,
    k1,
    k5,
    PRCK,
    PRCK256,
    PRDK,
    PRSK,
    PRSN,
    s2
} from '../../utils/Encipher';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { ProvisioningStatePDU } from './pdu/ProvisioningStatePDU';
import { ProvisioningRecordResponsePDU } from './pdu/ProvisioningRecordResponsePDU';
import { ProvisioningDataPDU } from './pdu/ProvisioningDataPDU';
import { ProvisioningRandomPDU } from './pdu/ProvisioningRandomPDU';
import { ProvisioningConfirmPDU } from './pdu/ProvisioningConfirmPDU';
import { ProxyPDU } from '../proxy/ProxyPDU';

/**
 * provisioning
 * Auth Method inputOOB outputOOB is not supported
 * Created by kee on 2019/7/31.
 */
const LOG_TAG = "Provisioning"

export class ProvisioningController {
    /**
     * not in provisioning flow
     */
    public static readonly STATE_IDLE = 0x1000;
    public static readonly STATE_RECORDS_GET = 0x0010;
    public static readonly STATE_RECORD_REQUEST = 0x0011;
    /**
     * sent provisioning invite pdu
     */
    public static readonly STATE_INVITE = 0x1001;
    /**
     * received provisioning capability
     */
    public static readonly STATE_CAPABILITY = 0x1002;
    /**
     * sent provisioning start
     */
    public static readonly STATE_START = 0x1003;
    /**
     * sent provisioning pub key
     */
    public static readonly STATE_PUB_KEY_SENT = 0x1004;
    /**
     * received provisioning pub key
     */
    public static readonly STATE_PUB_KEY_RECEIVED = 0x1005;
    //    public static readonly STATE_INPUT_COMPLETE = 0x1005;

    /**
     * sent provisioning confirm
     */
    public static readonly STATE_CONFIRM_SENT = 0x1006;
    /**
     * received provisioning confirm
     */
    public static readonly STATE_CONFIRM_RECEIVED = 0x1007;
    /**
     * sent provisioning random
     */
    public static readonly STATE_RANDOM_SENT = 0x1008;
    /**
     * received provisioning random
     */
    public static readonly STATE_RANDOM_RECEIVED = 0x1009;
    /**
     * sent provisioning data
     */
    public static readonly STATE_DATA = 0x100A;
    /**
     * received provisioning complete, success!
     */
    public static readonly STATE_COMPLETE = 0x100B;
    /**
     * received provisioning fail, or params check err!
     */
    public static readonly STATE_FAILED = 0x100C;
    private state = ProvisioningController.STATE_IDLE
    private static readonly AUTH_NO_OOB = new Uint8Array([
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ])
    private static readonly AUTH_NO_OOB_EPA = new Uint8Array([
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ])
    private static readonly TIMEOUT_PROVISIONING = 60 * 1000;
    /**
     * Certificate-based Provisioning URI
     */
    private static readonly RECORD_ID_URI = 0x0000;
    /**
     * Device Certificate
     */
    private static readonly RECORD_ID_DEVICE = 0x0001;
    /**
     * Intermediate Certificate
     * 0x0002 or larger
     */
    private static readonly RECORD_ID_INTERMEDIATE = 0x0002;
    /**
     * certificate record fragment size
     */
    private static readonly MAX_FRAGMENT_SIZE = 20;
    /**
     * This is an instance of a ProvisioningBridge class,
     * which is responsible for handling the communication between the provisioning server and the device being provisioned.
     */
    private mProvisioningBridge?: ProvisioningBridge;
    /**
     * This variable stores the ID of a provisioning record.
     */
    private recordId = -1;
    /**
     * This variable stores the index of a provisioning record.
     */
    private recordIndex = -1;
    /**
     * This is a sparse array that stores the contents of provisioning records.
     * The key is the record ID and the value is the record data.
     */
    private recordContents = new Map<number, Uint8Array>()
    /**
     * This variable stores the offset of a fragment of record data.
     */
    private fragmentOffset = 0
    /**
     * This variable stores the data of a provisioning record.
     */
    private recordData: Uint8Array | undefined
    /**
     * public key in certificate get by record response data
     */
    private recordPubKey: Uint8Array | undefined
    /**
     * This is an instance of a ProvisioningRecordsListPDU class, which represents a list of provisioning records.
     */
    private recordsListPDU: ProvisioningRecordsListPDU | undefined
    /**
     * This is an instance of a ProvisioningInvitePDU class, which represents an invite message in the provisioning process.
     */
    private invitePDU: ProvisioningInvitePDU | undefined;
    /**
     * This is an instance of a ProvisioningStartPDU class, which represents a start message in the provisioning process.
     */
    private startPDU: ProvisioningStartPDU | undefined
    /**
     * This is an instance of a ProvisioningCapabilityPDU class, which represents the capability of the provisioning server.
     */
    private pvCapability?: ProvisioningCapabilityPDU
    /**
     * This is an instance of a ProvisioningPubKeyPDU class, which represents the public key of the provisioner.
     */
    private provisionerPubKeyPDU: ProvisioningPubKeyPDU | undefined
    /**
     * This is an instance of a ProvisioningPubKeyPDU class, which represents the public key of the device being provisioned.
     */
    private devicePubKeyPDU: ProvisioningPubKeyPDU | undefined
    /**
     * This variable stores the key pair (public and private key) of the provisioner.
     */
    private provisionerKeyPair?: cryptoFramework.KeyPair
    /**
     * This variable stores the secret key generated by the device using Elliptic Curve Diffie-Hellman (ECDH) algorithm.
     */
    private deviceECDHSecret: Uint8Array | undefined
    /**
     * This variable stores the random value generated by the provisioner.
     */
    private provisionerRandom: Uint8Array | undefined
    /**
     * This variable stores the confirmation value generated by the provisioner.
     */
    private provisionerConfirm: Uint8Array | undefined
    /**
     * This variable stores the random value generated by the device.
     */
    private deviceRandom?: Uint8Array
    /**
     * This variable stores the confirmation value generated by the device.
     */
    private deviceConfirm?: Uint8Array
    //    private byte[] deviceKey;


    //    private ProvisioningParams mProvisioningParams;

    /**
     * target device
     */
    private mProvisioningDevice?: ProvisioningDevice
    public static readonly ROOT_CERT_IN_PTS =
        hexToBytes("308202873082022EA003020102020101300A06082A8648CE3D04030230819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533365A170D3330313030343138353533365A30819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D3059301306072A8648CE3D020106082A8648CE3D03010703420004D183194D0257D2141D3C5566639B4F7AF0834945349B7207DDDA730693FD2B56B8A83AC49FD22517D28D0EED9AE3F1D43A221FE37919B66E9418FF9618C2081EA35D305B301D0603551D0E041604142556CB5D177EFA709C7E05CCB7418A3B714C0A77301F0603551D230418301680142556CB5D177EFA709C7E05CCB7418A3B714C0A77300C0603551D13040530030101FF300B0603551D0F040403020106300A06082A8648CE3D040302034700304402207C9696D079CB866BEA5EAAC230FB52EB5BC8EFC72F46E25F7B1E7990401BC74202206B6FD9F0DBAC54D4121045FD0E4AC06D5F3306BF8DCAF32F2D701C1445A62EF8");
    // root cert in pts
    private rootCert = ProvisioningController.ROOT_CERT_IN_PTS;
    private provisionTimeoutId = 0;

    //HW_ROOT_CERT =  Arrays.hexToBytes("30820221308201C9A0030201020214738723BD08D202CB5C2FCB7F1B45CF5D14A292C6300A06082A8648CE3D0403023061310B3009060355040613026161310B300906035504080C026161310B300906035504070C026161310B3009060355040A0C026161310B3009060355040B0C026161310B300906035504030C0261613111300F06092A864886F70D010901160261613020170D3231303731343130343534335A180F32313231303632303130343534335A3061310B3009060355040613026161310B300906035504080C026161310B300906035504070C026161310B3009060355040A0C026161310B3009060355040B0C026161310B300906035504030C0261613111300F06092A864886F70D010901160261613059301306072A8648CE3D020106082A8648CE3D030107034200047CA0DF06B773604D9C41E68B89D375B39D8369B159D903AB41EA3744F61F0E6C1A35A19A1B618D36475E429635DDFEAEBD0E495DDF89B962124D52658E73AFC6A35D305B301D0603551D0E04160414584EBEF28F1459636393B7FE45C3EFBE317BD944301F0603551D23041830168014584EBEF28F1459636393B7FE45C3EFBE317BD944300C0603551D13040530030101FF300B0603551D0F040403020106300A06082A8648CE3D0403020346003043021F5D623DB722C87AD2416906A5EBC031AB76C79B2C146AEF765AD309BDBF822002203DE73217AD01E72AF3425E6465E15952516040C346F195FD02D10DE54DA4F740");

    /**
     * Initializes a new instance of the ProvisioningController class.
     *
     * @param handlerThread The handler thread to use for delayed operations.
     */
    public constructor() {
    }

    /**
     * Sets the provisioning bridge for the controller.
     *
     * @param provisioningBridge The provisioning bridge to set.
     */
    public setProvisioningBridge(provisioningBridge: ProvisioningBridge) {
        this.mProvisioningBridge = provisioningBridge;
    }

    /**
     * Gets the provisioning device associated with the controller.
     *
     * @return The provisioning device.
     */
    public getProvisioningDevice(): ProvisioningDevice | undefined {
        return this.mProvisioningDevice;
    }

    /**
     * starts the provisioning process by setting up necessary configurations and initiating a provisioning request.
     *
     * @param device target device
     */
    public begin(device: ProvisioningDevice) {
        this.log("begin -- " + bytesToHex(device.deviceUUID));
        this.mProvisioningDevice = device;
        if (device.rootCert) {
            this.rootCert = device.rootCert;
        } else {
            this.rootCert = ProvisioningController.ROOT_CERT_IN_PTS;
        }
        clearTimeout(this.provisionTimeoutId)
        this.provisionTimeoutId = setTimeout(() => {
            this.onProvisionTimeout()
        }, ProvisioningController.TIMEOUT_PROVISIONING)

        let oobInfo = device.oobInfo
        if (!device.autoStart && isCertSupported(oobInfo) && isPvRecordSupported(oobInfo)) {
            this.provisionRecordsGet();
        } else {
            this.provisionInvite();
        }

    }

    /**
     * cancels any ongoing provisioning process and resets the controller to an idle state.
     */
    public clear() {
        clearTimeout(this.provisionTimeoutId)
        this.state = ProvisioningController.STATE_IDLE;
    }

    /**
     * This method is used to handle incoming provisioning notifications.
     * It checks the current state of the device and performs the appropriate action based on the type of notification received.
     * If the device is in the idle state, a warning log is generated and the method returns.
     * The method then extracts the provisioning PDU type and data from the received byte array.
     * Based on the provisioning PDU type, the method calls the corresponding handler method to process the data.
     * The possible provisioning PDU types and their corresponding handler methods are as follows:
     * - TYPE_CAPABILITIES: Calls the onCapabilityReceived() method with the provisioning data.
     * - TYPE_PUBLIC_KEY: Calls the onPubKeyReceived() method with the provisioning data.
     * - TYPE_CONFIRMATION: Calls the onConfirmReceived() method with the provisioning data.
     * - TYPE_RANDOM: Calls the onRandomReceived() method with the provisioning data.
     * - TYPE_COMPLETE: Calls the onProvisionSuccess() method.
     * - TYPE_FAILED: Calls the onProvisionFail() method with a failure message.
     * - TYPE_RECORDS_LIST: Calls the onRecordListReceived() method with the provisioning data.
     * - TYPE_RECORD_RESPONSE: Calls the onRecordResponse() method with the provisioning data.
     *
     * @param provisioningPdu The byte array containing the provisioning PDU.
     */
    public pushNotification(provisioningPdu: Uint8Array) {
        if (this.state == ProvisioningController.STATE_IDLE) {
            this.log("received notification when idle");
            return;
        }
        this.log("provisioning pdu received: " + bytesToHex(provisioningPdu, ""));
        let provisioningPduType = provisioningPdu[0];
        let provisioningData = provisioningPdu.slice(1)
        switch (provisioningPduType) {
            case ProvisioningPDU.TYPE_CAPABILITIES:
                this.onCapabilityReceived(provisioningData);
                break;

            case ProvisioningPDU.TYPE_PUBLIC_KEY:
                this.onPubKeyReceived(provisioningData);
                break;

            case ProvisioningPDU.TYPE_CONFIRMATION:
                this.onConfirmReceived(provisioningData);
                break;

            case ProvisioningPDU.TYPE_RANDOM:
                this.onRandomReceived(provisioningData);
                break;

            case ProvisioningPDU.TYPE_COMPLETE:
                this.onProvisionSuccess();
                break;
            case ProvisioningPDU.TYPE_FAILED:
                this.onProvisionFail("failed notification received");
                break;

            case ProvisioningPDU.TYPE_RECORDS_LIST:
                this.onRecordListReceived(provisioningData);
                break;

            case ProvisioningPDU.TYPE_RECORD_RESPONSE:
                this.onRecordResponse(provisioningData);
                break;
        }
    }

    /**
     * This method is called when the provisioning process is successful.
     * It updates the provisioning state to STATE_COMPLETE and provides a success message.
     * It then calls the onProvisionComplete() method.
     */
    private onProvisionSuccess() {
        this.updateProvisioningState(ProvisioningController.STATE_COMPLETE, "Provision Success");
        this.onProvisionComplete();
    }

    /**
     * This method is called after the provisioning process is complete.
     * It sets the state to STATE_IDLE and removes any pending provisioning timeout tasks.
     */
    private onProvisionComplete() {
        this.state = ProvisioningController.STATE_IDLE;
        clearTimeout(this.provisionTimeoutId)
    }

    /**
     * This method is used to retrieve the authentication value for a device during provisioning.
     * It first checks if the device supports static OOB (Out of Band) authentication and if an authentication value has been set for the device.
     * If so, it returns the authentication value. If not, it checks if the device supports HMAC (Hash-based Message Authentication Code) algorithm and returns the appropriate authentication value accordingly.
     * If neither static OOB nor HMAC is supported, it returns a default authentication value.
     *
     * @return auth
     */
    private getAuthValue(): Uint8Array {
        let auth = this.mProvisioningDevice!.authValue;
        if (!this.pvCapability) {
            return ProvisioningController.AUTH_NO_OOB
        }
        if (this.pvCapability.isStaticOOBSupported() && auth) {
            // If the device does not support epa, only the first 16 bytes are fetched
            if (!this.pvCapability.isHMacAlgorithmSupported() && auth.length == 32) {
                return auth.slice(0, 16)
            }
            return auth;
        } else {
            if (this.pvCapability && this.pvCapability.isHMacAlgorithmSupported()) {
                return ProvisioningController.AUTH_NO_OOB_EPA;
            }
            return ProvisioningController.AUTH_NO_OOB;
        }
    }

    /**
     * Updates the provisioning state and notifies the provisioning bridge if it is not null.
     *
     * @param state The new provisioning state.
     * @param desc  The description of the provisioning state.
     */
    private updateProvisioningState(state: number, desc: string) {
        this.log(`provisioning state update: state -- ${state} desc -- ${desc}`);
        this.state = state;
        if (this.mProvisioningBridge) {
            this.mProvisioningBridge.onProvisionStateChanged(state, desc);
        }
    }

    /**
     * This method is used to retrieve records from a provisioning server.
     * It first updates the provisioning state to indicate that the "Records Get" operation is being performed.
     * Then, it creates a ProvisioningRecordsGetPDU object, which represents the PDU (Protocol Data Unit) for the records get operation.
     * Finally, it sends the PDU to the provisioning server using the sendProvisionPDU() method.
     *
     * @see #onRecordListReceived(byte[])
     */
    private provisionRecordsGet() {
        this.updateProvisioningState(ProvisioningController.STATE_RECORDS_GET, "Records Get");
        let recordsGetPDU = new ProvisioningRecordsGetPDU();
        this.sendProvisionPDU(recordsGetPDU);
    }

    /**
     * send record request message to get the provision record
     */
    private provisionRecordRequest() {
        this.log(`Record Request recordID=${this.recordId.toString(16).padStart(4)} offset=${this.fragmentOffset}}`);
        let recordRequestPDU =
            new ProvisioningRecordRequestPDU(this.recordId, this.fragmentOffset,
                ProvisioningController.MAX_FRAGMENT_SIZE);
        this.sendProvisionPDU(recordRequestPDU);
    }

    /**
     * send provision invite pdu
     * It creates a new ProvisioningInvitePDU object with a given attention value.
     * It then updates the provisioning state to "Invite" and sends the invitePDU using the sendProvisionPDU method.
     */
    private provisionInvite() {
        //        byte attention = 0;
        let attention = this.mProvisioningDevice!.attentionDuration;
        this.invitePDU = new ProvisioningInvitePDU(attention);
        this.updateProvisioningState(ProvisioningController.STATE_INVITE, "Invite");
        this.sendProvisionPDU(this.invitePDU);
    }


    /**
     * Called to initiate the provisioning process.
     * It sets up the provisioning start PDU (Protocol Data Unit) and sends it to the device being provisioned.
     * The method takes a boolean parameter  isStaticOOB  to determine if static Out-of-Band (OOB) authentication is used.
     * It also sets the public key and algorithm for the provisioning start PDU.
     *
     * @param isStaticOOB use static oob
     */
    private provisionStart(isStaticOOB: boolean) {
        let useOOBPublicKey = this.recordPubKey != null;
        this.startPDU = ProvisioningStartPDU.getSimple(useOOBPublicKey, isStaticOOB);
        this.startPDU.setPublicKey(this.pvCapability!.publicKeyType == 1 && this.recordPubKey != null);
        //        byte algo = (byte) (pvCapability.isHMacAlgorithmSupported() ? 1 : 0);
        let algo = this.getSupportAlg();
        this.startPDU.setAlgorithm(algo);
        this.updateProvisioningState(ProvisioningController.STATE_START,
            "Start - use static oob?" + isStaticOOB + " - algo:" + algo);
        this.sendProvisionPDU(this.startPDU);
    }

    private getSupportAlg() {
        if (!this.pvCapability!.isHMacAlgorithmSupported()) {
            return 0;
        }
        let auth = this.mProvisioningDevice!.authValue;
        if (auth && auth.length == 16) {
            return 0;
        }
        return 1;
    }

    /**
     * called to send the public key to the device being provisioned.
     * It retrieves the public key PDU and sends it to the device.
     */
    private provisionSendPubKey() {
        let pubKeyPDU = this.getPublicKey();
        if (!pubKeyPDU) {
            this.onProvisionFail("get public key error")
            return
        }
        this.updateProvisioningState(ProvisioningController.STATE_PUB_KEY_SENT,
            "Send Public Key : " + bytesToHexString(pubKeyPDU.toBytes()));
        this.sendProvisionPDU(pubKeyPDU);
    }

    /**
     * called when the capability data is received from the device being provisioned.
     * It checks if the provisioning state is in the invite state, and if not, logs a warning and returns.
     * It then parses the capability data and updates the provisioning state.
     * It sets the device capability in the  mProvisioningDevice  object.
     * If static OOB authentication is supported and the authentication value is not found, it checks if auto-use-no-OOB is enabled.
     * If it is, it sets the useStaticOOB flag to false. Otherwise, it calls the  onProvisionFail  method and returns.
     * Finally, it calls the  provisionStart  and  provisionSendPubKey  methods, and if the public key type is 1 and the record public key is not null, it calls the  onPubKeyReceived  method.
     *
     * @param capData device capablility data
     */
    public onCapabilityReceived(capData: Uint8Array) {
        if (this.state != ProvisioningController.STATE_INVITE) {
            this.logWithLevel(" capability received when not inviting", LOG_LEVEL_WARN);
            return;
        }

        this.pvCapability = ProvisioningCapabilityPDU.fromBytes(capData);
        this.mProvisioningDevice!.deviceCapability = this.pvCapability;
        this.updateProvisioningState(ProvisioningController.STATE_CAPABILITY,
            "Capability Received: " + this.pvCapability);

        if (this.mProvisioningDevice!.autoStart) {
            this.continueProvision(this.mProvisioningDevice!.unicastAddress);
        } else {
            //  hold and wait for continue
        }
    }


    public continueProvision(address: number) {
        let useStaticOOB = this.pvCapability!.isStaticOOBSupported();

        this.mProvisioningDevice!.unicastAddress = address;
        if (useStaticOOB && this.mProvisioningDevice!.authValue) {
            if (this.mProvisioningDevice!.autoUseNoOOB) {
                // use no oob
                useStaticOOB = false;
            } else {
                this.onProvisionFail("authValue not found when device static oob supported!");
                return;
            }
        }
        this.provisionStart(useStaticOOB);
        this.provisionSendPubKey();
        if (this.pvCapability!.publicKeyType == 1 && this.recordPubKey) {
            this.onPubKeyReceived(this.recordPubKey!);
        }
    }

    /**
     * called when the public key is received from the device being provisioned.
     * It checks if the provisioning state is in the pub key sent state, and if not, logs a warning and returns.
     * It updates the provisioning state and logs the received public key.
     * It then parses the public key data and generates the ECDH secret using the provisioner's private key.
     * If the secret is null, it calls the  onProvisionFail  method and returns.
     * Otherwise, it logs the secret and calls the  sendConfirm  method.
     *
     * @param pubKeyData
     */
    private onPubKeyReceived(pubKeyData: Uint8Array) {
        if (this.state != ProvisioningController.STATE_PUB_KEY_SENT) {
            this.logWithLevel(" pub key received when not pub key sent", LOG_LEVEL_WARN);
            return;
        }

        this.updateProvisioningState(ProvisioningController.STATE_PUB_KEY_RECEIVED, "Public Key received");
        log("pub key received: " + bytesToHexString(pubKeyData, ""));
        this.devicePubKeyPDU = ProvisioningPubKeyPDU.fromBytes(pubKeyData);
        this.deviceECDHSecret = generateECDH(pubKeyData, this.provisionerKeyPair!);
        if (!this.deviceECDHSecret) {
            log("pub key received ##4 : " + bytesToHexString(this.deviceECDHSecret, ""));
            this.onProvisionFail("invalid public key");
            return;
        }
        log("get secret: " + bytesToHexString(this.deviceECDHSecret, ""));
        this.sendConfirm();
    }

    /**
     * Called to send the confirm message to the device being provisioned.
     * It generates the confirm value, updates the provisioning state, and sends the confirm PDU to the device.
     */
    private sendConfirm() {
        let confirm = this.getConfirm();
        log("provisioner confirm - " + bytesToHexString(confirm));
        this.provisionerConfirm = confirm;
        let confirmPDU = new ProvisioningConfirmPDU(this.provisionerConfirm!);
        this.updateProvisioningState(ProvisioningController.STATE_CONFIRM_SENT, "Send confirm");
        this.sendProvisionPDU(confirmPDU);
    }

    /*
    If the Algorithm field is BTM_ECDH_P256_HMAC_SHA256_AES_CCM, the confirmation value of the Provisioner is a 256-bit value, the confirmation value of the device is a 256-bit value, and they are computed using:
ConfirmationProvisioner = HMAC-SHA-256ConfirmationKey (RandomProvisioner)
ConfirmationDevice = HMAC-SHA-256ConfirmationKey (RandomDevice)
Where:
ConfirmationKey = k5(ECDHSecret || AuthValue, ConfirmationSalt, “prck256”)
ConfirmationSalt = s2(ConfirmationInputs)
ConfirmationInputs = ProvisioningInvitePDUValue || ProvisioningCapabilitiesPDUValue || ProvisioningStartPDUValue || PublicKeyProvisioner || PublicKeyDevice
     */

    /**
     * This method is used to generate a confirmation value in the form of a byte array. The confirmation value is used for authentication purposes.
     * <p>
     * The method first calls the confirmAssembly() method to retrieve the input data for confirmation. It then initializes byte arrays for the salt, confirmation key, and authentication value.
     * <p>
     * Next, it checks if the encryption algorithm is HMAC. If it is, it calculates the salt value using the Encipher.s2() method. It then concatenates the deviceECDHSecret and authValue arrays to create a new array called secAuth. The confirmation key is generated using the Encipher.k5() method with secAuth, salt, and the PRCK256 algorithm. The provisionerRandom byte array is generated using the Arrays.generateRandom() method. Finally, the method returns the result of the Encipher.hMacSha256() method, which calculates the HMAC-SHA256 value using the provisionerRandom and confirmationKey arrays.
     * <p>
     * If the encryption algorithm is not HMAC, the method generates the salt value using the Encipher.generateSalt() method with the confirmInput array. The confirmation key is generated using the Encipher.k1() method with the deviceECDHSecret, salt, and the PRCK algorithm. The provisionerRandom byte array is generated using the Arrays.generateRandom() method. The confirmData array is created by concatenating the provisionerRandom and authValue arrays. Finally, the method returns the result of the Encipher.aesCmac() method, which calculates the AES-CMAC value using the confirmData and confirmationKey arrays.
     *
     * @return confirm data
     */
    private getConfirm(): Uint8Array {
        let confirmInput = this.confirmAssembly();
        let salt: Uint8Array;
        let confirmationKey: Uint8Array;
        let authValue = this.getAuthValue();

        // check alg
        if (this.isHmac()) {
            salt = s2(confirmInput);
            // ConfirmationKey = k5(ECDHSecret || AuthValue, ConfirmationSalt, “prck256”)
            let secAuth = new Uint8Array(this.deviceECDHSecret!.length + authValue.length)
            secAuth.set(this.deviceECDHSecret!, 0)
            secAuth.set(authValue, this.deviceECDHSecret!.length)
            //            confirmationKey = Encipher.k5(deviceECDHSecret, salt, Encipher.PRCK256);
            confirmationKey = k5(secAuth, salt, PRCK256);
            this.provisionerRandom = generateRandom(32);
            return hMacSha256(this.provisionerRandom, confirmationKey);
        } else {
            salt = generateSalt(confirmInput);
            confirmationKey = k1(this.deviceECDHSecret!, salt, PRCK);
            this.provisionerRandom = generateRandom(16);
            let confirmData = new Uint8Array(this.provisionerRandom.length + authValue.length)
            confirmData.set(this.provisionerRandom, 0)
            confirmData.set(authValue, this.provisionerRandom.length)
            return aesCmac(confirmData, confirmationKey);
        }
    }

    /**
     * Checks if the HMAC algorithm is supported by the current capability.
     *
     * @return true if the HMAC algorithm is supported, false otherwise.
     */
    private isHmac(): boolean {
        //        return pvCapability != null && pvCapability.isHMacAlgorithmSupported();
        return this.pvCapability != undefined && this.getSupportAlg() == 1;
    }

    /**
     * called when a confirmation message is received during the provisioning process.
     *
     * @param confirm confirm data
     */
    private onConfirmReceived(confirm: Uint8Array) {
        if (this.state != ProvisioningController.STATE_CONFIRM_SENT) {
            this.logWithLevel(" confirm received when not confirm sent", LOG_LEVEL_WARN);
            return;
        }

        this.updateProvisioningState(ProvisioningController.STATE_CONFIRM_RECEIVED, "Confirm received");

        this.deviceConfirm = confirm;

        if (bytesEquals(this.provisionerConfirm!, this.deviceConfirm)) {
            this.onProvisionFail("received the same confirm as local");
            return;
        }

        this.sendRandom();
    }

    /**
     * called when a random value is received during the provisioning process.
     *
     * @param random device random data
     */
    private onRandomReceived(random: Uint8Array) {
        if (this.state != ProvisioningController.STATE_RANDOM_SENT) {
            this.logWithLevel(" random received when not random sent", LOG_LEVEL_WARN);
            return;
        }

        this.updateProvisioningState(ProvisioningController.STATE_RANDOM_RECEIVED, "Random received");
        this.deviceRandom = random;


        if (bytesEquals(this.provisionerRandom!, this.deviceRandom)) {
            this.onProvisionFail("received the same random as local");
            return;
        }

        let pass = this.checkDeviceConfirm(random);
        if (pass) {
            this.sendProvisionData();
        } else {
            this.onProvisionFail("device confirm check err!");
        }
    }

    /**
     * called when a list of records is received.
     *
     * @param recordsData record data
     */
    private onRecordListReceived(recordsData: Uint8Array) {
        if (this.state != ProvisioningController.STATE_RECORDS_GET) {
            this.logWithLevel("record list received when not record list get", LOG_LEVEL_WARN);
            return;
        }
        // 0D 0000 0000 0001
        this.recordsListPDU = ProvisioningRecordsListPDU.fromBytes(recordsData);
        if (this.recordsListPDU.recordsList.length == 0) {
            this.onProvisionFail("Device Certificate not found");
            return;
        }

        this.recordIndex = 0;
        this.recordContents.clear();
        this.getNextRecord();
    }

    /**
     * used to retrieve the next record from a list of records.
     *
     * @see #onAllRecordsComplete
     */
    private getNextRecord() {
        log("get next record");
        if (this.recordIndex >= this.recordsListPDU!.recordsList.length) {
            this.onAllRecordsComplete();
            return;
        }
        this.recordId = this.recordsListPDU!.recordsList[this.recordIndex];
        this.fragmentOffset = 0;
        this.recordData = undefined;
        this.recordPubKey = undefined;
        this.updateProvisioningState(ProvisioningController.STATE_RECORD_REQUEST, "Record Request");
        this.provisionRecordRequest();
    }

    /**
     * handles the response received after sending a record request during the provisioning process.
     *
     * @param recordResponseData record response
     */
    private onRecordResponse(recordResponseData: Uint8Array) {
        if (this.state != ProvisioningController.STATE_RECORD_REQUEST) {
            this.logWithLevel("record response received when not record request", LOG_LEVEL_WARN);
            return;
        }
        let responsePDU = ProvisioningRecordResponsePDU.fromBytes(recordResponseData);
        this.log(responsePDU.toString());
        if (responsePDU.status != ProvisioningRecordResponsePDU.STATUS_SUCCESS || responsePDU.data == null) {
            this.onProvisionFail("record response error");
            return;
        }
        this.compositeResponseData(responsePDU.data);

        if (this.recordData!.length >= responsePDU.totalLength!) {
            this.onRecordResponseComplete();
        } else {
            this.fragmentOffset = this.fragmentOffset + responsePDU.data.length;
            this.provisionRecordRequest();
        }
    }

    /**
     * combine two sets of byte data into a single composite byte array.
     *
     * @param newRecordData new record data
     */
    private compositeResponseData(newRecordData: Uint8Array) {
        if (this.recordData == null) {
            this.recordData = newRecordData;
        } else {
            //            recordData = ByteBuffer.allocate(recordData.length + newRecordData.length).put(recordData).put(newRecordData).array();
            let re = new Uint8Array(this.recordData.length + newRecordData.length)
            re.set(this.recordData)
            re.set(newRecordData, this.recordData.length)
            this.recordData = re;
        }
    }

    /**
     * called when the response for recording is complete.
     */
    private onRecordResponseComplete() {
        log("complete record: " + this.recordId + " -- " + bytesToHexString(this.recordData!));
        this.recordContents.set(this.recordId, this.recordData!.slice());
        this.recordIndex++;
        this.getNextRecord();
    }

    /**
     * This method is called when all records have been processed.
     */
    private onAllRecordsComplete() {
        if (this.recordContents.size == 0) {
            this.onProvisionFail("no records found");
            return;
        }
        // let hasUriRecordId = this.recordContents.has(ProvisioningController.RECORD_ID_URI)
        let uriRecord = this.recordContents.get(ProvisioningController.RECORD_ID_URI)

        if (uriRecord) {
            // contains Certificate-based Provisioning URI
            let uriStr = bytesToString(uriRecord)
            log("Certificate-based Provisioning URI found: " + uriStr);
            // Uri uri = Uri.parse(uriStr);
            // skip HTTP retrieve
            // ptswebapiprod.azurewebsites.net/api/meshcert/v/a  for no-oob
            // ptswebapiprod.azurewebsites.net/api/meshcert/v/b  for static-oob
            let ROOT_CERT =
                hexToBytes("308202873082022EA003020102020101300A06082A8648CE3D04030230819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533365A170D3330313030343138353533365A30819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D3059301306072A8648CE3D020106082A8648CE3D03010703420004D183194D0257D2141D3C5566639B4F7AF0834945349B7207DDDA730693FD2B56B8A83AC49FD22517D28D0EED9AE3F1D43A221FE37919B66E9418FF9618C2081EA35D305B301D0603551D0E041604142556CB5D177EFA709C7E05CCB7418A3B714C0A77301F0603551D230418301680142556CB5D177EFA709C7E05CCB7418A3B714C0A77300C0603551D13040530030101FF300B0603551D0F040403020106300A06082A8648CE3D040302034700304402207C9696D079CB866BEA5EAAC230FB52EB5BC8EFC72F46E25F7B1E7990401BC74202206B6FD9F0DBAC54D4121045FD0E4AC06D5F3306BF8DCAF32F2D701C1445A62EF8");
            let DEVICE_CERT_NOOOB =
                hexToBytes("30820250308201F6A003020102020104300A06082A8648CE3D04030230818F310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453311F301D06035504030C16496E7465726D65646961746520417574686F726974793124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533375A170D3330313030343138353533375A3077310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303059301306072A8648CE3D020106082A8648CE3D03010703420004F465E43FF23D3F1B9DC7DFC04DA8758184DBC966204796ECCF0D6CF5E16500CC0201D048BCBBD899EEEFC424164E33C201C2B010CA6B4D43A8A155CAD8ECB279A35A305830090603551D1304023000300B0603551D0F040403020308301D0603551D0E04160414E262F3584AB688EC882EA528ED8E5C442A71369F301F0603551D230418301680144ABE293903A8BB49FF1D327CFEB80985F4109C21300A06082A8648CE3D0403020348003045022100E029814E909DD3D81C1DC4843FD27A56209212818765356699912382EFF9F46102201BE5E9E8801C868F7C44574F3AB7056C42B8083D6A39D519FD92FA4C17D81D52");
            let DEVICE_CERT_STATICOOB =
                hexToBytes("3082027F30820224A003020102020103300A06082A8648CE3D04030230818F310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453311F301D06035504030C16496E7465726D65646961746520417574686F726974793124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533365A170D3330313030343138353533365A3077310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303059301306072A8648CE3D020106082A8648CE3D03010703420004F465E43FF23D3F1B9DC7DFC04DA8758184DBC966204796ECCF0D6CF5E16500CC0201D048BCBBD899EEEFC424164E33C201C2B010CA6B4D43A8A155CAD8ECB279A3818730818430090603551D1304023000300B0603551D0F040403020308301D0603551D0E04160414E262F3584AB688EC882EA528ED8E5C442A71369F301F0603551D230418301680144ABE293903A8BB49FF1D327CFEB80985F4109C21302A06146982E19DE491EAC0C283999CAA83FD8CC3D0D3670412041000000000000000000102030405060708300A06082A8648CE3D0403020349003046022100F7B504477EC2E5796644A0C5A95D864BF001CF96A5A180E243432CCE28FC5F9E0221008D816BEE11C36CDC1890189EDB85DF9A26998063EAC8EA55330B7F75003FEB98");
            let WEBSITE_INTERMEDIATE_CERT =
                hexToBytes("3082027A30820220A003020102020102300A06082A8648CE3D04030230819D310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453312D302B06035504030C2430303142444330382D313032312D304230452D304130432D3030304230453041304330303124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D301E170D3139303731383138353533365A170D3330313030343138353533365A30818F310B30090603550406130255533113301106035504080C0A57617368696E67746F6E31163014060355040A0C0D426C7565746F6F746820534947310C300A060355040B0C03505453311F301D06035504030C16496E7465726D65646961746520417574686F726974793124302206092A864886F70D0109011615737570706F727440626C7565746F6F74682E636F6D3059301306072A8648CE3D020106082A8648CE3D030107034200045463155F21C616953E8FAE69A9BCE445BE4FC8A3EB3412E7B2E7539D1CDBD86C64465F8F40A0A770A63C2AD1A51717DDE536F17865663252AB06B629E6BAE17EA35D305B301D0603551D0E041604144ABE293903A8BB49FF1D327CFEB80985F4109C21301F0603551D230418301680142556CB5D177EFA709C7E05CCB7418A3B714C0A77300C0603551D13040530030101FF300B0603551D0F040403020106300A06082A8648CE3D040302034800304502205C224FE15E7EE0FD2E499EC019D930950FF190E0E384D9B2FAB6259522E3EDF0022100D8846CC82D72EE1387875BB2B95C347776A2950F29A17E7863117203EEF0F5FE");
            this.validateDeviceCertWithCerts(uriStr.endsWith("a") ? DEVICE_CERT_NOOOB : DEVICE_CERT_STATICOOB,
                WEBSITE_INTERMEDIATE_CERT, ROOT_CERT);
        } else {
            let deviceCertData = this.recordContents.get(ProvisioningController.RECORD_ID_DEVICE);
            let intermediateCertData = this.recordContents.get(ProvisioningController.RECORD_ID_INTERMEDIATE);
            if (!deviceCertData) {
                this.onProvisionFail("device cert not found");
                return;
            }
            if (!intermediateCertData) {
                //                onProvisionFail("intermediate cert not found");
                log("check single device cert");
                this.validateDeviceCert(deviceCertData);
                return;
            }
            if (!this.rootCert) {
                this.onProvisionFail("root cert not found");
                return;
            }
            this.validateDeviceCertWithCerts(deviceCertData, intermediateCertData, this.rootCert);
        }
    }


    /**
     * validates a device certificate by checking if it is signed by a trusted root certificate.
     * If the validation fails, a provision failure message is sent.
     *
     * @param deviceCertData cert data
     */
    private async validateDeviceCert(deviceCertData: Uint8Array) {
        // check intermediate  by root
        let devCert = await checkCertificate(deviceCertData);
        if (!devCert) {
            this.onProvisionFail("device cert verify fail");
        } else {
            this.recordPubKey = getPublicKeyInCert(devCert);
            let staticOOB = getStaticOOBInCert(devCert);
            this.mProvisioningDevice!.authValue = staticOOB;
            log("public key in record: " + bytesToHexString(this.recordPubKey));
            this.provisionInvite();
        }
    }


    /**
     * validates a device certificate by checking if it is signed by a trusted root certificate.
     * If the validation fails, a provision failure message is sent.
     *
     * @param deviceCertData       device cert
     * @param intermediateCertData intermediate cert
     * @param rootCertData         root cert
     */
    private async validateDeviceCertWithCerts(deviceCertData: Uint8Array, intermediateCertData: Uint8Array,
        rootCertData: Uint8Array) {
        // check intermediate  by root
        let devCert = await checkCertificateByCa(intermediateCertData, rootCertData);
        if (!devCert) {
            this.onProvisionFail("intermediate cert verify fail");
            return;
        }

        let certificate = await checkCertificateByCa(deviceCertData, intermediateCertData);
        if (!certificate) {
            this.onProvisionFail("device cert verify fail");
        } else {
            this.recordPubKey = getPublicKeyInCert(certificate);
            let staticOOB = getStaticOOBInCert(certificate);
            this.mProvisioningDevice!.authValue = staticOOB;
            log("public key in record - 1 : " + bytesToHexString(this.recordPubKey));
            this.provisionInvite();
        }
    }

    /**
     * called when the provisioning process fails.
     * It updates the provisioning state to "failed" and provides a description of the failure.
     * It then calls the onProvisionComplete() method to handle any necessary clean-up or post-provisioning tasks.
     *
     * @param desc description
     */
    private onProvisionFail(desc: string) {
        loge("on provision fail : " + desc)
        this.updateProvisioningState(ProvisioningController.STATE_FAILED, desc);
        this.onProvisionComplete();
    }

    /**
     * send the provisioning data to the recipient.
     */
    private sendProvisionData() {
        let pvData = this.createProvisioningData();
        let provisioningDataPDU = new ProvisioningDataPDU(pvData);
        this.updateProvisioningState(ProvisioningController.STATE_DATA, "Send provisioning data");
        this.sendProvisionPDU(provisioningDataPDU);
    }

    /**
     * send provisioner random
     */
    private sendRandom() {
        let randomPDU = new ProvisioningRandomPDU(this.provisionerRandom!);
        this.updateProvisioningState(ProvisioningController.STATE_RANDOM_SENT, "Send random");
        this.sendProvisionPDU(randomPDU);
    }

    /**
     * This method generates a public key for provisioning.
     * It first generates a key pair using the Encipher class.
     * If the key pair is successfully generated, it retrieves the public key from the pair and extracts the x and y coordinates of the public key.
     * It then creates a ProvisioningPubKeyPDU object and sets the x and y values of the public key coordinates.
     * Finally, it logs the x and y values and returns the ProvisioningPubKeyPDU object. If the key pair generation fails, it throws a RuntimeException with an error message.
     *
     * @return public key pdu
     */
    private getPublicKey(): ProvisioningPubKeyPDU | undefined {
        this.provisionerKeyPair = generateKeyPair();
        if (this.provisionerKeyPair) {
            let publicKey = this.provisionerKeyPair.pubKey;
            let key = publicKey.getEncoded().data
            let x = key.slice(key.length - 64, key.length - 32)
            let y = key.slice(key.length - 32, key.length)
            this.provisionerPubKeyPDU = new ProvisioningPubKeyPDU();
            this.provisionerPubKeyPDU.x = x;
            this.provisionerPubKeyPDU.y = y;
            log("get key x: " + bytesToHexString(x, ""));
            log("get key y: " + bytesToHexString(y, ""));
            return this.provisionerPubKeyPDU;
        } else {
            return undefined
        }
    }

    // assemble random value

    /**
     * assembly of various pieces of data related to a device provisioning process.
     * It takes the byte arrays of
     * invitation PDU,
     * capability PDU,
     * start PDU,
     * provisioner public key PDU,
     * device public key PDU,
     * and combines them into a single byte array using a ByteBuffer.
     *
     * @return confirm
     */
    public confirmAssembly(): Uint8Array {
        let inviteData = this.invitePDU!.toBytes()!;
        let capData = this.pvCapability!.toBytes()!;
        let startData = this.startPDU!.toBytes()!;

        let provisionerPubKey = this.provisionerPubKeyPDU!.toBytes()!;

        let devicePubKey = this.devicePubKeyPDU!.toBytes()!;

        let len = inviteData.length
            + capData.length
            + startData.length
            + provisionerPubKey.length
            + devicePubKey.length;
        let buffer = new Uint8Array(len)
        let offset = 0

        buffer.set(inviteData, offset)
        offset += inviteData.length

        buffer.set(capData, offset)
        offset += capData.length

        buffer.set(startData, offset)
        offset += startData.length

        buffer.set(provisionerPubKey, offset)
        offset += provisionerPubKey.length

        buffer.set(devicePubKey, offset)
        return buffer
    }

    /**
     * This method is used to check the confirmation values of a device. It takes a random byte array as input and performs some calculations to generate a confirmation value.
     * <p>
     * First, it assembles the confirmation input by calling the confirmAssembly() method.
     * <p>
     * Then, it generates a salt using the confirmInput.
     * <p>
     * Next, it generates a confirmation key by combining the deviceECDHSecret and the authValue. The secAuth byte array is created by concatenating the deviceECDHSecret and authValue. This secAuth array is then used along with the salt to generate the confirmation key using the k5() method.
     * <p>
     * If the isHmac() method returns true, it uses the confirmationKey to calculate the confirmationValue using the hMacSha256() method.
     * <p>
     * If the isHmac() method returns false, it generates a confirmation key using the deviceECDHSecret and the salt using the k1() method. It then creates a ByteBuffer to hold the random byte array and the authValue. This buffer is converted to an array and passed along with the confirmation key to the aesCmac() method to generate the confirmationValue.
     * <p>
     * Finally, it compares the generated confirmationValue with the deviceConfirm value. If they are equal, it logs a message saying the confirmation values check passed and returns true. Otherwise, it logs an error message and returns false.
     *
     * @param random device random
     * @return check result
     */
    private checkDeviceConfirm(random: Uint8Array): boolean {

        let confirmInput = this.confirmAssembly();
        let salt: Uint8Array;
        let confirmationKey: Uint8Array;
        let authValue = this.getAuthValue();

        let confirmationValue: Uint8Array;
        if (this.isHmac()) {
            salt = s2(confirmInput);
            let secAuth = new Uint8Array(this.deviceECDHSecret!.length + authValue.length)
            secAuth.set(this.deviceECDHSecret!, 0)
            secAuth.set(authValue, this.deviceECDHSecret!.length)
            confirmationKey = k5(secAuth, salt, PRCK256);
            confirmationValue = hMacSha256(this.deviceRandom!, confirmationKey);
        } else {
            salt = generateSalt(confirmInput);
            confirmationKey = k1(this.deviceECDHSecret!, salt, PRCK);

            let confirmationData = new Uint8Array(random.length + authValue.length);
            confirmationData.set(random, 0)
            confirmationData.set(authValue, random.length)
            confirmationValue = aesCmac(confirmationData, confirmationKey);
        }

        confirmationValue
        if (bytesEquals(confirmationValue, this.deviceConfirm!)) {
            log("Confirmation values check pass");
            return true;
        } else {
            this.logWithLevel("Confirmation values check err", LOG_LEVEL_WARN);
        }

        return false;
    }

    /**
     * used to create provisioning data for a device.
     *
     * @return provision data
     */
    private createProvisioningData(): Uint8Array {

        let confirmationInputs = this.confirmAssembly();

        let confirmationSalt: Uint8Array;
        if (this.isHmac()) {
            confirmationSalt = s2(confirmationInputs);
        } else {
            confirmationSalt = generateSalt(confirmationInputs);
        }

        // 96 bytes in epa
        let provisioningSaltInput =
            new Uint8Array(confirmationSalt.length + this.provisionerRandom!.length + this.deviceRandom!.length);
        provisioningSaltInput.set(confirmationSalt, 0);
        provisioningSaltInput.set(this.provisionerRandom!, confirmationSalt.length);
        provisioningSaltInput.set(this.deviceRandom!, confirmationSalt.length + this.provisionerRandom!.length);

        let provisioningSalt = generateSalt(provisioningSaltInput);


        let sessionKey = k1(this.deviceECDHSecret!, provisioningSalt, PRSK);

        let nonce = k1(this.deviceECDHSecret!, provisioningSalt, PRSN);
        let sessionNonce = new Uint8Array(nonce.length - 3);
        // ByteBuffer nonceBuffer = ByteBuffer.allocate(nonce.length - 3);
        sessionNonce.set(nonce.slice(3))

        let deviceKey = k1(this.deviceECDHSecret!, provisioningSalt, PRDK);
        this.mProvisioningDevice!.deviceKey = deviceKey;

        log("device key: " + bytesToHexString(deviceKey, ""));
        log("provisioning data prepare: " + this.mProvisioningDevice?.unicastAddress);
        let provisioningData = this.mProvisioningDevice!.generateProvisioningData();

        log("unencrypted provision data: " + bytesToHexString(provisioningData, ""));
        let enData = ccm(provisioningData, sessionKey, sessionNonce, 8, true);
        log("encrypted provision data: " + bytesToHexString(enData, ""));
        return enData;
    }

    /**
     * Sends a ProvisioningStatePDU to the mProvisioningBridge.
     * Converts the ProvisioningStatePDU to a byte array and appends the state byte at the beginning.
     * If the byte array is empty or null, only the state byte is sent.
     */
    private sendProvisionPDU(pdu: ProvisioningStatePDU) {
        let data = pdu.toBytes();

        let re: Uint8Array;
        if (!data || data.length == 0) {
            re = new Uint8Array([pdu.getState()]);
        } else {
            re = new Uint8Array(data.length + 1);
            re[0] = pdu.getState();
            re.set(data, 1)
        }
        if (this.mProvisioningBridge) {
            log("prov pdu prepared: " + bytesToHexString(re, ":"))
            this.mProvisioningBridge.onCommandPrepared(ProxyPDU.TYPE_PROVISIONING_PDU, re);
        }
    }

    onProvisionTimeout() {
        this.onProvisionFail("provisioning timeout");
    }

    /**
     * log using DEBUG level
     *
     * @param logMessage log message
     */
    private log(logMessage: string) {
        log_m(logMessage, LOG_TAG)
    }

    /**
     * log using custom level
     *
     * @param logMessage log message
     * @param level      level
     */
    private logWithLevel(logMessage: string, level: number) {
        log_m(logMessage, LOG_TAG, level)
    }
}
