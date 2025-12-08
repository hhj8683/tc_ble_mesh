/********************************************************************************************************
 * @file HttpClient.ets
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

import { http } from '@kit.NetworkKit';
import { logd, loge } from 'telinksigmeshlib';
import { JSON } from '@kit.ArkTS';


/**
 * Created by kee on 2017/11/28.
 */
const BASE_URL = "http://47.115.164.97:8080/"

const URL_UPLOAD = "upload";

const URL_DOWNLOAD = "download";


const DEFAULT_TIMEOUT = 5 * 60 * 1000

interface UploadRequestData {
    data: string
    timeout: string
}

interface HttpResponse {
    isSuccess: boolean
    // = 200
    resultCode: number
    msg: string
    data: Object
}


export class HttpClient {
    public static async upload(json: string): Promise<string | undefined> {
        // let url = `${BASE_URL + URL_UPLOAD}?data=${json}&timeout=${DEFAULT_TIMEOUT}`
        let url = `${BASE_URL + URL_UPLOAD}`
        logd('[upload] url : ' + url)
        const httpRequest = http.createHttp()
        try {
            const rsp = await httpRequest.request(url, {
                expectDataType: http.HttpDataType.STRING,
                method: http.RequestMethod.POST,
                extraData: `data=${json}&timeout=${DEFAULT_TIMEOUT}`
            })
            if (!rsp || !rsp.result) {
                loge("[upload] rsp err")
                httpRequest.destroy()
                return
            }
            logd("[upload] http rsp : " + JSON.stringify(rsp))
            if (typeof rsp.result != 'string') {
                loge('[upload] http rsp result type err : ' + (typeof rsp.result))
                httpRequest.destroy()
                return
            }
            let httpRsp: HttpResponse = JSON.parse(rsp.result) as HttpResponse
            if (!httpRsp || !httpRsp.isSuccess) {
                loge("[upload] http rsp err : " + JSON.stringify(rsp))
                httpRequest.destroy()
                return
            }
            let uuid: string = httpRsp.data as string
            if (!uuid) {
                loge("[upload] rsp data err : " + JSON.stringify(httpRsp))
                httpRequest.destroy()
                return
            }
            logd("[upload] upload success : " + uuid)
            httpRequest.destroy()
            return uuid
        } catch (e) {
            loge('[upload] upload fail：', JSON.stringify(e))
        }
        return
    }

    public static async download(uuid: string): Promise<string | undefined> {
        // let url = `${BASE_URL + URL_DOWNLOAD}?uuid=${uuid}`
        let url = BASE_URL + URL_DOWNLOAD
        logd('[download] url : ' + url)
        const httpRequest = http.createHttp()
        try {

            const rsp = await httpRequest.request(url, {
                expectDataType: http.HttpDataType.STRING,
                method: http.RequestMethod.POST,
                extraData: `uuid=${uuid}`
            })

            if (!rsp || !rsp.result) {
                loge("[download] rsp err")
                httpRequest.destroy()
                return
            }
            logd("[download] http rsp : " + JSON.stringify(rsp))
            if (typeof rsp.result != 'string') {
                loge('[download] http rsp result type err : ' + (typeof rsp.result))
                httpRequest.destroy()
                return
            }
            let httpRsp: HttpResponse = JSON.parse(rsp.result) as HttpResponse
            if (!httpRsp || !httpRsp.isSuccess) {
                loge("[download] http rsp err : " + JSON.stringify(rsp))
                httpRequest.destroy()
                return
            }
            let meshJson: string = httpRsp.data as string
            if (!meshJson) {
                loge("[download] rsp data err : " + JSON.stringify(httpRsp))
                httpRequest.destroy()
                return
            }
            logd("[download] download success : " + meshJson)
            httpRequest.destroy()
            return meshJson
        } catch (e) {
            loge('[download] upload fail：', JSON.stringify(e))
        }
        return
    }
}
