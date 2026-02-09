/********************************************************************************************************
 * @file     Colors.ets 
 *
 * @brief    for TLSR chips
 *
 * @author	 telink
 * @date     Sep. 30, 2010
 *
 * @par      Copyright (c) 2016, Telink Semiconductor (Shanghai) Co., Ltd.
 *           All rights reserved.
 *           
 *			 The information contained herein is confidential and proprietary property of Telink 
 * 		     Semiconductor (Shanghai) Co., Ltd. and is available under the terms 
 *			 of Commercial License Agreement between Telink Semiconductor (Shanghai) 
 *			 Co., Ltd. and the licensee in separate contract or the terms described here-in. 
 *           This heading MUST NOT be removed from this file.
 *
 * 			 Licensees are granted free, non-transferable use of the information in this 
 *			 file under Mutual Non-Disclosure Agreement. NO WARRENTY of ANY KIND is provided. 
 *           
 *******************************************************************************************************/
/********************************************************************************************************
 * @file Colors.ets
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
export class Colors {
    /**
     *
     * @param h 0-360
     * @param s 0-1.0
     * @param v 0-1.0
     * @returns Integer value such as : 1134BC
     */
    public static hsvToRgb(h: number, s: number, v: number): number {
        let r = 0, g = 0, b = 0;
        let i = parseInt((h / 60) % 6 + "");
        let f = h / 60 - i;
        let p = v * (1 - s);
        let q = v * (1 - f * s);
        let t = v * (1 - (1 - f) * s);
        switch (i) {
            case 0:
                r = v;
                g = t;
                b = p;
                break;
            case 1:
                r = q;
                g = v;
                b = p;
                break;
            case 2:
                r = p;
                g = v;
                b = t;
                break;
            case 3:
                r = p;
                g = q;
                b = v;
                break;
            case 4:
                r = t;
                g = p;
                b = v;
                break;
            case 5:
                r = v;
                g = p;
                b = q;
                break;
            default:
                break;
        }
        r = r * 255.0
        g = g * 255.0
        b = b * 255.0

        // return [r, g, b];
        return (Math.ceil(r) << 16) | (Math.ceil(g) << 8) | Math.ceil(b)
        // return [Math.ceil(r), Math.ceil(g), Math.ceil(b)];
    }

    /**
     * RGB转HSV
     * @param r 红色值 (0-255)
     * @param g 绿色值 (0-255)
     * @param b 蓝色值 (0-255)
     * @returns HSV对象 {h: 色相(0-360), s: 饱和度(0-1), v: 明度(0-1)}
     */
    static rgbToHsv(rgb: number) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = rgb & 0xFF
        let rNorm = r / 255;
        let gNorm = g / 255;
        let bNorm = b / 255;

        let max = Math.max(rNorm, gNorm, bNorm);
        let min = Math.min(rNorm, gNorm, bNorm);
        let delta = max - min;

        let h = 0, s = 0, v = max

        if (max !== 0) {
            s = (delta / max)
        }

        if (delta !== 0) {
            if (max === rNorm) {
                h = ((gNorm - bNorm) / delta) % 6;
            } else if (max === gNorm) {
                h = (bNorm - rNorm) / delta + 2;
            } else {
                h = (rNorm - gNorm) / delta + 4;
            }

            h *= 60;
            if (h < 0) {
                h += 360;
            }
        }
        return [Math.round(h), s, v]
    }

    public static rgbToHsl(rgb: number) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = rgb & 0xFF
        let rf = r / 255
        let gf = g / 255
        let bf = b / 255

        const max = Math.max(rf, Math.max(gf, bf));
        const min = Math.min(rf, Math.min(gf, bf));
        const deltaMaxMin = max - min;

        let h: number, s: number;
        let l = (max + min) / 2

        if (max == min) {
            // Monochromatic
            h = s = 0
        } else {
            if (max == rf) {
                h = ((gf - bf) / deltaMaxMin) % 6
            } else if (max == gf) {
                h = ((bf - rf) / deltaMaxMin) + 2
            } else {
                h = ((rf - gf) / deltaMaxMin) + 4
            }

            s = deltaMaxMin / (1 - Math.abs(2 * l - 1));
        }

        h = (h * 60) % 360
        if (h < 0) {
            h += 360
        }
        return [Colors.constrain(h, 0, 360), Colors.constrain(s, 0, 1), Colors.constrain(l, 0, 1)]
    }

    public static hslToRgb(h: number, s: number, l: number){

        const c = (1 - Math.abs(2 * l - 1)) * s;
        const m = l - 0.5 * c;
        const x = c * (1 - Math.abs((h / 60 % 2) - 1));

        const hueSegment =  h / 60;

        let r = 0, g = 0, b = 0;

        switch (hueSegment) {
            case 0:
                r = Math.round(255 * (c + m));
                g = Math.round(255 * (x + m));
                b = Math.round(255 * m);
                break;
            case 1:
                r = Math.round(255 * (x + m));
                g = Math.round(255 * (c + m));
                b = Math.round(255 * m);
                break;
            case 2:
                r = Math.round(255 * m);
                g = Math.round(255 * (c + m));
                b = Math.round(255 * (x + m));
                break;
            case 3:
                r = Math.round(255 * m);
                g = Math.round(255 * (x + m));
                b = Math.round(255 * (c + m));
                break;
            case 4:
                r = Math.round(255 * (x + m));
                g = Math.round(255 * m);
                b = Math.round(255 * (c + m));
                break;
            case 5:
            case 6:
                r = Math.round(255 * (c + m));
                g = Math.round(255 * m);
                b = Math.round(255 * (x + m));
                break;
        }

        r = Colors.constrain(r, 0, 255);
        g = Colors.constrain(g, 0, 255);
        b = Colors.constrain(b, 0, 255);

        return (r << 16) | (g << 8) | b
    }

    private static constrain(amount: number, low: number, high: number) {
        return amount < low ? low : (amount > high ? high : amount);
    }
}
