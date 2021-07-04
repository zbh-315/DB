@[TOC]( )
# 题目背景
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210524181440531.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ1NTQzNTk0,size_16,color_FFFFFF,t_70)


# 作答
## 思路解释
①每次随机选取一个进程，生成一个request
②对这个request，进行判断，看是否资源足够，看是否会死锁。
③如果资源足够了，释放资源。
④如果所有进程都结束了，退出循环，结束。
## 关键结构与函数
### struct Reource
```cpp
struct Reource {
	//资源ABC...，n是资源的个数
	int n = SIZE;
	int num[SIZE];
};
```
### struct Situation

```cpp
struct Situation {
	int n = N;
	struct Reource Maxn;//需要的最大资源
	struct Reource Allocation;//当前已经调用的资源
	struct Reource Need;//还需要的资源
	int flag=0;
	void update() {
		//Need=Maxn-Allocation
		for (int j = 0; j < Need.n; j++) {
			Need.num[j] = Maxn.num[j] - Allocation.num[j];
		}
	}
} ;
```

### void show(
展示进程的资源，和可用资源
### void ini(
初始化
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210524182904434.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ1NTQzNTk0,size_16,color_FFFFFF,t_70)

```cpp
int in[6][6] = {
	{7, 5, 3, 0, 1, 0},
	{3, 2, 2, 2, 0, 0},
	{9, 0, 2, 3, 0, 2},
	{2, 2, 2, 2, 1, 1},
	{4, 3, 3, 0, 0, 2},
```

### void request(
生成一个请求，对P[index]进行请求
### int respond(
对请求request进行分析，并返回
-1：资源不够
0：	资源够，但会死锁
1：	资源够，但不足以完成当前进程
2：	资源够，且足以完成

### void update(
调用request()，对respond()不同返回值进行不同操作
### int NoEnd(
判断是否所有进程都结束了，结束返回0，没结束返回1；
### main()

```cpp
int main(int argc, char **argv) {
	ini(P,Available);
	show(P,Available);
	while(NoEnd(P)) {
		update(P,Available);
		show(P,Available);
		//sleep();
	}
	return 0;
}
```
## 关键运行结果
### ① 初始化后
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210524184439194.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ1NTQzNTk0,size_16,color_FFFFFF,t_70)

### ②P1 Request->   1  2  2
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210524184515719.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ1NTQzNTk0,size_16,color_FFFFFF,t_70)


### ③P0 Request->   2  4  3
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210524184637116.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ1NTQzNTk0,size_16,color_FFFFFF,t_70)


### ④运行到最后

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210524184728489.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQ1NTQzNTk0,size_16,color_FFFFFF,t_70)

## 分析与尝试
### ①分析
对于请求Request，我采用的方法是

```cpp
//伪代码
Request=min(P[index].Need,Available)
```
这样，资源可以逐渐增加，不会存在死锁
我想到的缺点是：这样对那些需要资源比较多的进程不太友好。
### ②尝试
为了解决①的缺点，我尝试了生成随机请求
~~这是一次失败的尝试，但是让我加深了理解，更加理解了资源的request 和respond~~ 
```cpp
tt=min(P[index].Need+1,Available+1);
if(tt!=0)Request=rand()%tt
```
然后就死锁了。。。。。。。。。。。
操作和理由如下
我对于这个请求能不能够响应的判断操作是：如果request响应后，if有其他进程t可以接着响应，那么就不会死锁。
但是这并不正确，因为t释放的资源可能不足以响应所有进程。
打个比方：
| | Max | Allocation |Need
|-- |--|--|--|
| P0| 7 |0  |7|
| P1| 6 | 0 |6|
| P2| 2 | 1 |1|

|Available | 
|-- |
|5|

正确顺序:
P2->request(1)，P1->request(6)，P0->request(7)
按照随机生成：
P0->request(3)，如果响应，剩下的资源还可以响应P2继续释放资源，看似现在不会死锁，其实响应P2后会死锁：
P0->request(3)，后：
| | Max | Allocation |Need
|-- |--|--|--|
| P0| 7 |3  |4|
| P1| 6 | 0 |6|
| P2| 2 | 1 |1|

|Available | 
|-- |
|2|
之后资源只够响应进程P2->request(1)

| | Max | Allocation |Need
|-- |--|--|--|
| P0| 7 |3  |4|
| P1| 6 | 0 |6|
| P2| 0 | 0 |0|

|Available | 
|-- |
|3|
然后就死锁了。
可见，如果一个进程发出一小部分的资源请求，即使响应之后能有其他进程响应，释放的资源如果不够的话，也会存在死锁。
# 附录：代码
代码存放在两个文件：main.cpp、function.h

```cpp
//main.cpp 
#include <iostream>
#include <bits/stdc++.h>
#include "function.h"
using namespace std;
#define N 5
#define SIZE 3
struct Reource  Available;
struct Situation P[N];
int main(int argc, char **argv) {
	ini(P,Available);
	show(P,Available);
	while(NoEnd(P)) {
		update(P,Available);
		show(P,Available);
		//sleep();
	}
	return 0;
}
```

```cpp
//function.h
#define N 5
#define SIZE 3
#include<stdio.h>
#include<vector>
#include <stdlib.h>
using namespace std;

struct Reource {
	//资源ABC...，n是资源的个数
	int n = SIZE;
	int num[SIZE];
};
struct Situation {
	int n = N;
	struct Reource Maxn;//需要的最大资源
	struct Reource Allocation;//当前已经调用的资源
	struct Reource Need;//还需要的资源
	int flag=0;
	void update() {
		//Need=Maxn-Allocation
		for (int j = 0; j < Need.n; j++) {
			Need.num[j] = Maxn.num[j] - Allocation.num[j];
		}
	}
} ;
void show(struct Situation P[],struct Reource Available) {
	//展示P[]的资源，和可用资源
	printf("\n");
	printf("    |      MAX      |   Allocation  |      Need     |   Available   \n");
	printf("    |  A    B    C  |  A    B    C  |  A    B    C  |  A    B    C  \n");
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < 68; j++)
			if (j % 16 == 4)
				printf("+");
			else if(i==0||j<=52)
				printf("-");
		printf("\n");
		printf(" P%d ", i);
		for (int j = 0; j < 12; j++) {
			if (j % SIZE == 0)
				printf("|");
			if (j < SIZE)
				printf("%3d  ", P[i].Maxn.num[j]);
			else if (j < SIZE * 2)
				printf("%3d  ", P[i].Allocation.num[j % SIZE]);
			else if (j < SIZE * 3)
				printf("%3d  ", P[i].Need.num[j % SIZE]);
			else {
				if (i == 0)
					printf("%3d  ", Available.num[j % SIZE]);
			}
		}
		printf("\n");
	}
	printf("\n");
}
void ini(struct Situation P[],struct Reource &Available) {
	//初始化
	int in[6][6] = {
		{7, 5, 3, 0, 1, 0},
		{3, 2, 2, 2, 0, 0},
		{9, 0, 2, 3, 0, 2},
		{2, 2, 2, 2, 1, 1},
		{4, 3, 3, 0, 0, 2},
	};
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < SIZE * 2; j++) {
			if (j < SIZE)
				P[i].Maxn.num[j] = in[i][j];
			else
				P[i].Allocation.num[j % SIZE] = in[i][j];
		}
		P[i].flag = 0;
		P[i].update();
	}
	Available.num[0] = 2;
	Available.num[1] = 3;
	Available.num[2] = 2;
}
void request(struct Situation P[],int &index,struct Reource &Available,struct Reource &t) {
	//生成一个请求到t，对P[index]进行请求
	int i;
	vector<int>v;
	for(i=0; i<N; i++)
		if(P[i].flag==0)
			v.push_back(i);
	index=v[rand()%v.size()];
	for(i=0; i<SIZE; i++) {
//		int tt=min(P[index].Need.num[i]+1,Available.num[i]+1);
//		if(tt==0)t.num[i]=0;
//		else t.num[i]=rand()%tt;
		t.num[i]=min(P[index].Need.num[i],Available.num[i]);
	}
}
int respond(struct Situation P[],int &index,struct Reource &Available,struct Reource &t) {
	/*
	对请求request进行分析，并返回
	-1：资源不够
	0：	资源够，但会死锁
	1：	资源够，但不足以完成当前进程
	2：	资源够，且足以完成
	*/
	int flag=1,i,j;
	for(i=0; i<SIZE; i++)
		if(t.num[i]>Available.num[i])flag=0;
	if(flag==1) {
		int shifang=1,sisuo;
		for(i=0; i<SIZE; i++) {
			if(P[index].Allocation.num[i]+t.num[i]!=P[index].Maxn.num[i])shifang=0;
		}
		if(shifang==1)return 2;
		else {
			for(i=0; i<N; i++) {
				if(P[i].flag)continue;
				sisuo=0;
				for(j=0; j<SIZE; j++)
					if(Available.num[j]-t.num[j]<(i!=index?P[i].Need.num[j]:(P[i].Need.num[j]-t.num[j])))
						sisuo=1;
				if(sisuo==0) {
					return 1;
				}
			}
			return 0;
		}
	} else
		return -1;
}
void sleep() {
	for(int i=0; i<25000000; i++);
}
void update(struct Situation P[],struct Reource &Available) {
	//调用request，对respond不同返回值进行不同操作
	int index,i,cnt=0;
	struct Reource t;
	do {
		request(P,index,Available,t);
		for(i=0; i<SIZE; i++)cnt+=t.num[i];
	} while(cnt==0);
	printf("P%d Request-> ",index);
	for(i=0; i<SIZE; i++)
	printf("%3d",t.num[i]);
	printf("\n");
	int ret=respond(P,index,Available,t);
	if(ret==2) {
		printf("Enough &&Free up the resources->Success \n");
		P[index].flag=1;
		for(i=0; i<SIZE; i++) {
			Available.num[i]+=P[index].Allocation.num[i];
			P[index].Maxn.num[i]=P[index].Allocation.num[i]=P[index].Need.num[i]=0;
		}
	} else if(ret==1) {
		printf("Resources are enough->Success\n");
		for(i=0; i<SIZE; i++) {
			P[index].Allocation.num[i]+=t.num[i];
			Available.num[i]-=t.num[i];
		}
		P[index].update();
	} else if(ret==0) {
		printf("There is deadlock->Defeat\n");
	} else {
		printf("Resources aren't enough->Defeat\n");
	}
}
int NoEnd(struct Situation P[]) {
	//判断是否所有进程都结束了，结束返回0，没结束返回1；
	for(int i=0; i<N; i++)
		if(P[i].flag==0)
			return 1;
	return 0;
}
```

