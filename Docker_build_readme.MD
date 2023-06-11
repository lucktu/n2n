# 使用 `Github Action `
- 使用 `Github Action `  半自动生成  `docker` 镜像到 `Docker Hub` .
- 也可使用 `scripts/build-manual.sh` 案例手动编译推送到私有镜像


## 说明
docker hub 说明页面可以参考: [doc/docker.md](https://github.com/zctmdc/n2n-lucktu/blob/master/doc/docker.md#%E5%BF%AB%E9%80%9F%E5%85%A5%E9%97%A8)

github action 可以参考: [doc/build.md](https://github.com/zctmdc/n2n-lucktu/blob/master/doc/build.md)

如果你想用到自己的项目上，请注意修复依赖：[doc/fixlib.md](https://github.com/zctmdc/n2n-lucktu/blob/master/doc/fixlib.md)

**第一次需要手动生成需要的版本，之后，每次 *提交* 会自动运行的，就不需要手动点了** 

### 要做的
请在 Settings > secrets > Actions 中添加 REGISTRY_USERNAME，REGISTRY_TOKEN

https://github.com/docker/login-action#docker-hub

https://docs.docker.com/docker-hub/access-tokens/

### 初次使用快速上手：

批量生成对应的版本，网页界面有提示的

![image](https://github.com/lucktu/n2n/assets/24244480/1302bcef-e244-437a-9f45-686a244dd636)

- 运行结束，就是右边出现任务，等它从转圈变成绿色的勾
- 第一次如果要生成小版本的话，等几个钟头才能结束
- 所以的话
- 如果不需要全部的小版本，可以不参考黄色截图部分，用红色的，只生成大版本

- 指定版本：`version_b_s_rc`

![image](https://github.com/lucktu/n2n/assets/24244480/e0f11901-7cea-44bc-8f83-c222f6731f7f)

- 上图中，如果不指定版本:

默认使用  倒序 `Linux` 文件夹下面的文件 `x64` 第一个文件 `auto`
比如 `n2n_v4_xxx` `n2n_v3_xxx` 应该会选中 `n2n_v4_xxx` 那个文件版本 
然后识别版本并生成相应的docker镜像 `n2n_v4_xxx` `latest`


## 较上次提交变化
- 移除了不受支持的 `debian8`
- 采用新的修复代码，修复依赖
- 增加了多个参数，便于定制镜像

## 运行结果参考

![image](https://github.com/lucktu/n2n/assets/24244480/d91adea4-a6bb-4204-8d07-454b8c976c08)
![image](https://github.com/lucktu/n2n/assets/24244480/3217678f-62e9-4ecf-8c0a-fe2cfddbb0e4)
