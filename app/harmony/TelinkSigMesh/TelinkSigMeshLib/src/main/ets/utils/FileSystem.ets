// import fileIO from "@ohos.fileio";
import { fileIo as fs } from '@kit.CoreFileKit'
import fileUri from '@ohos.file.fileuri'
import { common } from '@kit.AbilityKit';

export async function copyToInternal(uri: string) {
    try {
        const context = getContext() as common.UIAbilityContext
        const destDir = context.filesDir
        const fileName = uri.substring(uri.lastIndexOf('/') + 1);
        const destPath = `${destDir}/${fileName}`
        // let file = fs.openSync(uri, fs.OpenMode.READ_ONLY & fs.OpenMode.WRITE_ONLY)
        let file = fs.openSync(uri, fs.OpenMode.READ_ONLY)
        fs.copyFileSync(file.fd, destPath);
        console.log("copy success : " + destPath)
        fs.closeSync(file.fd)
        return destPath
    } catch (e) {
        console.error('copy error :', JSON.stringify(e));
        return undefined
    }
}

export async function readBinaryFile(path: string): Promise<Uint8Array | undefined> {
    try {
        console.log("readBinaryFile : " + path)
        const file = fs.openSync(path, fs.OpenMode.READ_ONLY & fs.OpenMode.WRITE_ONLY)
        const stat = fs.statSync(file.fd);
        const buffer = new ArrayBuffer(stat.size);
        fs.readSync(file.fd, buffer, {
            offset: 0,
            length: stat.size
        });
        console.log("read file complete : " + buffer.byteLength)
        await fs.close(file.fd);
        return new Uint8Array(buffer);
    } catch (err) {
        console.error('read bin error :', JSON.stringify(err));
        return undefined
    }
}


export async function readTextFile(path: string): Promise<string | undefined> {
    try {
        const file = fs.openSync(path, fs.OpenMode.READ_ONLY & fs.OpenMode.WRITE_ONLY)
        const stat = fs.statSync(file.fd);
        let re = fs.readTextSync(file.path, {
            offset: 0,
            length: stat.size,
            encoding: 'utf-8'
        });
        await fs.close(file.fd);
        return re
    } catch (err) {
        console.error('read text error :', JSON.stringify(err));
        return undefined
    }
}

