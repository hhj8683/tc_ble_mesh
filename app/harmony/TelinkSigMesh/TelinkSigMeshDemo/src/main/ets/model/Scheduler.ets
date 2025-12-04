/********************************************************************************************************
 * @file Scheduler.java
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
import { ByteOrder, bytes2Long, num2bytes, num2Hex } from "telinksigmeshlib";
import { SchedulerRegister } from "./SchedulerRegister";


/**
 * scheduler
 * Created by kee on 2018/9/17.
 * Mesh_Model_Specification v1.0.pdf#5.2.3.4
 */
export class Scheduler {
    /**
     * #ref desc
     */
    public static readonly YEAR_ANY = 0x64;
    public static readonly DAY_ANY = 0x00;
    public static readonly HOUR_ANY = 0x18;
    public static readonly HOUR_RANDOM = 0x19;
    public static readonly MINUTE_ANY = 0x3C;
    public static readonly MINUTE_CYCLE_15 = 0x3D;
    public static readonly MINUTE_CYCLE_20 = 0x3E;
    public static readonly MINUTE_RANDOM = 0x3F;
    public static readonly SECOND_ANY = 0x3C;
    public static readonly SECOND_CYCLE_15 = 0x3D;
    public static readonly SECOND_CYCLE_20 = 0x3E;
    public static readonly SECOND_RANDOM = 0x3F;
    public static readonly ACTION_OFF = 0x0;
    public static readonly ACTION_ON = 0x1;
    public static readonly ACTION_SCENE = 0x2;
    public static readonly ACTION_NO = 0xF;
    /**
     * 4 bits
     */
    public index = 0;
    /**
     * 76 bits
     */
    public register: SchedulerRegister = new SchedulerRegister()
    // for device with multiple elements
    // use 0 as default for primary element
    public elementOffset = 0;

    public Scheduler() {
    }

    public getIndex() {
        return this.index;
    }


    public static fromBytes(data: Uint8Array): Scheduler | undefined {
        if (data == null || data.length != 10) {
            return undefined;
        }
        let index = data[0] & 0x0F
        let reg = new SchedulerRegister();
        reg.year = (data[0] >> 4 & 0b1111) | ((data[1] & 0b111) << 4);
        reg.month = (data[1] >> 3 & 0b11111) | ((data[2] & 0b1111111) << 5);
        reg.day = (data[2] >> 7 & 0b1) | ((data[3] & 0b1111) << 1); // d3 4
        reg.hour = (data[3] >> 4 & 0b1111) | ((data[4] & 0b1) << 4); // d4 1
        reg.minute = ((data[4] >> 1) & 0b111111); // d4 7
        reg.second = ((data[4] >> 7 & 0b1) | ((data[5] & 0b11111)) << 1); // d5 5
        reg.week = ((data[5] >> 5 & 0b111) | ((data[6] & 0b1111)) << 3); // d6 4
        reg.action = (data[6] >> 4 & 0b1111); // d6 8
        reg.transTime = data[7] & 0xFF; // d7 8
        reg.sceneId = (data[8] & 0xFF) | ((data[9] << 8) & 0xFF); // d8 d9
        let scheduler = new Scheduler();
        scheduler.index = index;
        scheduler.register = reg
        return scheduler;
    }

    public toBytes(): Uint8Array {
        // ByteBuffer byteBuffer = ByteBuffer.allocate(10).order(ByteOrder.LITTLE_ENDIAN);
        let byteBuffer = new Uint8Array(10)
        let regn = this.index |
            this.register.year << 4 |
            this.register.month << 11 |
            this.register.day << 23 |
            this.register.hour << 28 |
            this.register.minute << 33 |
            this.register.second << 39 |
            this.register.week << 45 |
            this.register.action << 52 |
            this.register.transTime << 56
        byteBuffer.set(num2bytes(regn, 8, ByteOrder.LITTLE_ENDIAN), 0)
        byteBuffer.set(num2bytes(this.register.sceneId, 2), 8)
        return byteBuffer
    }
}


export class SchedulerBuilder {
    /**
     * 4 bits
     * Index of the Schedule Register entry to set
     * 0x0-0xF
     */
    private index = 1;
    /**
     * 7 bits
     * 0x00–0x63: 2 least significant digits of the year
     * 0x64: Any year
     * All other values: Prohibited
     */
    private year = 0x00;
    /**
     * 12 bits
     * bit 0-11 means Scheduled in
     * January/February/March/April/May/June/July/August/September/October/November/December
     */
    private month = 0b000000000000;
    /**
     * 5 bits
     * 0x00 Any day
     * 0x01–0x1F Day of the month, when number overflow, event occurs in the last day
     */
    private day = 0x00;
    /**
     * 5 bits
     * 0x00–0x17: Hour of the day (00 to 23 hours)
     * 0x18: Any hour of the day
     * 0x19: Once a day (at a random hour)
     * All other values: Prohibited
     */
    private hour = 0x00;
    /**
     * 6 bits
     * 0x00–0x3B Minute of the hour (00 to 59)
     * 0x3C Any minute of the hour
     * 0x3D Every 15 minutes (minute modulo 15 is 0) (0, 15, 30, 45)
     * 0x3E Every 20 minutes (minute modulo 20 is 0) (0, 20, 40)
     * 0x3F Once an hour (at a random minute)
     */
    private minute = 0x00;
    /**
     * 6 bits
     * 0x00–0x3B Second of the minute (00 to 59)
     * 0x3C Any second of the minute
     * 0x3D Every 15 seconds (minute modulo 15 is 0) (0, 15, 30, 45)
     * 0x3E Every 20 seconds (minute modulo 20 is 0) (0, 20, 40)
     * 0x3F Once an minute (at a random second)
     */
    private second = 0x00;
    /**
     * 7 bits
     * bit 0-6 means
     * Scheduled on Mondays/Tuesdays/Wednesdays/Thursdays/Fridays/Saturdays/Sundays
     */
    private week = 0b000000;
    /**
     * 4 bits
     * 0x0 Turn Off
     * 0x1 Turn On
     * 0x2 Scene Recall
     * 0xF No action
     * All other values
     * Reserved for Future Use
     */
    private action = 0;
    /**
     * 8 bits
     * #reference model spec 3.1.3.1
     * bit 0-5 The number of Steps
     * bit 6-7 Transition Step Resolution
     */
    private transTime = 0;
    /**
     * 16 bit
     * scene id
     */
    private sceneId = 0;
    private elementOffset = 0;

    public setIndex(index: number): SchedulerBuilder {
        this.index = index;
        return this;
    }

    public setYear(year: number): SchedulerBuilder {
        this.year = year;
        return this;
    }

    public setMonth(month: number): SchedulerBuilder {
        this.month = month;
        return this;
    }

    public setDay(day: number): SchedulerBuilder {
        this.day = day;
        return this;
    }

    public setHour(hour: number): SchedulerBuilder {
        this.hour = hour;
        return this;
    }

    public setMinute(minute: number): SchedulerBuilder {
        this.minute = minute;
        return this;
    }

    public setSecond(second: number): SchedulerBuilder {
        this.second = second;
        return this;
    }

    public setWeek(week: number): SchedulerBuilder {
        this.week = week;
        return this;
    }

    public setAction(action: number): SchedulerBuilder {
        this.action = action;
        return this;
    }

    public setTransTime(transTime: number): SchedulerBuilder {
        this.transTime = transTime;
        return this;
    }

    public setSceneId(sceneId: number): SchedulerBuilder {
        this.sceneId = sceneId;
        return this;
    }

    public setElementOffset(elementOffset: number): SchedulerBuilder {
        this.elementOffset = elementOffset;
        return this;
    }

    public build(): Scheduler {
        let register = SchedulerRegister.getByParams(
            this.year,
            this.month,
            this.day,
            this.hour,
            this.minute,
            this.second,
            this.week,
            this.action,
            this.transTime,
            this.sceneId
        );
        let scheduler = new Scheduler();
        scheduler.index = this.index;
        scheduler.register = register
        scheduler.elementOffset = this.elementOffset;
        return scheduler;
    }
}
