#批量修改服务器密码的脚本

文件列表：
chg_passwd.exp			expect执行脚本
chg_passwd.expbak		expect备份脚本
chg_passwd.sh			主要的执行脚本
create_passwd.sh		生成密码脚本
hosts					修改密码需要读取的文件
newpasswd				新密码文件
oldpasswd				初始化密码文件


#执行逻辑
首先需要把需要修改密码的服务器IP，用户名，默认密码写入hosts文件，
再通过create_passwd.sh批量密码，然后用chg_passwd.sh调用chg_passwd.exp执行修改密码的操作。
1、生成密码
[root@g /opt/shell/chg_passwd]#sh create_passwd.sh 
请输入需要批量修改密码的IP个数:
请输入新密码长度:
2、修改密码
[root@g /opt/shell/chg_passwd]#sh chg_passwd.sh
'''
执行过程
'''
#需求
在日常运维工作中，遇到需要批量更改服务器密码的需求，需要批量操作修改密码，
一般可以通过paramiko模块或者ansible来操作，这里通过linux自带expect来实现，
效率很高，一个进程一分钟可以更改两百台机器的密码。

#原理
批量生成密码用mkpasswd,mkpasswd用于随机生成带特殊字符的9位密码。
生成这么多随机密码的目的是用来（批量）更改服务器的密码的，那么修改服务器密码必然涉及到交互问题，
expect是用来实现自动和交互式任务进行通信而无需人工干预。
安装except：yum install expect，这样同时也会把mkpasswd安装上。
expect执行脚本及注释如下：
#!/usr/bin/expect -f
#主要用来与服务器交互式操作修改密码的文件，也是最主要的文件，
set ipaddr [lindex $argv 0]      #设置第一个参数为ip地址
set username [lindex $argv 1]     #。。。。。。。用户名
set passwd [lindex $argv 2]    #。。。。。。。。旧密码
set new_pwd [lindex $argv 3]    # 。。。。。。。。 新密码
log_file /tmp/expect.log   #设置日志文件
set timeout 20   #设置超时时间
spawn ssh $username@$ipaddr    #这条命令是ssh远程登录到待修改服务器的机器上
#这块的大括号的形式其实和下面修改密码的过程类似，只是少敲了expect命令
expect {
"yes/no" { send "yes\r";exp_continue }
"password:" { send "$passwd\r" }
}
#expect "]$"
#send "sudo su - \r"
expect "root"   #expect用来读取登录上去的服务器的提示符，通过提示符来判断待输入的信息。
send "passwd root\r"
expect "New password:"
send "$new_pwd\r"
expect "Retype new password:"
send "$new_pwd\r"
expect "root"
send "exit\r"   #退出服务器登录，也可以用logout
#expect "]$"
#send "exit\r"
expect eof  #关闭expect通信
