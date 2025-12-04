import { aesEcb, xor16 } from "./Encipher";



export function ccmAesEncrypt(text: Uint8Array, key: Uint8Array, nonce: Uint8Array,
    aad: Uint8Array, tlen: number) {
    let nonceLen = nonce.length
    let textLen = text.length
    let aadLen = aad.length
    let bBuf = new Uint8Array(16)
    let q = textLen;
    let qLen = 15 - nonceLen;
    let y = new Uint8Array(16)
    bBuf[0] |= (aadLen > 0) ? 0x40 : 0x00;
    bBuf[0] |= (((tlen - 2) >> 2) << 4) & 0x30;
    bBuf[0] |= ((((tlen - 2) >> 1) & 0x01) << 3) & 0x08;
    bBuf[0] |= (qLen - 1) & 0x07;
    for (let i = 0; i < nonceLen; i++) {
        bBuf[i+1] = nonce[i];
    }
    for (let m = 0; m < qLen; m++, q >>= 8) {
        bBuf[15 - m] = q & 0xFF;
    }
    y = aesEcb(bBuf, key);
    let curBInd = 0;
    if (aadLen > 0) {
        if (aadLen < 65280) {
            bBuf[curBInd++] = (aadLen >> 8) & 0xff;
            bBuf[curBInd++] = aadLen & 0xff;
        } else if (aadLen >= 65280 && aadLen < 4294967296) {
            bBuf[curBInd++] = 0xff;
            bBuf[curBInd++] = 0xfe;
            for (let i = 24; i >= 0; i -= 8) {
                bBuf[curBInd++] = (aadLen >> i) & 0xff;
            }
        } else {
            bBuf[curBInd++] = 0xff;
            bBuf[curBInd++] = 0xff;
            for (let i = 56; i >= 0; i -= 8) {
                bBuf[curBInd++] = (aadLen >> i) & 0xff;
            }
        }
        for (let i = 0; i < aadLen; i++) {
            bBuf[curBInd++] = aad[i];
            if (curBInd >= 16) {

                bBuf = xor16(bBuf, y)
                y = aesEcb(bBuf, key);
                curBInd = 0;
            }
        }
        if (curBInd > 0 && curBInd < 16) {
            while (curBInd < 16) {
                bBuf[curBInd++] = 0x00;
            }
            bBuf = xor16(bBuf, y)
            y = aesEcb(bBuf, key);
            curBInd = 0;
        }
    }

    for (let i = 0; i < textLen; i++) {
        bBuf[curBInd++] = text[i];
        if (curBInd >= 16) {
            bBuf = xor16(bBuf, y)
            y = aesEcb(bBuf, key);
            curBInd = 0;
        }
    }
    if (curBInd > 0 && curBInd < 16) {
        while (curBInd < 16) {
            bBuf[curBInd++] = 0x00;
        }
        bBuf = xor16(bBuf, y)
        y = aesEcb(bBuf, key);
    }

    let m = Math.floor(textLen / 16) + (textLen % 16 > 0 ? 1 : 0);
    let ctr: Array<Uint8Array> = new Array(m + 1)
    for (let i = 0; i < m + 1; i++) {
        ctr[i] = new Uint8Array(16)
        for (let j = 0; j < 16; j++) {
            ctr[i][j] = 0;
        }
    }
    for (let i = 0; i < m + 1; i++) {
        ctr[i][0] = (qLen - 1) & 0x07;
        for (let ni = 0; ni < nonceLen; ni++) {
            ctr[i][ni+1] = nonce[ni];
        }
        let ci = 15;
        if (i > 0) {
            ctr[i][15] = ctr[i-1][15] + 1;
            while (ctr[i][ci] == 0 && ci >= 16 - qLen) {
                ctr[i][ci-1]++;
                ci--;
            }
        }
    }
    let s: Array<Uint8Array> = new Array(m + 1)
    for (let i = 0; i < m + 1; i++) {
        s[i] = new Uint8Array(16)
        for (let j = 0; j < 16; j++) {
            s[i][j] = 0;
        }
    }
    for (let i = 0; i < m + 1; ++i) {
        s[i] = aesEcb(ctr[i], key);
    }
    let cipher = new Uint8Array(textLen + tlen)
    for (let i = 0; i < textLen; ++i) {
        cipher[i] = text[i] ^ s[(Math.floor(i / 16))+1][i%16];
    }
    for (let i = (textLen); i < (textLen + tlen); ++i) {
        cipher[i] = y[i-(textLen)] ^ s[0][i-(textLen)];
    }
    return cipher
}

export function ccmAesDecrypt(cipher: Uint8Array, key: Uint8Array, nonce: Uint8Array, a: Uint8Array, tlen: number) {
    let nlen = nonce.length
    let alen = a.length
    let clen = cipher.length
    let qlen = 15 - nlen;
    let m = Math.floor((clen - tlen) / 16) + ((clen - tlen) % 16 > 0 ? 1 : 0)
    let ctr: Array<Uint8Array> = new Array(m + 1)
    for (let i = 0; i < m + 1; i++) {
        ctr[i] = new Uint8Array(16)
        for (let j = 0; j < 16; j++) {
            ctr[i][j] = 0;
        }
    }
    for (let i = 0; i < m + 1; i++) {
        ctr[i][0] = (qlen - 1) & 0x07;
        for (let ni = 0; ni < nlen; ni++) {
            ctr[i][ni+1] = nonce[ni];
        }
        let ci = 15;
        if (i > 0) {
            ctr[i][15] = ctr[i-1][15] + 1;
            while (ctr[i][ci] == 0 && ci >= 16 - qlen) {
                ctr[i][ci-1]++;
                ci--;
            }
        }
    }
    let s: Array<Uint8Array> = new Array(m + 1)
    for (let i = 0; i < m + 1; i++) {
        s[i] = new Uint8Array(16)
        for (let j = 0; j < 16; j++) {
            s[i][j] = 0;
        }
    }
    for (let i = 0; i < m + 1; ++i) {
        s[i] = aesEcb(ctr[i], key)
    }
    let plaintext = new Uint8Array(clen - tlen)
    for (let i = 0; i < clen - tlen; i++) {
        plaintext[i] = cipher[i] ^ s[Math.floor(i / 16)+1][i%16];
    }
    let t = new Uint8Array(tlen)
    for (let i = clen - tlen; i < clen; i++) {
        t[i-(clen - tlen)] = cipher[i] ^ s[0][(i - (clen - tlen))];
    }

    let bBuf = new Uint8Array(16);
    let q = clen - tlen;
    let y = new Uint8Array(16)
    bBuf[0] |= (alen > 0) ? 0x40 : 0x00;
    bBuf[0] |= (((tlen - 2) >> 2) << 4) & 0x30;
    bBuf[0] |= ((((tlen - 2) >> 1) & 0x01) << 3) & 0x08;
    bBuf[0] |= (qlen - 1) & 0x07;
    for (let i = 0; i < nlen; i++) {
        bBuf[i+1] = nonce[i];
    }
    for (let m = 0; m < qlen; m++, q >>= 8) {
        bBuf[15 - m] = q & 0xFF;
    }
    y = aesEcb(bBuf, key)
    let curBInd = 0;
    if (alen > 0) {
        if (alen < 65280) {
            bBuf[curBInd++] = (alen >> 8) & 0xff;
            bBuf[curBInd++] = alen & 0xff;
        } else if (alen >= 65280 && alen < 4294967296) {
            bBuf[curBInd++] = 0xff;
            bBuf[curBInd++] = 0xfe;
            for (let i = 24; i >= 0; i -= 8) {
                bBuf[curBInd++] = (alen >> i) & 0xff;
            }
        } else {
            bBuf[curBInd++] = 0xff;
            bBuf[curBInd++] = 0xff;
            for (let i = 56; i >= 0; i -= 8) {
                bBuf[curBInd++] = (alen >> i) & 0xff;
            }
        }
        for (let i = 0; i < alen; i++) {
            bBuf[curBInd++] = a[i];
            if (curBInd >= 16) {
                bBuf = xor16(bBuf, y)
                y = aesEcb(bBuf, key)
                curBInd = 0;
            }
        }
        if (curBInd > 0 && curBInd < 16) {
            while (curBInd < 16) {
                bBuf[curBInd++] = 0x00;
            }
            bBuf = xor16(bBuf, y)
            y = aesEcb(bBuf, key)
            curBInd = 0;
        }
    }

    for (let i = 0; i < clen - tlen; i++) {
        bBuf[curBInd++] = plaintext[i];
        if (curBInd >= 16) {
            bBuf = xor16(bBuf, y)
            y = aesEcb(bBuf, key)
            curBInd = 0;
        }
    }
    if (curBInd > 0 && curBInd < 16) {
        while (curBInd < 16) {
            bBuf[curBInd++] = 0x00;
        }
        bBuf = xor16(bBuf, y)
        y = aesEcb(bBuf, key)
    }
    for (let i = 0; i < tlen; i++) {
        if (t[i] != y[i]) {
            return undefined;
        }
    }

    return plaintext
}

