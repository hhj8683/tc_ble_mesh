/********************************************************************************************************
 * @file NetworkingController.java
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

import { ExtendBearerMode } from "./ExtendBearerMode";
import { NetworkingBridge } from "./NetworkingBridge";
import { ArkTSUtils, ArrayList, HashSet, Queue } from "@kit.ArkTS";
import {
    ADDRESS_BROADCAST,
    bit,
    DeviceKey,
    IV_MISSING,
    MeshKey,
    UNSIGNED_INTEGER_MAX,
    validUnicastAddress
} from "../../utils/MeshUtils";
import { MeshConfiguration } from "../../foundation/MeshConfiguration";
import { calculateNetKeyK2, generatePrivateBeaconKey, k4 } from "../../utils/Encipher";
import { logd, logw, LOG_LEVEL_WARN } from "../../utils/MeshLogger";
import { GattConnection } from "../../ble/GattConnection";
import { Opcode } from "../message/Opcode";
import { ByteOrder, bytesToHexString, num2bytes, num2Hex } from "../../utils/ArrayUtils";
import { MeshPrivateBeacon } from "./beacon/MeshPrivateBeacon";
import { SecureNetworkBeacon } from "./beacon/SecureNetworkBeacon";
import { ProxyConfigurationMessage } from "../proxy/ProxyConfigurationMessage";
import { MeshMessage } from "../message/MeshMessage";
import { AccessType } from "./AccessType";
import { AccessLayerPDU } from "./AccessLayerPDU";
import { UpperTransportAccessPDU , UpperTransportEncryptionSuite } from "./transport/upper/UpperTransportAccessPDU";
import { NetworkLayerPDU } from "./NetworkLayerPDU";
import { ProxyFilterType } from "../proxy/ProxyFilterType";
import { ProxySetFilterTypeMessage } from "../proxy/ProxySetFilterTypeMessage";
import { ProxyAddAddressMessage } from "../proxy/ProxyAddAddressMessage";
import { ProxyConfigurationPDU } from "../proxy/ProxyConfigurationPDU";
import { ProxyPDU } from "../proxy/ProxyPDU";
import { MeshBeaconPDU } from "./beacon/MeshBeaconPDU";
import { ProxyFilterStatusMessage } from "../proxy/ProxyFilterStatusMessage";
import { LowerTransportPDU } from "./transport/lower/LowerTransportPDU";
import { TransportControlMessagePDU } from "./transport/lower/TransportControlMessagePDU";
import { SegmentAcknowledgmentMessage } from "./transport/lower/SegmentAcknowledgmentMessage";
import { SegmentedAccessMessagePDU } from "./transport/lower/SegmentedAccessMessagePDU";
import { UnsegmentedAccessMessagePDU } from "./transport/lower/UnsegmentedAccessMessagePDU";
import { UnsegmentedControlMessagePDU } from "./transport/lower/UnsegmentedControlMessagePDU";
import { UpperTransportControlPDU } from "./transport/upper/UpperTransportControlPDU";

/**
 * managing networking operations.
 * networking packet partition and composition
 * Created by kee on 2019/7/31.
 */

const LOG_TAG = "Networking";

export class NetworkingController {
    // include mic(4)
    public static readonly UNSEGMENTED_TRANSPORT_PAYLOAD_MAX_LENGTH = 15;
    public static readonly UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT = 11;
    //    private static final int SEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH = 12;

    public static readonly UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG = 225;
    //    private static final int SEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH = UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH + 1;

    private extendBearerMode = ExtendBearerMode.NONE;
    // segmentedAccessLength = unsegmentedAccessLength + 1
    //    public int unsegmentedAccessLength = UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;


    private static readonly DEFAULT_SEQUENCE_NUMBER_UPDATE_STEP = 0x100;
    /**
     * executing iv update procedure when connect proxy node success
     * based on sequence number value >= THRESHOLD_SEQUENCE_NUMBER
     *
     * @see #checkSequenceNumber(byte[], byte[])
     */
    private static readonly THRESHOLD_SEQUENCE_NUMBER = 0xC00000;
    //    private final static int THRESHOLD_SEQUENCE_NUMBER = 0x88; // for test ivIndex Update


    /**
     * receive
     */
    private static readonly TRANSPORT_IN = 0x00;
    /**
     * transmit
     */
    private static readonly TRANSPORT_OUT = 0x01;
    /**
     * AtomicInteger  variable used to generate a sequence number
     */
    private mSequenceNumber = 1
    /**
     * boolean variable that indicates whether a private beacon has been received.
     */
    private privateBeaconReceived = false;
    /**
     * boolean variable that indicates whether the initialization vector (IV) is being updated.
     */
    private isIvUpdating = false;
    /**
     * nid
     */
    private nid = 0;
    /**
     * byte array used to store an encryption key
     */
    private encryptionKey: Uint8Array = new Uint8Array(0);
    /**
     * byte array used to store a privacy key.
     */
    private privacyKey: Uint8Array = new Uint8Array(0);
    /**
     * integer variable used to store a network key index.
     */
    private netKeyIndex = 0;
    /**
     * deviceKey and unicastAddress map
     */
    private deviceKeyMap: ArrayList<DeviceKey> = new ArrayList()
    /**
     * 0x1122334400AABBCC
     * ivIndex: 0x11223344
     * sequenceNumber: 0xAABBCC
     * save device sequence number(lower 24 bits) and ivIndex(higher 32 bits), compare with sequence number in received network pdu
     * if sequence number in network pud is not larger than saved sequence number, drop this pdu
     */
    private deviceSequenceNumberMap: Map<number, number> = new Map();
    /**
     * appKey and appKeyIndex map
     */
    private appKeyMap: Array<MeshKey> = []
    /**
     * from mesh configuration
     */
    private initIvIndex = 0;
    /**
     * unsigned 32-bit integer
     */
    private ivIndex = 0;
    /**
     * provisioner address
     */
    private localAddress = 0x7FFF;
    /**
     * direct connected node mesh address
     */
    private directAddress = 0;
    /**
     * model message transition id
     * All tid in message(if contains) will be valued by this variable
     */
    private tid = 0
    /**
     * 13 bits
     */
    private static readonly SEQ_ZERO_LIMIT = 0x1FFF;
    /**
     * received segmented message buffer by notification
     */
    private receivedSegmentedMessageBuffer: Map<number, SegmentedAccessMessagePDU> = new Map();
    private static readonly SEQ_AUTH_BUF_CAPACITY = 10;
    /**
     * segment completed auth buffer
     */
    private completedSeqAuthBuffer: Map<number, number> = new Map();
    /**
     * segment busy auth buffer
     */
    private busySeqAuthBuffer: Map<number, number> = new Map();
    /**
     * sent segmented message buffer
     */
    private sentSegmentedMessageBuffer: ArrayList<SegmentedAccessMessagePDU> = new ArrayList();
    //    private SparseArray<byte[]> receivedSegmentedMessageBuffer;

    /**
     * last seqAuth in segmented pdu
     * 0: segment idle
     * others: segment busy
     */
    private lastSeqAuth = 0;
    /**
     * last seqAuth source address
     */
    private lastSegSrc = 0;
    // if last RX segment packets complete
    private lastSegComplete = true;
    private mNetworkingBridge: NetworkingBridge
    private mSnoUpdateStep = NetworkingController.DEFAULT_SEQUENCE_NUMBER_UPDATE_STEP;
    // private Handler mDelayHandler;

    // private SegmentAckMessageSentTask mAccessSegCheckTask = new SegmentAckMessageSentTask();
    private mAccessSegCheckTask: SegmentAckMessageSentTask = {
        timerId: 0,
        src: 0,
        ttl: 0
    }
    private segmentTimeoutTask: SegmentTimeoutTask = {
        timerId: 0
    }
    /**
     * not receive any segment with current segAuth
     */
    private static readonly SEG_TIMEOUT = 10 * 1000;
    /**
     * Segment ack message task
     */
    // src: number;
    // ttl: number;

    // public void run() {
    //     sendSegmentBlockAck(src, ttl);
    // }




    // waiting for segment ack message
    // private SegmentBlockWaitingTask mSegmentBlockWaitingTask = new SegmentBlockWaitingTask();

    private reliableMessageTimeoutTask = 0
    private mSegmentBlockWaitingTask: SegmentBlockWaitingTask = {
        timerId: 0,
        ctl: 0,
        ttl: 0,
        src: 0,
        dst: 0
    }
    private static readonly BLOCK_ACK_WAITING_TIMEOUT = 15 * 1000;
    private segmentedBusy = false;
    // private Runnable segmentedMessageTimeoutTask = new SegmentedMessageTimeoutTask();
    private segmentedMessageTimeoutTask: SegmentedMessageTimeoutTask = { timerId: 0 }
    /**
     * sending message with ack
     * only one reliable message can be sent at one time
     * <p>
     * for reliable message,
     */
    private mSendingReliableMessage?: MeshMessage;
    /**
     * only one reliable message can be sent at one time,
     * if reliableBusy
     */
    private reliableBusy = false;
    // reliable
    private RELIABLE_SEGMENTED_LOCK: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();
    private mResponseMessageBuffer: HashSet<number> = new HashSet();
    private whiteList: Uint16Array = new Uint16Array(0)
    private proxyFilterInitStep = 0;
    private static readonly PROXY_FILTER_INIT_STEP_SET_TYPE = 1;
    private static readonly PROXY_FILTER_SET_STEP_ADD_ADR = 2;
    private static readonly PROXY_FILTER_INIT_TIMEOUT = 5 * 1000;
    /**
     * networking pdu sending prepared queue
     */
    // private final Queue<byte[]> mNetworkingQueue = new ConcurrentLinkedQueue<>();
    private mNetworkingQueue: Queue<Uint8Array> = new Queue();
    private NETWORK_QUEUE_LOCK: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();
    /**
     * used in blob transfer (firmware update)
     */
    //    public static final long NETWORK_INTERVAL_FOR_FU = 180; // 240 ms // 320


    public static readonly NETWORK_INTERVAL_DEFAULT = 240;
    // 240 ms // 320

    //    public static final long NETWORK_INTERVAL_DEFAULT = 10; // for test

    /**
     * network packet sent to un-direct connected node should push to queue, and send periodically
     */
    public static netPktSendInterval = NetworkingController.NETWORK_INTERVAL_DEFAULT;
    // 240 ms // 320

    /**
     * used as a lock object for synchronization purposes.
     */
    // private final Object mNetworkBusyLock = new Object();

    private mNetworkBusyLock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock();
    private networkingBusy = false;
    /**
     * store a private beacon key
     */
    private privateBeaconKey: Uint8Array = new Uint8Array(0);

    /**
     * initializes a new Handler object using the looper from the HandlerThread
     *
     * @param handlerThread thread
     */
    public constructor(networkingBridge: NetworkingBridge) {
        this.mNetworkingBridge = networkingBridge
    }


    private networkingSendingTask: number = 0

    /**
     * This method is used to set up the Mesh network configuration.
     * It takes a MeshConfiguration object as a parameter
     * and initializes various variables and keys based on the configuration provided.
     *
     * @param configuration config
     */
    public setup(configuration: MeshConfiguration) {
        this.clear();
        this.resetDirectAddress();
        this.initIvIndex = configuration.ivIndex & UNSIGNED_INTEGER_MAX;
        this.ivIndex = this.initIvIndex;
        let seqNo = configuration.sequenceNumber;
        this.mSequenceNumber = (this.initSequenceNumber(seqNo));
        this.netKeyIndex = configuration.netKeyIndex;
        let k2Output = calculateNetKeyK2(configuration.networkKey);
        this.nid = (k2Output[0][15] & 0x7F);
        this.encryptionKey = k2Output[1];
        this.privacyKey = k2Output[2];
        this.privateBeaconKey = generatePrivateBeaconKey(configuration.networkKey);
        this.appKeyMap = configuration.appKeyMap;
        this.deviceKeyMap = configuration.deviceKeyMap;

        this.localAddress = configuration.localAddress;
        this.whiteList = configuration.proxyFilterWhiteList;
    }

    /**
     * This method is used to clear/reset the state of various variables
     * and data structures in the class.
     */
    public clear() {
        clearTimeout(this.mAccessSegCheckTask.timerId)
        clearTimeout(this.mSegmentBlockWaitingTask.timerId)
        clearTimeout(this.segmentedMessageTimeoutTask.timerId)

        this.networkingBusy = false;
        this.segmentedBusy = false;
        this.reliableBusy = false
        while (this.mNetworkingQueue.length > 0) {
            this.mNetworkingQueue.pop();
        }
        // last lastSeqAuth and lastSegComplete should keep to avoid the complete seqAuth not saved in completedSeqAuthBuffer
        // for example , after key bind success, app send publish(segment packet) immediately,
        // if the device resend the aggregator segment packet, network
        //        this.lastSeqAuth = 0;
        //        this.lastSegSrc = 0;
        this.lastSegComplete = true;
        this.deviceSequenceNumberMap.clear()
        this.receivedSegmentedMessageBuffer.clear();
        this.sentSegmentedMessageBuffer.clear();
        this.mResponseMessageBuffer.clear();
        this.isIvUpdating = false;
        this.lastSegComplete = true;
        this.privateBeaconReceived = false;
    }

    /**
     * This method resets the direct address to 0.
     */
    public resetDirectAddress() {
        this.directAddress = 0;
    }

    /**
     * add a device key to the device key map. The device key is associated with a specific unicast address.
     *
     * @param unicastAddress address
     * @param deviceKey      device key value
     */
    public addDeviceKey(unicastAddress: number, deviceKey: Uint8Array) {
        this.deviceKeyMap.add({ address: unicastAddress, key: deviceKey });
    }

    /**
     * removes a device key from the device key map based on the provided unicast address.
     *
     * @param unicastAddress address
     */
    public removeDeviceKey(unicastAddress: number) {
        for (let i = 0; i < this.deviceKeyMap.length; i++) {
            if (this.deviceKeyMap[i].address == unicastAddress) {
                this.deviceKeyMap.removeByIndex(i)
                return
            }
        }
    }


    /**
     * Sets the extend bearer mode.
     *
     * @param extendBearerMode The extend bearer mode to be set.
     */
    public setExtendBearerMode(extendBearerMode: ExtendBearerMode) {
        logd("setExtendBearerMode: " + extendBearerMode);
        this.extendBearerMode = extendBearerMode;
    }

    /**
     * Retrieves the extend bearer mode.
     *
     * @return The extend bearer mode.
     */
    public getExtendBearerMode(): ExtendBearerMode {
        return this.extendBearerMode;
    }

    /**
     * This method calculates and returns the segment access length based on the destination address and opcode.
     * If the GATT connection MTU is less than UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG,
     * then the default unsegmented access payload max length is returned.
     * If the destination address matches the direct address and the opcode is BLOB_CHUNK_TRANSFER,
     * then the unsegmented access payload max length for long packets is returned.
     * If the extend bearer mode is set to NONE, then the default unsegmented access payload max length is returned.
     * If the extend bearer mode is set to GATT and the destination address matches the direct address,
     * then the unsegmented access payload max length for long packets is returned,
     * otherwise the default unsegmented access payload max length is returned.
     * If the extend bearer mode is set to GATT_ADV, then the unsegmented access payload max length for long packets is returned.
     * If none of the above conditions are met, the default unsegmented access payload max length is returned.
     *
     * @param dstAddress The destination address
     * @param opcode     The opcode
     * @return The segment access length
     */
    private getSegmentAccessLength(dstAddress: number, opcode: number): number {
        if (GattConnection.mtu < NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG) {
            return NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;
        }
        if (dstAddress == this.directAddress && opcode == Opcode.BLOB_CHUNK_TRANSFER) {
            return NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG;
        }
        switch (this.extendBearerMode) {
            case ExtendBearerMode.NONE:
                return NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;
            case ExtendBearerMode.GATT:
                return dstAddress == this.directAddress ?
                NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG :
                NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;
            case ExtendBearerMode.GATT_ADV:
                return NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_LONG;
        }
        return NetworkingController.UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH_DEFAULT;
    }

    /**
     * This method is used to save the completed sequence authentication value for a given source.
     * It is synchronized to ensure thread safety.
     *
     * @param src     The source value for which the sequence authentication is being saved.
     * @param seqAuth The sequence authentication value to be saved.
     */
    private async saveCompletedSeqAuth(src: number, seqAuth: number) {
        logd(`save complete seqAuth src: 0x${src.toString(16).padStart(4, '0')} -- seqAuth: 0x${seqAuth.toString(16)
            .padStart(14, '0')}`);
        this.completedSeqAuthBuffer.set(src, seqAuth);
    }

    /**
     * checks if a specific authentication sequence exists in the completed authentication buffer for a given source.
     * It compares the authentication sequence number (seqAuth) against the 0
     *
     * @param src     source address
     * @param seqAuth seqAuth
     * @return is target auth exists
     */
    private isCompleteAuthExists(src: number, seqAuth: number): boolean {
        return this.completedSeqAuthBuffer.get(src) == seqAuth;
    }

    /**
     * used to save the busy sequence authentication for a particular source.
     *
     * @param src     source address
     * @param seqAuth seqAuth
     */
    private async saveBusySeqAuth(src: number, seqAuth: number) {
        logd(`save busy seqAuth src: 0x${num2Hex(src, 4)} -- seqAuth: 0x${num2Hex(seqAuth, 14)}}`)
        this.busySeqAuthBuffer.set(src, seqAuth);
    }

    /**
     * checks if a specific authentication sequence exists in the busy authentication buffer for a given source.
     * It compares the authentication sequence number (seqAuth) against the 0
     *
     * @param src     source address
     * @param seqAuth seqAuth
     * @return is target auth exists
     */
    private isBusyAuthExists(src: number, seqAuth: number): boolean {
        return this.busySeqAuthBuffer.get(src) == seqAuth;
    }


    /**
     * Checks the sequence number and updates the IV index if necessary.
     * If the IV index is being updated by a remote device, logs a message.
     * Otherwise, sets the IV index to the updated value if necessary.
     * If a private beacon has been received, creates and sends an IV updating beacon.
     * Otherwise, creates and sends a secure network beacon with the updated IV index.
     *
     * @param networkId The network ID.
     * @param beaconKey The beacon key.
     */
    public checkSequenceNumber(networkId: Uint8Array, beaconKey: Uint8Array) {
        const updatingNeeded = this.mSequenceNumber >= NetworkingController.THRESHOLD_SEQUENCE_NUMBER;

        logd(`checkSequenceNumber => updatingNeeded=${updatingNeeded} , isIvUpdating=${this.isIvUpdating} sno=${this.mSequenceNumber}`)
        if (this.isIvUpdating) {
            logd("beacon updating status changed by remote device ");
        } else {
            this.isIvUpdating = updatingNeeded;
            if (this.isIvUpdating) {
                this.ivIndex = this.initIvIndex + 1;
            }
        }

        if (this.privateBeaconReceived) {
            let beacon =
                MeshPrivateBeacon.createIvUpdatingBeacon(this.initIvIndex, this.privateBeaconKey, this.isIvUpdating);
            this.sendMeshBeaconPdu(beacon);
        } else {
            let networkBeacon =
                SecureNetworkBeacon.createIvUpdatingBeacon(this.initIvIndex, networkId, beaconKey, this.isIvUpdating);
            logd("send beacon: " + networkBeacon.toString());
            this.sendMeshBeaconPdu(networkBeacon);
        }
    }

    /**
     * called when the ivIndex is updated.
     *
     * @param newIvIndex new IvIndex
     */
    private onIvUpdated(newIvIndex: number) {
        if (newIvIndex > this.initIvIndex || this.initIvIndex == IV_MISSING) {
            logd(` iv updated to %08X", newIvIndex`)
            this.initIvIndex = newIvIndex;
            this.deviceSequenceNumberMap.clear();
            this.mSequenceNumber = 0;
            this.mNetworkingBridge.onNetworkInfoUpdate(this.mSequenceNumber, newIvIndex);

        } else {
            logd(" iv not updated");
        }
    }

    /**
     * This method is used to handle the received IV (Initialization Vector) index from a remote device in a Mesh network. The IV index is a value used for encryption and security purposes in the network.
     * <p>
     * The method takes two parameters: the remote IV index value and a boolean indicating whether the IV index is being updated. It logs the received IV index and the update status.
     * <p>
     * If the local IV index is missing (initialized as MeshUtils.IV_MISSING), it updates the local IV index with the received remote IV index and sets the IV update status accordingly. It then calls the onIvUpdated() method to handle the IV update.
     * <p>
     * If the local IV index is not missing, it calculates the difference (d-value) between the remote and local IV indices. If the d-value is zero, it means that the remote node has completed its IV update. If the local node is also in the process of updating its IV index, it sets the IV update status to false and calls the onIvUpdated() method.
     * <p>
     * If the d-value is greater than zero, it means that a larger IV index has been received. If the d-value is less than or equal to 42 (a predefined threshold), it updates the local IV index with the received remote IV index and calls the onIvUpdated() method with the updated IV index. If the d-value is greater than 42, it logs a message indicating that the d-value is too large.
     * <p>
     * If the d-value is negative, it means that a smaller IV index has been received, which is unexpected. It logs a warning message.
     *
     * @param remoteIvIndex ivIndex
     * @param updating      is updating
     */
    private onIvIndexReceived(remoteIvIndex: number, updating: boolean) {
        logd(`iv index received : removeIvIndex=${num2Hex(remoteIvIndex, 8)}, updating=${updating}, localIv: ${num2Hex(this.ivIndex, 8)}, updating: ${this.isIvUpdating}`);
        if (this.ivIndex == IV_MISSING) {
            this.isIvUpdating = updating;
            this.ivIndex = remoteIvIndex;
            this.onIvUpdated(remoteIvIndex);
            return;
        }
        // d-value
        let dVal = remoteIvIndex - this.ivIndex;

        if (dVal == 0) {
            // remote node iv update complete
            if (!updating && this.isIvUpdating) {
                this.isIvUpdating = false;
                this.onIvUpdated(remoteIvIndex);
            }
        } else if (dVal > 0) {
            logd("larger iv index received");
            if (dVal <= 42) {
                this.isIvUpdating = updating;
                this.ivIndex = remoteIvIndex;

                this.onIvUpdated(updating ? remoteIvIndex - 1 : remoteIvIndex);
            } else {
                logd("iv index dVal greater than 42");
            }

        } else {
            logw(" smaller iv index received");
        }
    }

    /**
     * This method is used to initialize the sequence number for a specific operation.
     * It takes in the current sequence number as a parameter and returns the initialized sequence number.
     *
     * @param sequenceNumber sno
     * @return init sno
     */
    private initSequenceNumber(sequenceNumber: number): number {
        if (this.mSnoUpdateStep == 0 || this.mSnoUpdateStep == 1) {
            return sequenceNumber;
        }
        let initSno = (sequenceNumber / this.mSnoUpdateStep + 1) * this.mSnoUpdateStep;
        this.onSequenceNumberUpdate(initSno);
        logd("init sno: " + initSno);
        return initSno;
    }

    /**
     * send proxy config message
     *
     * @param message prepared message
     */
    private sendProxyConfigurationMessage(message: ProxyConfigurationMessage) {
        let transportPdu = message.toByteArray();
        let networkLayerPDU = this.createProxyConfigurationPdu(transportPdu,
            this.localAddress, this.getTransmitIvIndex(), this.mSequenceNumber);
        this.sendProxyNetworkPdu(networkLayerPDU);
    }

    /**
     * Sends a mesh message to the specified destination address.
     *
     * @param meshMessage the mesh message to be sent
     * @return true if the message was sent successfully, false otherwise
     */
    public async sendMeshMessage(meshMessage: MeshMessage): Promise<boolean> {

        let dst = meshMessage.destinationAddress
        if (!this.validateDestinationAddress(dst)) {
            logw("invalid dst address: " + num2Hex(dst, 4));
            return false;
        }

        let accessType = meshMessage.accessType
        let encryptionKey: Uint8Array | undefined;
        if (accessType == AccessType.APPLICATION) {
            encryptionKey = this.getAppKey(meshMessage.appKeyIndex);
        } else {
            encryptionKey = this.getDeviceKey(meshMessage.destinationAddress);
        }

        if (!encryptionKey) {
            logw("access key not found : " + accessType);
            return false;
        }
        meshMessage.accessKey = encryptionKey
        return await this.postMeshMessage(meshMessage, false);
    }


    /**
     * This method is used to post a mesh message. It takes a MeshMessage object and a boolean value indicating whether to retry sending the message.
     * <p>
     * The method retrieves the destination address, source address, SZMIC value, opcode, AKF value, and AID value from the MeshMessage object. If the access type is application, it calculates the AID value using the Encipher.k4() method. Otherwise, it sets the AID value to 0x00.
     * <p>
     * The method also retrieves the sequence number and parameters from the MeshMessage object. If the parameters exist and the TID position is valid, it updates the TID value based on the retry flag.
     * <p>
     * Next, an AccessLayerPDU object is created using the opcode and parameters. The AccessLayerPDU is then converted to a byte array.
     * <p>
     * The method determines whether the message needs to be segmented by comparing the length of the access PDU data with the segment length for the given destination address and opcode. If the message is segmented, it checks if there is already a segmented message being sent.
     * <p>
     * Afterwards, the method retrieves the transmit IV index and creates an UpperTransportAccessPDU object using the access PDU data, access key, SZMIC value, access type, IV index, sequence number, source address, and destination address.
     * <p>
     * If the UpperTransportAccessPDU is null, it returns false. Otherwise, it logs the upper transport PDU.
     * <p>
     * The method then checks if the message is reliable. If it is not segmented, it sends an unsegmented access message. If it is segmented, it creates segmented access messages and sends them.
     * <p>
     * If the message is reliable and unsegmented, it starts a reliable timeout check. If the message is reliable and segmented, it starts a reliable timeout check when a block ack is received.
     * <p>
     * Finally, the method sends the network PDUs and returns true.
     *
     * @param meshMessage target message
     * @param retry       is retry
     * @return true if the message was sent successfully, false otherwise
     */
    private async postMeshMessage(meshMessage: MeshMessage, retry: boolean): Promise<boolean> {
        let dst = meshMessage.destinationAddress
        let src = this.localAddress;
        let aszmic = meshMessage.szmic
        let opcode = meshMessage.getOpcode();
        let akf = meshMessage.accessType
        let aid: number;
        if (meshMessage.accessType == AccessType.APPLICATION) {
            aid = k4(meshMessage.accessKey!);
        } else {
            aid = 0x00;
        }

        let sequenceNumber = this.mSequenceNumber

        let params = meshMessage.getParams();
        let tidPos = meshMessage.tidPosition
        if (params != null && tidPos >= 0 && params.length > tidPos) {
            params[tidPos] = retry ? this.tid : ++this.tid
        }

        let accessPDU = new AccessLayerPDU(meshMessage.getOpcode(), params);

        let accessPduData = accessPDU.toByteArray();

        //        boolean segmented = accessPduData.length > UNSEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH;
        let segmentLen = this.getSegmentAccessLength(dst, opcode);
        let segmented = accessPduData.length > segmentLen;
        meshMessage.isSegmented = segmented
        if (segmented) {
            let err: boolean = false
            await this.RELIABLE_SEGMENTED_LOCK.lockAsync(
                () => {
                    if (this.segmentedBusy) {
                        logd("segment message send err: segmented busy");
                        err = true
                    }
                })
            if (err) {
                return false
            }
        }


        logd("post access pdu: " + bytesToHexString(accessPDU.toByteArray(), ""));

        let ivIndex = this.getTransmitIvIndex();

        let upperPDU: UpperTransportAccessPDU | undefined = this.createUpperTransportAccessPDU(accessPduData,
            meshMessage.accessKey!,
            meshMessage.szmic,
            meshMessage.accessType,
            ivIndex,
            sequenceNumber, src, dst)

        if (!upperPDU) {
            logw("create upper transport pdu err: encrypt err");
            return false;
        }
        logd("upper transport pdu: " + bytesToHexString(upperPDU.encryptedPayload, ""));

        // check message reliable
        let reliable = meshMessage.isReliable();

        // upperPDU.getEncryptedPayload().length <= UNSEGMENTED_TRANSPORT_PAYLOAD_MAX_LENGTH
        //
        /*
            for unsegmented & reliable message, start reliable timeout check immediately,
            for segmented & reliable message, start reliable timeout check when received block ack
         */
        if (!segmented) {
            logd("send unsegmented access message");

            if (reliable) {
                if (this.reliableBusy) {
                    logw("unsegmented reliable message send err: busy");
                    return false;
                }
                this.reliableBusy = true;
                this.mSendingReliableMessage = meshMessage;
                this.restartReliableMessageTimeoutTask();
            }

            let unsegmentedMessagePDU = this.createUnsegmentedAccessMessage(upperPDU.encryptedPayload!, akf, aid);
            let networkPDU = this.createNetworkPDU(unsegmentedMessagePDU.toByteArray(),
                meshMessage.ctl, meshMessage.ttl, src, dst, ivIndex, sequenceNumber);
            this.sendNetworkPdu(networkPDU);
        } else {
            let err: boolean = false
            await this.RELIABLE_SEGMENTED_LOCK.lockAsync(
                () => {
                    if (reliable) {
                        if (this.reliableBusy) {
                            logw("segmented reliable message send err: busy");
                            err = true
                            return;
                        }
                        this.reliableBusy = true;
                        this.mSendingReliableMessage = meshMessage;
                        //                    restartReliableMessageTimeoutTask(); //
                    }

                    let segmentedAccessMessages =
                        this.createSegmentedAccessMessage(upperPDU?.encryptedPayload!, akf, aid, aszmic, sequenceNumber,
                            segmentLen);
                    if (segmentedAccessMessages.length == 0) {
                        return false;
                    }

                    logd("send segmented access message");
                    let networkLayerPduList: ArrayList<NetworkLayerPDU> = new ArrayList();
                    for (let i = 0; i < segmentedAccessMessages.length; i++) {
                        let lowerTransportPdu = segmentedAccessMessages[i].toByteArray();
                        let networkPDU = this.createNetworkPDU(lowerTransportPdu,
                            meshMessage.ctl, meshMessage.ttl, src, dst, ivIndex, sequenceNumber + i);
                        networkLayerPduList.add(networkPDU);
                    }
                    if (validUnicastAddress(dst)) {
                        this.sentSegmentedMessageBuffer = segmentedAccessMessages
                        this.startSegmentedMessageTimeoutCheck();
                        this.startSegmentedBlockAckWaiting(meshMessage.ctl, meshMessage.ttl, src, dst);
                    } else if (reliable) {
                        this.restartReliableMessageTimeoutTask();
                    }
                    this.sendNetworkPduList(networkLayerPduList);

                    return
                }
            )
        }
        return true;
    }

    /**
     * proxy filter init steps:
     * 1. set white list
     * 2. add localAddress and 0xFFFF into address array
     */
    public proxyFilterInit() {
        this.proxyFilterInitStep = 0;
        clearTimeout(this.proxyFilterInitTimeoutTask)
        this.proxyFilterInitTimeoutTask = setTimeout(() => {
            logw("filter init timeout");
            this.onProxyInitComplete(false);
        }, NetworkingController.PROXY_FILTER_INIT_TIMEOUT)

        this.setFilterType(ProxyFilterType.WhiteList);
    }

    /**
     * This method is used to set the filter type for the proxy.
     * It takes a parameter of type ProxyFilterType, which represents the desired filter type.
     * It creates a ProxySetFilterTypeMessage object with the value of the filter type and then calls the sendProxyConfigurationMessage method to send the message to the proxy.
     *
     * @param filterType target type
     */
    private setFilterType(filterType: ProxyFilterType) {
        let message = new ProxySetFilterTypeMessage(filterType);
        this.sendProxyConfigurationMessage(message);
    }

    /**
     * add a filter address to a proxy configuration.
     *
     * @param addressArray addresses
     */
    private addFilterAddress(addressArray: Uint16Array) {
        let addAddressMessage = new ProxyAddAddressMessage(addressArray);
        this.sendProxyConfigurationMessage(addAddressMessage);
    }

    /**
     * Validates the destination address.
     *
     * @param address the destination address to be validated
     * @return true if the address is not equal to zero, false otherwise
     */
    private validateDestinationAddress(address: number): boolean {
        return address != 0;
    }

    /**
     * get app key in map
     *
     * @return app key at index
     */
    private getAppKey(appKeyIndex: number): Uint8Array | undefined {
        if (this.appKeyMap.length == 0) {
            return undefined;
        }
        for (let appKey of this.appKeyMap) {
            if (appKey.keyIndex == appKeyIndex) {
                return appKey.key
            }
        }
        return undefined
    }


    /**
     * get device key for config model message when akf==0
     * {@link AccessType#DEVICE}
     *
     * @param unicastAddress node address
     * @return device key
     */
    private getDeviceKey(unicastAddress: number): Uint8Array | undefined {
        if (this.deviceKeyMap.length == 0) {
            return undefined;
        }
        for (let deviceKey of this.deviceKeyMap) {
            if (deviceKey.address == unicastAddress) {
                return deviceKey.key
            }
        }
        return undefined
    }

    /**
     * This method starts a timeout check for segmented messages.
     * It sets a flag to indicate that the system is currently busy with segmented messages.
     * It first removes any previously scheduled timeout tasks using the mDelayHandler's removeCallbacks() method.
     * Then, it schedules a new timeout task called segmentedMessageTimeoutTask using the mDelayHandler's postDelayed() method.
     * The timeout duration is specified by the constant BLOCK_ACK_WAITING_TIMEOUT.
     */
    private startSegmentedMessageTimeoutCheck() {
        this.segmentedBusy = true;
        clearTimeout(this.segmentedMessageTimeoutTask.timerId)
        this.segmentedMessageTimeoutTask.timerId = setTimeout(() => {
            logd("segmented message timeout");
            this.stopSegmentedBlockAckWaiting(true, false);
        }, NetworkingController.BLOCK_ACK_WAITING_TIMEOUT)
    }

    /**
     * used to start the waiting period for receiving a segmented block acknowledgment.
     *
     * @param src source address
     * @param dst dst address
     */
    private async startSegmentedBlockAckWaiting(ctl: number, ttl: number, src: number, dst: number) {
        clearTimeout(this.mSegmentBlockWaitingTask.timerId)
        this.mSegmentBlockWaitingTask.timerId = setTimeout(() => {
            this.resendSegmentedMessages(-1, 0);
        }, await this.getSegmentedTimeout(ttl, true))
        this.mSegmentBlockWaitingTask.ctl = ctl
        this.mSegmentBlockWaitingTask.ttl = ttl
        this.mSegmentBlockWaitingTask.src = src
        this.mSegmentBlockWaitingTask.dst = dst
    }

    /**
     * stop segmented message block acknowledgment waiting
     *
     * @param complete true: when timeout {@link #BLOCK_ACK_WAITING_TIMEOUT}
     *                 or block ack shows all segmented message received
     *                 false: when checking block ack
     */
    private stopSegmentedBlockAckWaiting(complete: boolean, success: boolean) {
        logd(`stop segmented block waiting, complete - ${complete} success - ${success}`)
        clearTimeout(this.mSegmentBlockWaitingTask.timerId)
        if (complete) {
            this.onSegmentedMessageComplete(success);
        }
    }

    /**
     * segment message sent complete
     *
     * @param success true: received completed block
     *                false: timeout
     */
    private onSegmentedMessageComplete(success: boolean) {
        logd("segmented message complete, success? : " + success);
        // clear segment state
        this.clearSegmentSendingState(success);

        // check reliable state
        if (this.reliableBusy) {
            /*
            if segmented message sent success, check response after #@link{RELIABLE_MESSAGE_TIMEOUT}
            else if segmented message timeout, retry immediately
             */
            if (success) {
                this.restartReliableMessageTimeoutTask();
            } else {
                // if segment timeout , no need to resend reliable message
                this.onReliableMessageComplete(false);
            }
        }
    }

    /**
     * This method is used to clear the state of segment sending.
     *
     * @param success is segment message send success
     */
    private clearSegmentSendingState(success: boolean) {
        this.segmentedBusy = false;
        clearTimeout(this.segmentedMessageTimeoutTask.timerId)
        this.sentSegmentedMessageBuffer.clear();
        this.mNetworkingBridge.onSegmentMessageComplete(success);
    }

    /**
     * This method calculates the timeout for segment acknowledgments in a segmented communication protocol. The timeout is determined based on the time-to-live (TTL) value and whether it is for sending or receiving.
     * <p>
     * If the timeout is for sending (outer), it calculates the timeout by adding the relay timeout (300ms), the segment acknowledgment timeout (200ms + 50ms * TTL), and the number of packets in the networking queue multiplied by the network packet send interval.
     * <p>
     * If the timeout is for receiving, it calculates the timeout by adding the relay timeout and the segment acknowledgment timeout.
     * <p>
     * The method then logs the calculated timeout and returns it.
     * <p>
     * Please let me know if you have any further questions!
     *
     * @param ttl   ttl
     * @param outer is sending
     * @return timeout milli
     */
    private async getSegmentedTimeout(ttl: number, outer: boolean): Promise<number> {
        let relayTimeout = 300;
        let segmentAckTimeout = 200 + 50 * ttl;
        let timeout: number;
        if (outer) {
            // send
            let queueSize: number = 0
            await this.NETWORK_QUEUE_LOCK.lockAsync(() => {
                queueSize = this.mNetworkingQueue.length
            })
            timeout = relayTimeout + segmentAckTimeout + queueSize * NetworkingController.netPktSendInterval;
        } else {
            // receive
            timeout = relayTimeout + segmentAckTimeout;
        }
        logd("get segment ack timeout: " + timeout);
        return timeout;
    }

    /**
     * calculates the timeout duration for a reliable message in a networking queue.
     *
     * @return timeout
     */
    private async getReliableMessageTimeout(): Promise<number> {
        let queueSize: number = 0
        await this.NETWORK_QUEUE_LOCK.lockAsync(() => {
            queueSize = this.mNetworkingQueue.length
        })

        // 960
        //        let timeout = 1280 + queueSize * NETWORKING_INTERVAL;

        // for test
        //        let timeout = (dleEnabled ? 5120 : 2560) + queueSize * NETWORKING_INTERVAL;
        let timeout = queueSize * NetworkingController.netPktSendInterval;
        let meshMessage = this.mSendingReliableMessage;
        if (meshMessage) {
            timeout += meshMessage.retryInterval;
        } else {
            //            timeout = (dleEnabled ? 2560 : 1280) + ;
            timeout += MeshMessage.DEFAULT_RETRY_INTERVAL;
        }
        logd("reliable message timeout:" + timeout);
        return timeout;
    }

    /**
     * used to increase the sequence number by one.
     */
    private increaseSequenceNumber() {
        let latestValue = ++this.mSequenceNumber
        this.onSequenceNumberUpdate(latestValue);
    }

    /**
     * Sends a list of network layer PDUs over the network.
     *
     * @param networkPduList The list of network layer PDUs to be sent.
     */
    private sendNetworkPduList(networkPduList: ArrayList<NetworkLayerPDU>) {
        for (let networkLayerPDU of networkPduList) {
            let networkPduPayload: Uint8Array = networkLayerPDU.generateEncryptedPayload();
            logd("multi network pdu: " + bytesToHexString(networkPduPayload, ":"));
            this.onNetworkingPduPrepared(networkPduPayload, networkLayerPDU.dst);
        }
    }

    /**
     * Sends a network layer PDU over the network.
     *
     * @param networkPdu network layer PDU to be sent.
     */
    private sendNetworkPdu(networkPdu: NetworkLayerPDU) {
        let networkPduPayload = networkPdu.generateEncryptedPayload();
        logd("single network pdu: " + bytesToHexString(networkPduPayload, ":"));
        this.onNetworkingPduPrepared(networkPduPayload, networkPdu.dst);
    }

    /**
     * Sends a proxy network layer PDU over the network.
     *
     * @param networkPdu network layer PDU to be sent.
     */
    private sendProxyNetworkPdu(networkPdu: ProxyConfigurationPDU) {
        let networkPduPayload = networkPdu.generateEncryptedPayload();
        logd("proxy network pdu: " + bytesToHexString(networkPduPayload, ":"));
        this.mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_PROXY_CONFIGURATION, networkPduPayload);
    }

    /**
     * This method is called when a networking PDU (Protocol Data Unit) is prepared for sending.
     * It logs the payload in hexadecimal format and whether the networking is busy or not.
     * <p>
     * If the networking is not busy, it checks if the destination address matches the direct address.
     * If it does, it logs that the networking PDU is being sent directly and calls the onCommandPrepared
     * method of the mNetworkingBridge (if available) with the networking PDU payload.
     * <p>
     * If the networking is busy or the destination address does not match the direct address,
     * it adds the networking PDU payload to the networking queue.
     * <p>
     * After that, it checks if the networking is not busy. If it is not, it sets the networkingBusy
     * flag to true, indicating that the networking is busy, and calls the pollNetworkingQueue method
     * to start sending the networking PDUs from the queue.
     */
    private async onNetworkingPduPrepared(payload: Uint8Array, dstAddress: number) {
        logd("networking pdu prepared: " + bytesToHexString(payload, ":") + " busy?-" + this.networkingBusy);
        let err: boolean = false
        await this.mNetworkBusyLock.lockAsync(() => {
            if (!this.networkingBusy) {
                let directPdu = dstAddress == this.directAddress;
                if (directPdu) {
                    logd("networking pdu sending direct ");
                    this.mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_NETWORK_PDU, payload);
                    err = true
                }
            }
        })
        if (err) {
            return
        }

        await this.NETWORK_QUEUE_LOCK.lockAsync(() => {
            this.mNetworkingQueue.add(payload);
        })


        await this.mNetworkBusyLock.lockAsync(() => {
            if (!this.networkingBusy) {
                this.networkingBusy = true;
                this.pollNetworkingQueue();
            }
        })

    }


    /**
     * This method is responsible for polling the networking queue and retrieving the next payload to be sent.
     * If there is no payload in the queue, it sets the networkingBusy flag to false.
     * If there is a payload, it logs the payload and sends it to the networking bridge for processing.
     * It also removes any previously scheduled networking sending tasks and schedules a new one with a delay of netPktSendInterval.
     */
    private async pollNetworkingQueue() {
        let payload: Uint8Array | undefined;
        await this.NETWORK_QUEUE_LOCK.lockAsync(() => {
            payload = this.mNetworkingQueue.pop()
        })
        if (payload) {
            logd("networking pdu poll: " + bytesToHexString(payload, ":"));
            this.mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_NETWORK_PDU, payload);
            clearTimeout(this.networkingSendingTask)
            this.networkingSendingTask = setTimeout(() => {
                this.pollNetworkingQueue();
            }, NetworkingController.netPktSendInterval)
        } else {
            logd("networking pdu poll: null");
            await this.mNetworkBusyLock.lockAsync(() => {
                this.networkingBusy = false;
            })
        }
    }


    /**
     * seqNo update by step
     * {@link #mSnoUpdateStep}
     *
     * @param latestSequenceNumber latest sequenceNumber
     */
    private onSequenceNumberUpdate(latestSequenceNumber: number) {
        if (this.mSnoUpdateStep == 0 || latestSequenceNumber % this.mSnoUpdateStep == 0) {
            //                mNetworkingBridge.onNetworkInfoUpdate(latestSequenceNumber, (int) this.ivIndex);
            // if the ivIndex is updating
            this.mNetworkingBridge.onNetworkInfoUpdate(latestSequenceNumber, this.initIvIndex);
        }
    }


    /**
     * This method is used to parse a secure network beacon.
     * It takes in a payload, which is the data of the beacon, and a network beacon key, which is used to decrypt the payload.
     *
     * @param payload          payload
     * @param networkBeaconKey key
     */
    public parseSecureBeacon(payload: Uint8Array, networkBeaconKey: Uint8Array) {
        let networkBeacon = SecureNetworkBeacon.from(payload, networkBeaconKey);
        // validate beacon data
        if (networkBeacon) {
            logd("SecureNetworkBeacon received: " + networkBeacon.toString());
            let ivIndex = networkBeacon.ivIndex
            let isIvUpdating = networkBeacon.isIvUpdating();
            this.onIvIndexReceived(ivIndex & UNSIGNED_INTEGER_MAX, isIvUpdating);
        } else {
            logw("network beacon parse err");
        }

    }

    /**
     * This method is used to parse a private beacon from a given payload and private beacon key.
     *
     * @param payload          payload
     * @param privateBeaconKey key
     */
    public parsePrivateBeacon(payload: Uint8Array, privateBeaconKey: Uint8Array) {
        let privateBeacon = MeshPrivateBeacon.from(payload, privateBeaconKey);
        if (privateBeacon) {
            this.privateBeaconReceived = true;
            logd("MeshPrivateBeacon received: " + privateBeacon.toString());
            let ivIndex = privateBeacon.ivIndex
            let isIvUpdating = privateBeacon.isIvUpdating();
            this.onIvIndexReceived(ivIndex & UNSIGNED_INTEGER_MAX, isIvUpdating);
        } else {
            logd("private beacon parse error");
        }
    }

    /**
     * accepted when received networking pdu
     *
     * @param ivi 1-bit
     * @return ivIndex
     */
    private getAcceptedIvIndex(ivi: number): number {
        logd(`getAcceptedIvIndex : ${this.ivIndex}  ivi: ${ivi}`)
        let ivChecked = (this.ivIndex & 0b01) == ivi;
        return ivChecked ? this.ivIndex : (this.ivIndex - 1);
    }

    /**
     * This method returns the transmit IV index.
     * If the IV is not currently updating, the transmit IV index is returned as is.
     * Otherwise, the transmit IV index is decremented by 1. A log message is printed to display the transmit IV index in hexadecimal format. The transmit IV index is then returned.
     *
     * @return ivIndex
     */
    private getTransmitIvIndex(): number {
        let re = (!this.isIvUpdating ? this.ivIndex : this.ivIndex - 1);
        logd(`getTransmitIvIndex : ${re}`)
        return re;
    }

    /**
     * Sends a MeshBeaconPDU over the network.
     *
     * @param meshBeaconPDU The MeshBeaconPDU to send.
     */
    private sendMeshBeaconPdu(meshBeaconPDU: MeshBeaconPDU) {
        this.mNetworkingBridge.onCommandPrepared(ProxyPDU.TYPE_MESH_BEACON, meshBeaconPDU.toBytes());
    }

    /**
     * parse a network PDU (Protocol Data Unit) payload.
     *
     * @param payload data payload
     */
    public parseNetworkPdu(payload: Uint8Array) {

        let ivi = (payload[0] & 0xFF) >> 7;
        let ivIndex = this.getAcceptedIvIndex(ivi);
        // new NetworkEncryptionSuite(ivIndex, this.encryptionKey, this.privacyKey, this.nid)
        let networkLayerPDU = new NetworkLayerPDU({
            ivIndex: ivIndex,
            encryptionKey: this.encryptionKey,
            privacyKey: this.privacyKey,
            nid: this.nid
        }
        );
        if (networkLayerPDU.parse(payload)) {
            logd("network layer pdu: " + networkLayerPDU.toString());
            if (!this.validateSequenceNumber(networkLayerPDU, ivIndex)) {
                logw("network pdu sequence number check err");
                return;
            }
            if (networkLayerPDU.ctl == MeshMessage.CTL_ACCESS) {
                this.parseAccessMessage(networkLayerPDU);
            } else {
                this.parseControlMessage(networkLayerPDU);
            }

        } else {
            logw("network layer parse err")
        }
    }

    /**
     * Parses the Proxy Configuration PDU from the given payload.
     *
     * @param payload The payload containing the Proxy Configuration PDU.
     */
    public parseProxyConfigurationPdu(payload: Uint8Array) {
        // Extract the IVI from the first byte of the payload
        let ivi = (payload[0] & 0xFF) >> 7;

        // Get the accepted IVI from the extracted IVI
        let ivIndex = this.getAcceptedIvIndex(ivi);
        let proxyNetworkPdu = new ProxyConfigurationPDU({
            ivIndex: ivIndex,
            encryptionKey: this.encryptionKey,
            privacyKey: this.privacyKey,
            nid: this.nid
        }
        );
        if (proxyNetworkPdu.parse(payload)) {
            logd("proxy pdu: " + JSON.stringify(proxyNetworkPdu))
            if (!this.validateSequenceNumber(proxyNetworkPdu, ivIndex)) {
                logw("proxy config pdu sequence number check err");
                return;
            }
            logd(`proxy network pdu src: ${num2Hex(proxyNetworkPdu.src, 4)} dst: ${num2Hex(proxyNetworkPdu.dst, 4)}`);
            this.onProxyConfigurationNotify(proxyNetworkPdu.transportPDU, proxyNetworkPdu.src);
        }

    }

    /**
     * This method is called when a proxy configuration notification is received.
     * It takes in a byte array representing the proxy configuration message and the source address of the message.
     *
     * @param proxyConfigMessage message data
     * @param src                source address
     */
    private onProxyConfigurationNotify(proxyConfigMessage: Uint8Array, src: number) {
        logd("onProxyConfigurationNotify: "+ bytesToHexString(proxyConfigMessage, ":"));
        let proxyFilterStatusMessage = ProxyFilterStatusMessage.fromBytes(proxyConfigMessage);
        if (proxyFilterStatusMessage) {
            // target Filter type is whitelist
            if (proxyFilterStatusMessage.filterType == ProxyFilterType.WhiteList) {
                if (this.proxyFilterInitStep < 0) {
                    logw("filter init action not started!");
                    return;
                }
                logd(`reset direct address: ${num2Hex(src, 4)}`);
                this.directAddress = src;
                this.proxyFilterInitStep++;
                if (this.proxyFilterInitStep == NetworkingController.PROXY_FILTER_INIT_STEP_SET_TYPE) {
                    if (this.whiteList == null || this.whiteList.length == 0) {
                        this.addFilterAddress(new Uint16Array([this.localAddress, ADDRESS_BROADCAST]));
                    } else {
                        this.addFilterAddress(this.whiteList);
                    }
                } else if (this.proxyFilterInitStep == NetworkingController.PROXY_FILTER_SET_STEP_ADD_ADR) {
                    this.onProxyInitComplete(true);
                }
            }

        }
    }

    private proxyFilterInitTimeoutTask = 0

    // private Runnable proxyFilterInitTimeoutTask = new Runnable() {
    //     @Override
    //     public void run() {
    //         log("filter init timeout");
    //         onProxyInitComplete(false);
    //     }
    // };

    /**
     * called when the initialization of a proxy is completed.
     *
     * @param success indicates whether the initialization was successful or not.
     */
    private onProxyInitComplete(success: boolean) {
        this.proxyFilterInitStep = -1;
        if (success) {
            clearTimeout(this.proxyFilterInitTimeoutTask)
        }
        this.mNetworkingBridge.onProxyInitComplete(success, this.directAddress);
    }

    /**
     * Validates the sequence number of a received NetworkLayerPDU.
     *
     * @param networkLayerPDU The NetworkLayerPDU to validate.
     * @param pduIvIndex      The IV index of the received PDU.
     * @return True if the sequence number is valid, false otherwise.
     */
    private validateSequenceNumber(networkLayerPDU: NetworkLayerPDU, pduIvIndex: number): boolean {
        let src = networkLayerPDU.src
        let pduSequenceNumber = networkLayerPDU.seq
        let valueInCache = this.deviceSequenceNumberMap.get(src);
        if (!valueInCache) {
            valueInCache = -1
        }
        let deviceSequenceNumber = this.getSequenceNumberInCache(valueInCache);
        let pass = true;
        // logw(`value in cache : valueInCache=${valueInCache} , pduSequenceNumber=${pduSequenceNumber} , src=${src} `)
        if (valueInCache == -1) {
            logd("put init sequence number");
            this.saveSequenceCache(src, pduSequenceNumber, pduIvIndex);
        } else {
            let deviceIvIndex = this.getIvIndexInCache(valueInCache);
            // logw(`check ivIndex : deviceIvIndex=${deviceIvIndex} , pduIvIndex=${pduIvIndex}`)
            if (pduIvIndex > deviceIvIndex) {
                logd("network pdu - larger ivIndex received, save the new ivIndex");
                this.saveSequenceCache(src, pduSequenceNumber, pduIvIndex);
            } else if (pduIvIndex == deviceIvIndex) {
                if (pduSequenceNumber > deviceSequenceNumber) {
                    this.saveSequenceCache(src, pduSequenceNumber, pduIvIndex);
                } else {
                    logd(`validate sequence number error  src: ${num2Hex(src,
                        4)} -- pdu-sno: ${num2Hex(pduSequenceNumber, 6)} -- dev-sno: ${num2Hex(deviceSequenceNumber,
                        6)}`)
                    pass = false;
                }
            } else {
                logd("network pdu error: less ivIndex pdu received");
                pass = false;
            }

        }
        return pass;
    }

    /**
     * save sequence number and ivIndex misc value
     */
    private saveSequenceCache(src: number, sequenceNumber: number, ivIndex: number) {
        let value = ((ivIndex & 0xFFFFFFFF) << 32) | (sequenceNumber & 0x00FFFFFF);
        // logw(`save sequence cache : src=${src} , value=${num2Hex(value, 16)}`)
        // logw(`save sequence cache detail : src=${src} , value=${num2Hex(value, 16)} , sno=${num2Hex(sequenceNumber, 8)} , ivIndex=${num2Hex(ivIndex, 8)}`)
        this.deviceSequenceNumberMap.set(src, value);
    }

    /**
     * This method extracts the sequence number from a value stored in the cache.
     * The sequence number is represented by the lower 24 bits of the value.
     *
     * @param valInCache the value stored in the cache
     * @return the extracted sequence number
     */
    private getSequenceNumberInCache(valInCache: number): number {
        return valInCache & 0xFFFFFF;
    }

    /**
     * This method extracts the IV index from a value stored in the cache.
     * The IV index is represented by bits 32 to 63 of the value.
     *
     * @param valInCache the value stored in the cache
     * @return the extracted IV index
     */
    private getIvIndexInCache(valInCache: number): number {
        return ((valInCache >> 31) >> 1) & 0xFFFFFFFF
    }

    /**
     * This method is used to parse a control message received from the network layer.
     * It extracts the lower transport PDU data from the network layer PDU and identifies
     * the segment and opcode of the control message. Based on the segment and opcode,
     * it performs the appropriate action.
     *
     * @param networkLayerPDU The network layer PDU containing the control message.
     */
    private parseControlMessage(networkLayerPDU: NetworkLayerPDU) {
        let lowerTransportPduData = networkLayerPDU.transportPDU
        let segOpcode = lowerTransportPduData[0] & 0xFF;
        let seg = segOpcode >> 7;
        let opcode = segOpcode & 0x7F;
        logd("parse control message  seg:" + seg + " -- opcode:" + opcode);
        if (seg == LowerTransportPDU.SEG_TYPE_UNSEGMENTED) {
            if (opcode == TransportControlMessagePDU.CONTROL_MESSAGE_OPCODE_SEG_ACK) {
                let segmentAckMessage = new SegmentAcknowledgmentMessage();
                if (segmentAckMessage.parse(lowerTransportPduData)) {
                    this.onSegmentAckMessageReceived(segmentAckMessage);
                }
            } else if (opcode == TransportControlMessagePDU.CONTROL_MESSAGE_OPCODE_HEARTBEAT) {
                this.onHeartbeatNotify(networkLayerPDU.src, networkLayerPDU.dst, lowerTransportPduData);
            }
        }
    }

    /**
     * This method is called when a heartbeat control message is received.
     * It logs the received heartbeat message and forwards it to the networking bridge
     * if available.
     *
     * @param src          The source address of the heartbeat message.
     * @param dst          The destination address of the heartbeat message.
     * @param transportPdu The transport PDU containing the heartbeat message.
     */
    private onHeartbeatNotify(src: number, dst: number, transportPdu: Uint8Array) {
        logd("on heart beat notify: " + bytesToHexString(transportPdu, ":"));
        this.mNetworkingBridge.onHeartbeatMessageReceived(src, dst, transportPdu);
    }

    /**
     * when receive Segment Acknowledgment Message
     * check if is segmented message sending,
     * and check blockAck value , if segmented message missing, resend
     */
    private onSegmentAckMessageReceived(segmentAckMessage: SegmentAcknowledgmentMessage) {
        logd("onSegmentAckMessageReceived: " + segmentAckMessage.toString());
        if (this.segmentedBusy) {
            this.resendSegmentedMessages(segmentAckMessage.getSeqZero(), segmentAckMessage.getBlockAck());
        } else {
            logw("Segment Acknowledgment Message err: segmented messages not sending");
        }
    }

    /**
     * @param seqZero  valued by block ack message or -1 when not received any block ack message;
     *                 so if seqZero is -1, resend all segmented messages
     * @param blockAck valued by block ack message showing missing segmented messages or 0 when not received any block ack message
     */
    private resendSegmentedMessages(seqZero: number, blockAck: number) {
        let messageBuffer = this.sentSegmentedMessageBuffer
        // final SparseArray<SegmentedAccessMessagePDU> messageBuffer = sentSegmentedMessageBuffer.clone();
        logd("resendSegmentedMessages: seqZero: " + seqZero
            + " block ack: " + blockAck
            + " buffer size: " + messageBuffer.length);
        if (messageBuffer.length != 0) {
            let message0 = messageBuffer[0];
            if (!message0) {
                logw("resendSegmentedMessages err : message0 not found")
                return
            }
            let messageSeqZero = message0.seqZero
            if (seqZero != -1) {
                if (seqZero == messageSeqZero) {
                    this.stopSegmentedBlockAckWaiting(false, false);
                } else {
                    return;
                }
            }


            let ctl = this.mSegmentBlockWaitingTask.ctl;
            let ttl = this.mSegmentBlockWaitingTask.ttl;
            let src = this.mSegmentBlockWaitingTask.src;
            let dst = this.mSegmentBlockWaitingTask.dst;

            let messageSegN = message0.segN
            let messageReceived: boolean
            let messagePDU: SegmentedAccessMessagePDU | undefined
            let ivIndex = this.getTransmitIvIndex();
            let sequenceNumber = this.mSequenceNumber
            let addedValue = 0;
            // List<NetworkLayerPDU> networkLayerPduList = new ArrayList<>();
            let networkLayerPduList: ArrayList<NetworkLayerPDU> = new ArrayList();
            for (let i = 0; i <= messageSegN; i++) {
                messageReceived = (blockAck & bit(i)) != 0;
                if (!messageReceived) {
                    // message miss
                    messagePDU = messageBuffer[i]
                    if (!messagePDU) {
                        logw("resendSegmentedMessages err : message0 not found")
                        return
                    }
                    let lowerTransportPdu = messagePDU.toByteArray();
                    logd("resend segmented message: seqZero:" + messagePDU.seqZero + " -- segO:" + messagePDU.segO);
                    let networkPDU = this.createNetworkPDU(lowerTransportPdu,
                        ctl, ttl, src, dst, ivIndex, sequenceNumber + addedValue);
                    addedValue++;
                    networkLayerPduList.add(networkPDU);
                }
            }

            if (networkLayerPduList.length == 0) {
                // all received
                this.stopSegmentedBlockAckWaiting(true, true);
            } else {
                this.startSegmentedBlockAckWaiting(ctl, ttl, src, dst);
                this.sendNetworkPduList(networkLayerPduList);
            }

        }
    }


    /**
     * parse lower transport pdu
     */
    private parseAccessMessage(networkLayerPDU: NetworkLayerPDU) {
        logd("parse access message");
        let src = networkLayerPDU.src
        let dst = networkLayerPDU.dst

        if (validUnicastAddress(dst)) {
            if (dst != this.localAddress) {
                return;
            }
        }

        let lowerTransportData = networkLayerPDU.transportPDU;

        let lowerTransportHeader = lowerTransportData[0];
        let seg = (lowerTransportHeader >> 7) & 0b01;
        let accessPDU: AccessLayerPDU | undefined
        if (seg == 1) {
            logd("parse segmented access message");

            /*
             * tick refresh if received segment busy
             */
            /*if (reliableBusy) {
                log("refresh reliable tick because of segment network pdu received");
                restartReliableMessageTimeoutTask();
            }*/
            accessPDU = this.parseSegmentedAccessMessage(networkLayerPDU);

        } else {
            logd(`parse unsegmented access message ${bytesToHexString(networkLayerPDU.transportPDU)}`);
            accessPDU = this.parseUnsegmentedAccessMessage(networkLayerPDU);
        }

        if (accessPDU != null) {
            this.onAccessPduReceived(src, dst, accessPDU);
        }
    }


    /**
     * refresh reliable message status, then invoke message callback
     */
    private onAccessPduReceived(src: number, dst: number, accessPDU: AccessLayerPDU) {
        logd(`access pdu received : src=0x${num2Hex(src, 4)}: opcode=0x${num2Hex(accessPDU.opcode,
            4)} params=${bytesToHexString(accessPDU.params)}`);
        // check reliable message state
        this.updateReliableMessage(src, accessPDU);
        this.mNetworkingBridge.onMeshMessageReceived(src, dst, accessPDU.opcode, accessPDU.params);
    }

    /**
     * This method is used to update the reliable message status when a response is received from a device.
     *
     * @param src            source address
     * @param accessLayerPDU access pdu
     */
    private updateReliableMessage(src: number, accessLayerPDU: AccessLayerPDU) {
        if (!this.reliableBusy) {
            return;
        }
        let sendingMessage = this.mSendingReliableMessage;
        if (sendingMessage != null && sendingMessage.getResponseOpcode() == accessLayerPDU.opcode) {
            let sendingDst = sendingMessage.destinationAddress
            if (validUnicastAddress(sendingDst) && sendingDst != src) {
                logd(`not expected response : ${num2Hex(sendingDst, 4)} - ${num2Hex(src, 4)}`);
                return;
            }
            this.mResponseMessageBuffer.add(src);
            if (this.mResponseMessageBuffer.length >= sendingMessage.responseMax) {
                this.onReliableMessageComplete(true);
            }
        }
    }

    /**
     * reliable command complete
     *
     * @param success if command response received
     */
    private async onReliableMessageComplete(success: boolean) {

        // clear networking packet sending queue
        logd("clear network buffer");
        await this.NETWORK_QUEUE_LOCK.lockAsync(() => {
            clearTimeout(this.networkingSendingTask)
            this.networkingBusy = false;
            while (this.mNetworkingQueue.length > 0) {
                this.mNetworkingQueue.pop()
            }
        })

        let msg = this.mSendingReliableMessage;
        if (!msg) {
            return;
        }
        clearTimeout(this.reliableMessageTimeoutTask)
        let opcode = msg.getOpcode();
        let dest = msg.destinationAddress
        let rspMax = msg.responseMax
        let rspCount = this.mResponseMessageBuffer.length;
        logd(`Reliable Message Complete: ${num2Hex(opcode, 4)} success?: ${success}`);
        let arr = new Uint16Array([rspCount])
        for (let i = 0; i < rspCount; i++) {
            arr[i] = this.mResponseMessageBuffer[i]
        }
        this.mResponseMessageBuffer.clear();
        await this.RELIABLE_SEGMENTED_LOCK.lockAsync(() => {
            this.reliableBusy = false;
            if (success) {
                if (this.segmentedBusy && msg?.isSegmented) {
                    this.segmentedBusy = false;
                    this.stopSegmentedBlockAckWaiting(true, true);
                }
            }
        })
        this.mNetworkingBridge.onReliableMessageComplete(success, opcode, dest, rspMax, rspCount, arr);
    }

    /**
     * start or refresh tick
     */
    private async restartReliableMessageTimeoutTask() {
        logd("restart reliable message timeout task, immediate");
        clearTimeout(this.reliableMessageTimeoutTask)
        this.reliableMessageTimeoutTask = setTimeout(() => {
            this.onReliableMessageTimeout()
        }, await this.getReliableMessageTimeout())
    }

    private async onReliableMessageTimeout() {
        let meshMessage = this.mSendingReliableMessage;
        if (meshMessage) {
            logd(`reliable message retry segmentRxComplete? ${this.lastSegComplete} retryCnt: ${meshMessage.retryCnt} ${meshMessage.toString()} opcode: ${num2Hex(meshMessage.getOpcode(),
                6)}`);
            if (this.lastSegComplete) {
                let retryCnt = meshMessage.retryCnt
                if (retryCnt <= 0) {
                    this.onReliableMessageComplete(false);
                } else {
                    // resend mesh message
                    meshMessage.retryCnt = retryCnt - 1
                    await this.RELIABLE_SEGMENTED_LOCK.lockAsync(() => {
                        this.reliableBusy = false;
                        if (this.segmentedBusy && meshMessage?.isSegmented) {
                            this.stopSegmentedBlockAckWaiting(true, false);
                        }
                    })
                    this.postMeshMessage(meshMessage, true);
                }
            } else {
                // receiving rx segment packet
                this.restartReliableMessageTimeoutTask();
            }
        }
    }


    // parse unsegmented access message lower transport PDU

    /**
     * This method is used to parse an unsegmented access message from a network layer PDU.
     * It first retrieves the lower transport data from the network layer PDU and extracts the header.
     * The Access Key Flag (AKF) and the IV Index are then extracted from the header.
     * An instance of the UnsegmentedAccessMessagePDU is created and the network layer PDU is parsed using it.
     * If the parsing is successful, an UpperTransportAccessPDU.UpperTransportEncryptionSuite is created based on the AKF value.
     * If AKF is equal to the AKF value of the Access Type DEVICE, the device key is used along with the IV Index.
     * Otherwise, a list of application keys is retrieved and used along with the IV Index.
     * An instance of UpperTransportAccessPDU is created with the encryption suite.
     * The unsegmented access message is then parsed and decrypted using the UpperTransportAccessPDU.
     * If the decryption is successful, the decrypted payload is parsed as an AccessLayerPDU and returned.
     * If any errors occur during the parsing or decryption process, null is returned.
     *
     * @param networkLayerPDU network pdu
     * @return access pdu
     */
    private parseUnsegmentedAccessMessage(networkLayerPDU: NetworkLayerPDU): AccessLayerPDU | undefined {
        let lowerTransportData = networkLayerPDU.transportPDU
        let header = lowerTransportData[0]; //Lower transport pdu starts here
        let akf = (header >> 6) & 0x01;

        let ivIndex = networkLayerPDU.encryptionSuite.ivIndex;

        let unsegmentedAccessMessagePDU = new UnsegmentedAccessMessagePDU();
        if (unsegmentedAccessMessagePDU.parse(networkLayerPDU)) {

            let upperTransportEncryptionSuite: UpperTransportEncryptionSuite;
            if (AccessType.DEVICE == akf) {
                upperTransportEncryptionSuite =
                    {
                        deviceKey: this.getDeviceKey(networkLayerPDU.src),
                        ivIndex: ivIndex
                    }

            } else {
                let appKeyList = this.getAppKeyList();
                upperTransportEncryptionSuite = {
                    appKeyList: appKeyList,
                    ivIndex: ivIndex
                }
            }

            let upperTransportAccessPDU = new UpperTransportAccessPDU(upperTransportEncryptionSuite);
            let decRe = upperTransportAccessPDU.parseAndDecryptUnsegmentedMessage(unsegmentedAccessMessagePDU,
                networkLayerPDU.seq, networkLayerPDU.src, networkLayerPDU.dst);
            if (decRe) {
                return AccessLayerPDU.parse(upperTransportAccessPDU.decryptedPayload!);
            } else {
                logw("unsegmented access message parse err");
            }
        }
        return undefined;
    }

    /**
     * retrieves a list of app keys stored in the appKeyMap.
     *
     * @return app key list
     */
    private getAppKeyList(): ArrayList<Uint8Array> | undefined {
        if (this.appKeyMap != null && this.appKeyMap.length != 0) {
            let appKeyList = new ArrayList<Uint8Array>();
            for (let i = 0; i < this.appKeyMap.length; i++) {
                appKeyList.add(this.appKeyMap[i].key);
            }
            return appKeyList;
        }
        return undefined;
    }

    /**
     * This is a method that checks whether a segment block needs to be stopped or restarted based on the parameters passed.
     * If the parameter "immediate" is true, it stops the segment timeout task, otherwise, it restarts it.
     * The method also removes any pending callbacks for the "mAccessSegCheckTask" task and sets a new timeout based on the "ttl" parameter.
     * Finally, it posts a delayed task to the "mDelayHandler" with the "mAccessSegCheckTask" and the calculated timeout.
     *
     * @param immediate immediate
     * @param ttl       ttl
     * @param src       src
     */
    private async checkSegmentBlock(immediate: boolean, ttl: number, src: number) {
        if (immediate) {
            this.stopSegmentTimeoutTask();
        } else {
            this.restartSegmentTimeoutTask();
        }
        clearTimeout(this.mAccessSegCheckTask.timerId)
        let timeout = immediate ? 0 : await this.getSegmentedTimeout(ttl, false);
        this.mAccessSegCheckTask.src = src;
        this.mAccessSegCheckTask.ttl = ttl;
        logd("check segment block: immediate-" + immediate + " ttl-" + ttl + " src-" + src + " timeout-" + timeout);
        this.mAccessSegCheckTask.timerId = setTimeout(() => {
            this.sendSegmentBlockAck(src, ttl);
        }, timeout)
    }

    /**
     * Stop a task that checks for segment block acknowledgments.
     * It removes any pending callbacks from the delay handler associated with the task.
     */
    private stopSegmentBlockAckTask() {
        clearTimeout(this.mAccessSegCheckTask.timerId)
    }

    /**
     * This method is used to send a segment block acknowledgment message to a specific source with a given time-to-live (TTL) value.
     * It first clones the received segmented message buffer and checks if there are any messages in it.
     * If there are, it calculates the sequence number (seqZero) and block acknowledgment value (blockAck) for each message and creates a SegmentAcknowledgmentMessage object.
     * It then sends this message to the source using the sendSegmentAckMessage() method.
     * If all the segments have not been received yet, it sets a delay for checking the status of the segmented message transmission using the mAccessSegCheckTask.
     * This method is used in a communication protocol to ensure that all segments of a message are received correctly.
     *
     * @param src source
     * @param ttl ttl
     */
    private async sendSegmentBlockAck(src: number, ttl: number) {
        logd(`send segment block ack: ${num2Hex(src)}`);
        let messages = this.receivedSegmentedMessageBuffer // new Map([...this.receivedSegmentedMessageBuffer])
        if (messages.size > 0) {
            //            int segN = -1;
            let seqZero = -1;
            let blockAck = 0;
            // let segO: number;
            let segN = -1;

            messages.forEach((message, segO) => {
                if (segN == -1) {
                    segN = message.segN
                }
                if (seqZero == -1) {
                    seqZero = message.seqZero
                }
                blockAck |= (1 << segO);
            })

            let segmentAckMessage = new SegmentAcknowledgmentMessage();
            segmentAckMessage.seqZero = seqZero
            segmentAckMessage.blockAck = blockAck
            this.sendSegmentAckMessage(segmentAckMessage, src);

            let complete = messages.size == (segN + 1);
            if (!complete) {
                clearTimeout(this.mAccessSegCheckTask.timerId)
                let timeout = await this.getSegmentedTimeout(ttl, false);
                this.mAccessSegCheckTask.timerId = setTimeout(() => {
                    this.sendSegmentBlockAck(src, ttl);
                }, timeout)
            }
        }
    }

    /**
     * send segment busy
     * send a busy acknowledgment message for a segment block.
     *
     * @param src     the source of the acknowledgment
     * @param seqZero the sequence number of the segment block
     * @param seqAuth the sequence authentication value
     */
    private sendSegmentBlockBusyAck(src: number, seqZero: number, seqAuth: number) {
        logd("send segment block busy ack:" + src);
        this.saveBusySeqAuth(src, seqAuth);
        let segmentAckMessage = new SegmentAcknowledgmentMessage();
        segmentAckMessage.seqZero = seqZero
        segmentAckMessage.blockAck = 0
        this.sendSegmentAckMessage(segmentAckMessage, src);
    }

    /**
     * send a segment acknowledgment message to a specific destination.
     *
     * @param segmentAcknowledgmentMessage message
     * @param dst                          dst
     */
    private sendSegmentAckMessage(segmentAcknowledgmentMessage: SegmentAcknowledgmentMessage, dst: number) {
        logd("send segment ack: " + segmentAcknowledgmentMessage.toString());
        this.sendUnsegmentedControlMessage(segmentAcknowledgmentMessage, dst);
    }

    /**
     * send an unsegmented control message.
     * It takes a control message PDU as input and converts it to a byte array.
     *
     * @param controlMessagePDU control message pdu
     * @param dst               dst
     */
    private sendUnsegmentedControlMessage(controlMessagePDU: UnsegmentedControlMessagePDU, dst: number) {
        let data = controlMessagePDU.toByteArray();
        logd("send control message: " + bytesToHexString(data, ""));
        let ctl = MeshMessage.CTL_CONTROL;
        let ttl = 5;
        let src = this.localAddress;
        let ivIndex = this.getTransmitIvIndex();
        let networkPDU: NetworkLayerPDU =
            this.createNetworkPDU(data, ctl, ttl, src, dst, ivIndex, this.mSequenceNumber);
        this.sendNetworkPdu(networkPDU);
    }

    private onSegmentTimeout() {
        this.stopSegmentBlockAckTask();
        logd(`segment timeout : lastSeqAuth: 0x${num2Hex(this.lastSeqAuth, 14)}  -- src: 0x${num2Hex(this.lastSegSrc,
            4)}`);
        this.lastSegComplete = true;
        this.lastSegSrc = 0;
        this.lastSeqAuth = 0;
    }


    /**
     * restart segment timer
     */
    private restartSegmentTimeoutTask() {
        clearTimeout(
            this.segmentTimeoutTask.timerId
        )
        this.segmentTimeoutTask.timerId = setTimeout(
            () => {
                this.onSegmentTimeout()
            }
            , NetworkingController.SEG_TIMEOUT)
    }

    /**
     * stop segment timer
     */
    private stopSegmentTimeoutTask() {
        clearTimeout(this.segmentTimeoutTask.timerId)
    }

    /**
     * send a segment acknowledgment message to a specified source with information
     *
     * @param src     src
     * @param segN    segN
     * @param seqZero seqZero
     */
    private sendSegmentCompleteBlockAck(src: number, segN: number, seqZero: number) {
        let blockAck = 0;
        for (let i = 0; i < segN + 1; i++) {
            blockAck |= (1 << i);
        }
        let segmentAckMessage = new SegmentAcknowledgmentMessage();
        segmentAckMessage.seqZero = seqZero
        segmentAckMessage.blockAck = blockAck
        this.sendSegmentAckMessage(segmentAckMessage, src);
    }

    /**
     * parse segmented access message
     * check auth
     */
    /**
     * This method is used to parse a segmented access message received from the network layer.
     * It extracts the necessary information from the network layer PDU and constructs a segmented access message PDU.
     * It then performs various checks and operations to ensure the integrity and completeness of the segmented message.
     * Finally, it decrypts the segmented message and returns the access layer PDU.
     *
     * @param networkLayerPDU The network layer PDU containing the segmented access message.
     * @return The access layer PDU decrypted from the segmented access message, or null if there was an error.
     */
    private parseSegmentedAccessMessage(networkLayerPDU: NetworkLayerPDU): AccessLayerPDU | undefined {
        // Create a new segmented access message PDU and parse the network layer PDU into it
        let message = new SegmentedAccessMessagePDU();
        message.parse(networkLayerPDU);
        // Extract necessary information from the network layer PDU
        let src = networkLayerPDU.src
        let ttl = networkLayerPDU.ttl & 0xFF;
        let sequenceNumber = networkLayerPDU.seq;

        let seqLowerBitValue = sequenceNumber & NetworkingController.SEQ_ZERO_LIMIT;

        let seqZero = message.seqZero

        let seqHigherBitValue: number
        // Calculate the higher bit value of the sequence number based on the lower bit value and the seqZero value
        if (seqLowerBitValue < seqZero) {
            seqHigherBitValue = (sequenceNumber - (NetworkingController.SEQ_ZERO_LIMIT + 1)) & 0xFFE000;
        } else {
            seqHigherBitValue = sequenceNumber & 0xFFE000;
        }

        // Calculate the transport sequence number by combining the higher bit value and the seqZero value
        // sequence number of first segmented message
        let transportSeqNo = seqHigherBitValue | seqZero;
        let ivIndex = networkLayerPDU.encryptionSuite.ivIndex;
        // seq auth:   ivIndex(32bits) | seqNo(11bits) | seqZero(13bits)
        // 0x7FFFFFFFL remove highest bit
        // Calculate the seqAuth value for authentication
        let seqAuth = (transportSeqNo & 0xFFFFFF) | ((ivIndex & 0x7FFFFFFF) << 24);

        // Extract the segO and segN values from the segmented access message PDU
        let segO = message.segO
        let segN = message.segN

        logd(`lastComplete? :${this.lastSegComplete} -- seqAuth: 0x${num2Hex(seqAuth,
            14)} -- lastSeqAuth: 0x${num2Hex(this.lastSeqAuth, 14)} -- src: 0x${num2Hex(src, 4)}
         -- lastSrc: 0x%${num2Hex(this.lastSegSrc, 4)} -- seg0: ${segO} -- segN: ${segN}`);

        if (this.isBusyAuthExists(src, seqAuth)) {
            logd("busy auth exists");
            this.sendSegmentBlockBusyAck(src, seqZero, seqAuth);
            return undefined;
        }

        if (this.isCompleteAuthExists(src, seqAuth)) {
            logd("complete auth exists");
            this.sendSegmentCompleteBlockAck(src, segN, seqZero);
            return undefined;
        }

        let accessPDU: AccessLayerPDU | undefined = undefined;

        // Check if the current seqAuth and source values are different from the last ones
        if (seqAuth != this.lastSeqAuth || this.lastSegSrc != src) {
            if (this.lastSegComplete) {
                logd("last segment complete");
                // save last seqAuth
                this.saveCompletedSeqAuth(this.lastSegSrc, this.lastSeqAuth);
                this.lastSegComplete = false;
                // new segment message
                this.lastSeqAuth = seqAuth;
                this.lastSegSrc = src;
                this.receivedSegmentedMessageBuffer.clear();
            } else {
                this.sendSegmentBlockBusyAck(src, seqZero, seqAuth);
                return undefined;
            }
        }

        {
            this.receivedSegmentedMessageBuffer
                .set(segO, message);

            let messageCnt = this.receivedSegmentedMessageBuffer.size
            logd("received segment message count: " + messageCnt);

            if (messageCnt != segN + 1) {
                this.lastSeqAuth = seqAuth;
                this.checkSegmentBlock(false, ttl, src);
            } else {
                this.lastSegComplete = true;
                this.checkSegmentBlock(true, ttl, src);
                if (this.isCompleteAuthExists(src, seqAuth)) {
                    logd(" seqAuth already received: " + seqAuth);
                    this.lastSeqAuth = 0;
                    return undefined;
                }
                let encryptionSuite: UpperTransportEncryptionSuite
                let akf = message.akf
                if (akf == AccessType.APPLICATION) {
                    encryptionSuite = { appKeyList: this.getAppKeyList(), ivIndex: ivIndex }
                } else {
                    let deviceKey = this.getDeviceKey(src);
                    if (deviceKey == null) {
                        logw("Device key not found when decrypt segmented access message");
                        return undefined;
                    }
                    encryptionSuite = { deviceKey: deviceKey, ivIndex: ivIndex }
                }

                let upperTransportAccessPDU = new UpperTransportAccessPDU(encryptionSuite);
                upperTransportAccessPDU.parseAndDecryptSegmentedMessage(this.receivedSegmentedMessageBuffer,
                    transportSeqNo, src, networkLayerPDU.dst);

                let completeTransportPdu = upperTransportAccessPDU.decryptedPayload;

                logd("decrypted upper: " + bytesToHexString(completeTransportPdu, ""));
                if (completeTransportPdu != null) {
                    accessPDU = AccessLayerPDU.parse(completeTransportPdu);
                } else {
                    logw("upper pdu decryption error: ");
                }
            }
        }
        return accessPDU;
    }

    /**
     * Creates an UpperTransportAccessPDU object with the given parameters.
     *
     * @param accessPDU  The Access PDU to be encrypted.
     * @param key        The encryption key.
     * @param szmic      The value indicating the size of the Message Integrity Check (MIC).
     * @param accessType The type of access.
     * @param ivIndex    The IV index.
     * @param seqNo      The sequence number.
     * @param src        The source address.
     * @param dst        The destination address.
     * @return The created UpperTransportAccessPDU object, or null if encryption fails.
     */
    private createUpperTransportAccessPDU(accessPDU: Uint8Array, key: Uint8Array, szmic: number, accessType: AccessType,
        ivIndex: number, seqNo: number, src: number, dst: number): UpperTransportAccessPDU | undefined {

        let encryptionSuite: UpperTransportEncryptionSuite;

        if (accessType == AccessType.APPLICATION) {
            let appKeyList: ArrayList<Uint8Array> = new ArrayList();
            appKeyList.add(key);
            encryptionSuite = {
                appKeyList: appKeyList,
                ivIndex: ivIndex
            }
        } else {
            encryptionSuite = {
                deviceKey: key,
                ivIndex: ivIndex
            }
        }
        let upperTransportAccessPDU =
            new UpperTransportAccessPDU(encryptionSuite);
        if (upperTransportAccessPDU.encrypt(accessPDU, szmic, accessType, seqNo, src, dst)) {
            return upperTransportAccessPDU;
        } else {
            return undefined;
        }
    }

    /**
     * Creates segmented access message PDUs for a given encrypted upper transport PDU.
     *
     * @param encryptedUpperTransportPDU The encrypted upper transport PDU.
     * @param akf                        The Application Key Flag.
     * @param aid                        The Application Identifier.
     * @param aszmic                     The value indicating whether the message integrity check is required.
     * @param sequenceNumber             The sequence number of the message.
     * @param segmentLen                 The length of each segment.
     * @return A SparseArray containing the segmented access message PDUs.
     */
    private createSegmentedAccessMessage(encryptedUpperTransportPDU: Uint8Array, akf: number, aid: number,
        aszmic: number, sequenceNumber: number, segmentLen: number): ArrayList<SegmentedAccessMessagePDU> {

        let segmentedAccessLen = segmentLen + 1;
        let seqNoBuffer = num2bytes(sequenceNumber, 3, ByteOrder.BIG_ENDIAN);
        // 13 lowest bits
        let seqZero = ((seqNoBuffer[1] & 0x1F) << 8) | (seqNoBuffer[2] & 0xFF);

        // segment pdu number
        let segNum =
            Math.ceil((encryptedUpperTransportPDU.length) / segmentedAccessLen); // SEGMENTED_ACCESS_PAYLOAD_MAX_LENGTH
        let segN = segNum - 1; // index from 0
        logd("create segmented access message: seqZero - " + seqZero + " segN - " + segN);

        let lowerTransportPDUArray: ArrayList<SegmentedAccessMessagePDU> = new ArrayList();
        let offset = 0;
        let segmentedLength: number;
        let lowerTransportPDU: SegmentedAccessMessagePDU;
        for (let segOffset = 0; segOffset < segNum; segOffset++) {
            segmentedLength = Math.min(encryptedUpperTransportPDU.length - offset, segmentedAccessLen);
            lowerTransportPDU = new SegmentedAccessMessagePDU();
            lowerTransportPDU.akf = (akf);
            lowerTransportPDU.aid = (aid);
            lowerTransportPDU.szmic = (aszmic);
            lowerTransportPDU.seqZero = (seqZero);
            lowerTransportPDU.segO = (segOffset);
            lowerTransportPDU.segN = (segN);
            lowerTransportPDU.segmentM = encryptedUpperTransportPDU.slice(offset, offset + segmentedLength)
            offset += segmentedLength;
            lowerTransportPDUArray.add(lowerTransportPDU)
        }
        return lowerTransportPDUArray;
    }


    /**
     * Creates an unsegmented access message PDU for a given upper transport PDU.
     *
     * @param upperTransportPDU The upper transport PDU.
     * @param akf               The Application Key Flag.
     * @param aid               The Application Identifier.
     * @return The unsegmented access message PDU.
     */
    private createUnsegmentedAccessMessage(upperTransportPDU: Uint8Array, akf: number,
        aid: number): UnsegmentedAccessMessagePDU {
        let pdu = new UnsegmentedAccessMessagePDU();
        pdu.akf = akf
        pdu.aid = aid
        pdu.upperTransportPDU = upperTransportPDU
        return pdu
    }

    /**
     * Creates a network layer PDU for a given transport PDU and other parameters.
     *
     * @param transportPdu   The transport PDU.
     * @param ctl            The Control field value.
     * @param ttl            The Time To Live value.
     * @param src            The source address.
     * @param dst            The destination address.
     * @param ivIndex        The IV Index value.
     * @param sequenceNumber The sequence number of the message.
     * @return The network layer PDU.
     */
    private createNetworkPDU(transportPdu: Uint8Array,
        ctl: number, ttl: number, src: number, dst: number, ivIndex: number, sequenceNumber: number): NetworkLayerPDU {
        let networkLayerPDU = new NetworkLayerPDU(
            {
                ivIndex: ivIndex,
                encryptionKey: this.encryptionKey,
                privacyKey: this.privacyKey,
                nid: this.nid
            }
        );
        networkLayerPDU.ivi = ivIndex & 0x01
        networkLayerPDU.nid = this.nid
        networkLayerPDU.ctl = ctl
        networkLayerPDU.ttl = ttl
        networkLayerPDU.seq = sequenceNumber
        networkLayerPDU.src = src
        networkLayerPDU.dst = dst
        networkLayerPDU.transportPDU = transportPdu

        // for every network pdu , sequence number should increase
        this.increaseSequenceNumber();
        return networkLayerPDU;
    }

    /**
     * Creates a proxy configuration PDU for a given transport PDU and other parameters.
     *
     * @param transportPdu   The transport PDU.
     * @param src            The source address.
     * @param ivIndex        The IV Index value.
     * @param sequenceNumber The sequence number of the message.
     * @return The proxy configuration PDU.
     */
    private createProxyConfigurationPdu(transportPdu: Uint8Array, src: number, ivIndex: number,
        sequenceNumber: number): ProxyConfigurationPDU {
        let networkLayerPDU = new ProxyConfigurationPDU({
            ivIndex: ivIndex,
            encryptionKey: this.encryptionKey,
            privacyKey: this.privacyKey,
            nid: this.nid
        }
        );
        networkLayerPDU.ivi = (ivIndex & 0x01)
        networkLayerPDU.nid = (this.nid);
        networkLayerPDU.ctl = (ProxyConfigurationPDU.ctl);
        networkLayerPDU.ttl = (ProxyConfigurationPDU.ttl);
        networkLayerPDU.seq = (sequenceNumber);
        networkLayerPDU.src = (src);
        networkLayerPDU.dst = (ProxyConfigurationPDU.dst);
        networkLayerPDU.transportPDU = (transportPdu);

        // for every network pdu , sequence number should increase
        this.increaseSequenceNumber();
        return networkLayerPDU;
    }
}


/**
 * Segment ack message timeout task
 */
interface SegmentedMessageTimeoutTask {
    timerId: number
}

/**
 * This class represents a task that is executed in a separate thread.
 */
interface SegmentBlockWaitingTask {
    timerId: number,
    ctl: number,
    ttl: number,
    src: number,
    dst: number,
}


/**
 * Segment ack message task
 */
interface SegmentAckMessageSentTask {
    timerId: number
    src: number
    ttl: number

    // public  run(): void {
    //     sendSegmentBlockAck(src, ttl);
    // }
}

interface SegmentTimeoutTask {
    timerId: number
}
