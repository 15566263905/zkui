#!/bin/bash

AppName=zkui-2.0.jar
APP_HOME=/opt/zookeeper/zkui/$AppName
APP_OPTS=""
APP_LOG="/opt/zookeeper/zkui/logs/zkui.log"
APP_CONFIG="/opt/zookeeper/zkui/config/config.cfg"

#JVM参数
# -Xms:指定jvm堆的初始大小，默认为物理内存的1/64；可以指定单位，比如k、m，若不指定，则默认为字节。
# -Xmx:指定jvm堆的最大值，默认为物理内存的1/4，单位与-Xms一致；在开发过程中，通常会将 -Xms 与 -Xmx两个参数的配置相同的值，其目的是为了能够在java垃圾回收机制清理完堆区后不需要重新分隔计算堆区的大小而浪费资源。
# -XX:NewSize: 设置新生代对象能占用内存够的初始大小
# -XX:MaxNewSize: 设置新生代能占用内存的最大值；这个值应该小于 -Xmx的值
# -XX:SurvivorRatio: 新生代中survivor区和eden区的比例
# -XX:PermSize: 表示非堆区初始内存分配大小
# -XX:MaxPermSize:非堆区分配的内存的最大上限
# -XX:NewRatio: 新生代内存容量与老生代内存容量的比例
# -XX:+HeapDumpOnOutOfMemoryError:	当首次遭遇OOM(OutOfMemoryError)时导出此时堆中相关信息
# -XX:+PrintGCDateStamps: 输出GC的时间戳（以日期的形式，如 2013-05-04T21:53:59.234+0800）
# -XX:+PrintGCDetails: 输出详细GC日志
# -XX:+UseParallelGC: 启用并行GC
# -XX:+UseParallelOldGC: 对Full GC启用并行，当-XX:-UseParallelGC启用时该项自动启用
# -Xss: 设置每个线程的堆栈大小
# JVM_OPTS="$APP_HOME -Xms512M -Xmx512M -XX:PermSize=256M -XX:MaxPermSize=512M -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"
JVM_OPTS="$APP_HOME $APP_CONFIG"

if [ "$1" = "" ];
then
    echo -e "\033[0;31m 未输入操作名 \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
    exit 1
fi

if [ "$AppName" = "" ];
then
    echo -e "\033[0;31m 未输入应用名 \033[0m"
    exit 1
fi

function start()
{
  OLDPID=$(ps -ef |grep java|grep $AppName|grep -v grep|awk '{print $2}')

	if [ x"$OLDPID" != x"" ]; then
	    echo "$AppName is running..."
        exit
	else
	  # echo "java $APP_OPTS -jar $JVM_OPTS > /dev/null 2>&1 &"
	  echo "java -jar $JVM_OPTS > $APP_LOG 2>&1 &"
	  # >或>> 区别是：前者会先清空文件，然后再写入内容，后者会将重定向的内容追加到现有文件的尾部
		nohup java -jar $JVM_OPTS > $APP_LOG 2>&1 &
		echo "Start $AppName ..."
	fi

    PID=$(ps -ef |grep java|grep $AppName|grep -v grep|awk '{print $2}')
    if [ x"$PID" = x"" ]; then
	    echo "$AppName start fail"
        exit
    else
        echo "$AppName start success"
    fi
}

function stop()
{
  echo "Stop $AppName"

	PID=""
	query(){
		PID=$(ps -ef |grep java|grep $AppName|grep -v grep|awk '{print $2}')
	}

	query
	if [ x"$PID" != x"" ]; then
		kill -TERM $PID
		echo "$AppName (pid:$PID) exiting..."
		while [ x"$PID" != x"" ]
		do
			sleep 1
			query
		done
		echo "$AppName exited."
	else
		echo "$AppName already stopped."
	fi
}

function restart()
{
    stop
    sleep 2
    start
}

function status()
{
    PID=$(ps -ef |grep java|grep $AppName|grep -v grep|wc -l)
    if [ $PID != 0 ];then
        echo "$AppName is running..."
    else
        echo "$AppName is not running..."
    fi
}

case $1 in
    start)
    start;;
    stop)
    stop;;
    restart)
    restart;;
    status)
    status;;
    *)

esac
