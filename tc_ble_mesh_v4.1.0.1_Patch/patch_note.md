## V4.1.0.1_Patch_0006

### Version
* SDK version: tc_ble_mesh_V4.1.0.1_Patch_0006
* Chips Version
  - B85: TLSR825X
  - B87: TLSR827X
* Hardware Version
  - B85: C1T139A30_V1_2, C1T139A3_V2_0
  - B87: C1T197A30_V1_1, C1T201A3_V1_0
* Base SDK Version
  - telink_b85m_ble_single_connection_sdk_v3.4.1
* Toolchain Version
  - TC32 ELF GCC4.3 ( IDE: [Telink IoT Studio](https://www.telink-semi.com/development-tools ))

### Bug Fixes
* PLL
  - for TLSR8278(B87)
    - The criteria for determining the stability of the PLL have become more stringent.
    - Detailed Description: Previously, the criteria for determining the stability of the PLL was considered passed if detected once.
    - After Fix: The criteria for determining the stability of the PLL is only considered passed if it is detected three times consecutively (to improve reliability).
    - Update Recommendation: Recommended update.
* mesh_switch
  - Fixed incorrect sleep duration for mesh_switch.
  - Detailed Description: When the switch IV update timer exceeded 32 hours (SWITCH_LONG_SLEEP_TIME_S) but was less than 96 hours (SWITCH_IV_SEARCHING_INTERVAL_S), the sleep interval was only 1 second.
  - After Fix: When the switch IV update timer exceeds 32 hours (SWITCH_LONG_SLEEP_TIME_S) but is less than 96 hours (SWITCH_IV_SEARCHING_INTERVAL_S), the sleep interval is now 32 hours.
  - Update Recommendation: If the application uses switch_check_and_enter_sleep() for sleep, must update.
* PM
  - Fixed the issue where start_reboot() took 10 seconds to reboot.
    - Detailed Description：After updating to Patch_0002, calling start_reboot() took 10 seconds to reboot successfully.
    - After Fix： The sleep duration in start_reboot() has been changed from 1ms to 4ms (minimum 2ms). After calling start_reboot(), the system now reboots successfully within 10ms.
    - Update Recommendation: If Patch_0002 is used, must update.

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* to avoid compilation errors or loss of functionality, please update all files when upgrading the SDK.


### 版本
* SDK 版本: tc_ble_mesh_V4.1.0.1_Patch_0006
* Chips 版本
  - B85: TLSR825X
  - B87: TLSR827X
* Hardware 版本
  - B85: C1T139A30_V1_2, C1T139A3_V2_0
  - B87: C1T197A30_V1_1, C1T201A3_V1_0
* Base SDK 版本
  - telink_b85m_ble_single_connection_sdk_v3.4.1
* Toolchain 版本
  - TC32 ELF GCC4.3 ( IDE: [Telink IoT Studio](https://www.telink-semi.com/development-tools ))

### Bug Fixes
* PLL
  - for TLSR8278(B87)
    - 将PLL稳定性判断的标准变得更严格。
    - 详细描述：之前，判断PLL稳定性的标准是只要检测到一次就认为通过了。
    - 修复效果：判断PLL稳定性的标准仅在连续检测到三次时才认为通过了（提高可靠性）。
    - 更新建议：建议更新。
* mesh_switch
  - 修复 mesh_switch休眠时间不对问题
    - 详细描述：switch iv更新计时超过在32小时(SWITCH_LONG_SLEEP_TIME_S)，但小于96小时（SWITCH_IV_SEARCHING_INTERVLAL_S）时，休眠间隔只有1秒钟。
    - 修复效果：switch iv更新计时超过在32小时(SWITCH_LONG_SLEEP_TIME_S)，但小于96小时（SWITCH_IV_SEARCHING_INTERVLAL_S）时，休眠间隔32小时。
    - 更新建议：如果使用mesh_switch，需要更新。
* PM
  - 修复start_reboot()需要花费10秒才重启成功的问题。
    - 详细描述：更新Patch_0002后，调用start_reboot()需要10秒钟才重启成功。
    - 修复效果：start_reboot()休眠时间由1ms改为4ms（最小2ms），调用start_reboot()后10ms重启成功。
    - 更新建议：如果有使用Patch_0002，需要更新。

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* 为避免编译错误以及功能丢失，升级SDK时，请确认更新全部SDK文件。



## V4.1.0.1_Patch_0005

### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh ble library commit log: SHA-1: 8de37a59a75f858e9bb6084d26c8ff14c184181c

### Bug Fixes

* private online status
  - Fixed the issue where the online status callback function light_node_status_change_cb() did not report offline status.
    - Detailed Description：When ONLINE_STATUS_EN was enabled and register_mesh_node_status_callback(light_node_status_change_cb) was called to register the callback, the light_node_status_change_cb() function did not report offline status.
    - After fix：The light_node_status_change_cb() function now correctly reports offline status.
    - Update Recommendation: If ONLINE_STATUS_EN was enabled and register_mesh_node_status_callback(light_node_status_change_cb) was called, must update.

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* to avoid compilation errors or loss of functionality, please update all files when upgrading the SDK.


### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh library commit log: SHA-1: 8de37a59a75f858e9bb6084d26c8ff14c184181c

### Bug Fixes

* private online status
  - 修复online status状态回调处理函数light_node_status_change_cb()未上报离线状态问题。
    - 详细描述：代码中打开ONLINE_STATUS_EN，调用register_mesh_node_status_callback(light_node_status_change_cb)注册后，light_node_status_change_cb中未上报离线状态。
    - 修复效果：light_node_status_change_cb中正常上报离线状态。
    - 更新建议：如果有使用私有的online status功能，且调用register_mesh_node_status_callback(light_node_status_change_cb)注册回调函数，需要更新。

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* 为避免编译错误以及功能丢失，升级SDK时，请确认更新全部SDK文件。



## V4.1.0.1_Patch_0004

### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh ble library commit log: SHA-1: 5195c9404cd19409928c800475824570f79556a8

### Bug Fixes

* spirit_lpn
  - Fixed the issue where spirit_lpn failed to enter scan mode after waking up from suspend.
    - Detailed Description：The default sleep interval for Spirit LPN is 360ms, and scan is enabled in user_init_deepRetn(). If the sleep time is less than 50 ms, device will enter suspend mode.
                            Scan was not re-enabled after suspend up, which may cause packet reception loss.
    - After fix: Scan is enabled according to the scanning cycle after waking up from suspend.
    - Update Recommendation: If use spirit_lpn, must update.

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* to avoid compilation errors or loss of functionality, please update all files when upgrading the SDK.


### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh library commit log: SHA-1: 5195c9404cd19409928c800475824570f79556a8

### Bug Fixes

* spirit_lpn
  - 修复spirit_lpn从suspend唤醒后未进入扫描问题。
    - 详细描述：默认spirit_lpn休眠间隔360ms，扫描是在user_init_deepRetn()中打开的。如果spirit_lpn休眠间隔小于50ms，会进入suspend休眠，唤醒后未重新打开扫描，可能导致接收丢包。
    - 修复效果：suspend唤醒后也会按照扫描周期打开扫描。
    - 更新建议: 如果使用spirit_lpn，需要更新。

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* 为避免编译错误以及功能丢失，升级SDK时，请确认更新全部SDK文件。


## V4.1.0.1_Patch_0003

### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh ble library commit log: SHA-1: 5195c9404cd19409928c800475824570f79556a8

### Bug Fixes

* N/A

### Features

* add SAVE_SNO_CACHE_EN option to save replay protection list in flash, disable by default, set to 1 to enable.

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* to avoid compilation errors or loss of functionality, please update all files when upgrading the SDK.


### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh library commit log: SHA-1: 5195c9404cd19409928c800475824570f79556a8

### Bug Fixes

* N/A

### Features

* 添加SAVE_SNO_CACHE_EN选项，保存收到的mesh消息的sequence number到flash。即replay protection list，默认关闭。

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* 为避免编译错误以及功能丢失，升级SDK时，请确认更新全部SDK文件。


## V4.1.0.1_Patch_0002

### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh ble library commit log: SHA-1: 5195c9404cd19409928c800475824570f79556a8

### Bug Fixes

* PM
  - Resolve the low-probability inaccuracy in sleep duration caused by the delayed disabling of global interrupt during the sleep entry process.
    - Detailed Description：If an interrupt happened to trigger and the interrupt handling took a long time when entering sleep mode. It may cause an incorrect sleep duration.
    - After fix：Interrupts are now disabled immediately when entering sleep mode.
    - Update Recommendation: If power management was used, must update.

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* to avoid compilation errors or loss of functionality, please update all files when upgrading the SDK.


### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh library commit log: SHA-1: 5195c9404cd19409928c800475824570f79556a8

### Bug Fixes

* PM
  - 修复进入休眠时由于未及时关中断导致的低概率休眠时间不对问题。
    - 详细描述：进入休眠时，如果刚好触发中断且中断处理时间长，会导致休眠时间不对。
    - 修复效果：进入休眠时，立刻关闭中断。
    - 更新建议: 如果有使用低功耗，需要更新。

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* 为避免编译错误以及功能丢失，升级SDK时，请确认更新全部SDK文件。


## V4.1.0.1_Patch_0001

### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh ble library commit log: SHA-1: a73b6395993989b369fe62d2be0d5c0be8496c05

### Bug Fixes

* fix the issue of cpu_long_sleep_wakeup() when using external 32k rc.

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* to avoid compilation errors or loss of functionality, please update all files when upgrading the SDK.


### Dependency Updates

* telink_b85m_ble_single_connection_sdk_v3.4.1
* mesh library commit log: SHA-1: a73b6395993989b369fe62d2be0d5c0be8496c05

### Bug Fixes

* 修复使用外部32k rc晶振时cpu_long_sleep_wakeup()休眠异常问题。

### Features

* N/A

### Performance Improvements

* N/A

### BREAKING CHANGES

* N/A

### Notes

* 为避免编译错误以及功能丢失，升级SDK时，请确认更新全部SDK文件。