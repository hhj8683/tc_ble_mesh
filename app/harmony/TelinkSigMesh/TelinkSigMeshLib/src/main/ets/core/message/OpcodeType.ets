/********************************************************************************************************
 * @file OpcodeType.java
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

import { bit } from "../../utils/MeshUtils";

/**
 * opcode type
 */
export enum OpcodeType {
    SIG_1 = 1, // Opcode type for SIG_1
    SIG_2 = 2, // Opcode type for SIG_2
    VENDOR = 3 // Opcode type for VENDOR
}

/**
 * Returns the OpcodeType based on the first byte of the opcode.
 *
 * @param opFst The first byte of the opcode.
 * @return The OpcodeType.
 */
export function getByFirstByte(opFst: number): OpcodeType {
    return (opFst & bit(7)) != 0
        ?
        ((opFst & bit(6)) != 0 ? OpcodeType.VENDOR : OpcodeType.SIG_2)
        :
    OpcodeType.SIG_1;
}