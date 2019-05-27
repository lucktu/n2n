
已经在openwrt-18.06.2-x86-64验证通过，理论都适用该版本前后的openwrt_x64版镜像。


--n2n复制来源openwrt_x64的leno版
  20190213-0032-openwrt-x64-R9.1.1-squashfs.img


--缺少libcrypto.so.1.0.0库
  复制到openwrt-18.06.2-x86-64-combined-ext4.img运行edge命令提示缺少libcrypto.so.1.0.0库，复制leno版库后正常。




--缺tun设备
  运行edge命令提示ERROR: ioctl() [No such file or directory][2]。

方法
opkg update后
opkg list |grep kmod |grep tun确定tun名称
opkg install kmod-tun
insmod /lib/modules/4.14.95/tun.ko

----- by QQ群友 风火轮 78599998*
