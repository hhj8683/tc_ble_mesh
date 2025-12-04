/********************************************************************************************************
 * @file StatusNotificationEvent.java
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
import { NotificationMessage } from "../../core/message/NotificationMessage";
import { Event } from "../Event";

/**
 * Mesh Status Message Event
 * event will dispatched when received mesh status
 * For known messages, registering in MeshStatus.Container is suggested
 * If StatusMessage is registered in {@link com.telink.ble.mesh.core.message.MeshStatus.Container}
 * the eventType of the status event will be valued by the className (Class.getName),
 * otherwise, it will be valued by {@link #EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN}
 * <p>
 * Created by kee on 2019/9/12.
 */
export class StatusNotificationEvent implements Event {
    public type: string;
    /**
     * all unrecognized notification
     */
    public static readonly EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN =
        "com.telink.ble.mesh.EVENT_TYPE_NOTIFICATION_MESSAGE_UNKNOWN";
    /**
     * event message
     */
    public notificationMessage: NotificationMessage;

    /**
     * Constructor for the StatusNotificationEvent class.
     *
     * @param sender              the object that sends the event
     * @param type                the type of the event
     * @param notificationMessage the notification message associated with the event
     */
    public constructor(type: string, notificationMessage: NotificationMessage) {
        this.type = type
        this.notificationMessage = notificationMessage;
    }
}