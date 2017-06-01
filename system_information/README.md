

#shell

shell scripts 一个用来统计服务器信息的脚本，主要针对物理服务器，虚拟机查询结果会有很多空值

示例：
<pre>
[root@gome /opt/shell/system_information]#sh basic_system_information.sh 
please input a number ：
		basic information   => 1
		memory information  => 2
		CPU information     => 3
		PCIE information    => 4
		raid information    => 5
		ALL information     => Enter
		===>>>
</pre>		
用途：
可以分别统计出系统基本信息、内存信息、CPU信息、PCIE信息、raid信息，全部信息。
把统计出来的信息导入CMDB系统，除了进行服务器数据的采集外，还能够保证CMDB信息的准确性，
在机器数量比较少（<1000台）的时候，可以通过该脚本结合zabbix检测每天故障服务器。

需要手动下载的工具： HP的服务器有专用的raid工具：hpacucli-9.0-24.0.noarch.rpm
非HP服务器统一使用MegaCli工具:MegaCli-8.00.48-1.i386.rpm

参考： http://www.datadisk.co.uk/html_docs/redhat/hpacucli.htm
http://www.ttlsa.com/tools/megacli-tool-query-raid-status/
