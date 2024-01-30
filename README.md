* `Palworld-restart.sh`仅适用于在linux系统下重启该脚本所在机器的服务器。
* 该脚本所使用的RCON连接工具来源于https://github.com/Teddyou7/PalworldRcon 作者：泰迪欧_Teddyou https://www.bilibili.com/read/cv29970590/ 出处：bilibili

# 怎么使用`Palworld-restart.sh`

1. 在https://github.com/Teddyou7/PalworldRcon下载RCON工具到服务器并编译，确保能够正常使用。
2. 编辑`restart.config`文件，确保设置正确的PalworldRcon文件路径和PalServer目录路径。按照实际情况设置合适的重启参数。
3. 控制台进入`Palworld-restart.sh`脚本所在目录，使用`./Palworld-restart.sh`命令运行脚本，启动服务器。
4. 使用`crontab -e`添加以下命令，设定脚本定时执行，实现自动重启
```bash
0 * * * * cd 脚本所在绝对路径 && ./Palworld-restart.sh
```
