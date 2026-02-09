/********************************************************************************************************
 * @file UnitConvert.ets
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
import { logd } from "telinksigmeshlib";

/**
 * Created by kee on 2017/11/28.
 */
export class UnitConvert {

    /**
     * @param lum 0-100
     * @return -32768-32767
     */
    public static  lum2level( lum: number) {
        if (lum > 100) {
            lum = 100;
        }
        return (-32768 + (65535 * lum) / 100);
    }

    /**
     * @param level -32768-32767
     * @return lum 0-100
     */
    public static  level2lum( level: number) {
        let lightness = level + 32768;
        let fix = 0;
        if (lightness != 0) {
            let levelUnit = 65535 / 100 / 2;
            if (lightness < levelUnit + 2) {
                lightness = levelUnit * 2;
            }
            fix = levelUnit;
        }
        let re = (((lightness + fix) * 100) / 65535);
        return re;
    }

    /**
     * @param lum 0-100
     * @return 0-65535
     */
    public static  lum2lightness( lum: number) {
        return  Math.ceil( 65535 * lum / 100)
    }

    /**
     * @param lightness 0-65535
     * @return lum 0-100
     */
    public static lightness2lum( lightness: number) {
//        return lightness * 100 / 65535;
        let fix = 0;
        if (lightness != 0) {
            let levelUnit = 65535 / 100 / 2;
            if (lightness < levelUnit + 2) {
                lightness = levelUnit * 2;
            }
            fix = levelUnit;
        }
        let re = (((lightness + fix) * 100) / 65535);
        logd("lightness2lum: " + lightness + " re: " + re);
        return re;
    }

    /**
     * TEMP_MIN	 800
     * TEMP_MAX	 20000
     *
     * @param temp100 0-100
     * @return 800-2000
     */
    public static temp100ToTemp( temp100: number) {
        if (temp100 > 100) {
            temp100 = 100;
        }
        return (800 + ((20000 - 800) * temp100) / 100);
    }

    /**
     * @param temp 800-2000
     * @return temp100 0-100
     */
    public static  tempToTemp100( temp: number) {
        if (temp < 800) return 0;
        if (temp > 20000) return 100;
        return (temp - 800) * 100 / (20000 - 800);
    }


    /**
     * get zone offset, 15min
     *
     * @return zoneOffSet
     */
    public static  getZoneOffset() {
        return new Date().getTimezoneOffset() / 15 + 64
        // zone offset and daylight offset
        // return (cal.get(Calendar.ZONE_OFFSET) + cal.get(Calendar.DST_OFFSET)) / 60 / 1000 / 15 + 64;
    }
}
