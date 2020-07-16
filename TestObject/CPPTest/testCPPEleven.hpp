//
//  testCPPEleven.hpp
//  TestObject
//
//  Created by maxcwfeng on 2020/7/16.
//  Copyright © 2020 冯驰伟. All rights reserved.
//

#ifndef testCPPEleven_hpp
#define testCPPEleven_hpp

#include <stdio.h>
#include "testOnlyHpp.hpp"

//测试返回类型用decltype表示可以节省代码，看下面就少了一个类型R------
template <typename R,typename T, typename U>
R add(T t,U u)
{
    return t+u;
}

template <typename T, typename U>
auto add(T t,U u) ->decltype(t+u)
{
    return t+u;
}
//---------------------------------------------------------

//返回值类型不明确要提前定义
int testFunctionReturnType(int one, float two);
auto testFunctionReturnTypeEx(int one, float two);
auto testFunctionReturnTypeExExEx(int one, float two)->int;
auto testFunctionReturnTypeExEx(int one, float two){
    return one + two;
}
//---------------------------------------------------------

void mainTest(){
    //测试hpp不需要实现文件，头文件声明加定义；-------
    WWKLocalizedResource::ANNOUNCEMENT::TEXT::testInt = 2;
    int testValue = WWKLocalizedResource::ANNOUNCEMENT::TEXT::testInt + WWKLocalizedResource::ANNOUNCEMENT::TEXT::testIntEx;
    testValue = 0;
    //------------------------
    
    //测试decltype返回类型，decay退化类型(不能退化指针，百度下有其他方法)，is_same判断是不是一样的类型-----
    int tempData = 0;
    int& testPointer = tempData;
    bool value = std::is_same<std::decay<decltype(testPointer)>::type, int>::value; //return true
    //bool value = std::is_same<decltype(testPointer), int>::value; //return false
    value = false;
    //------------------------
    
    //测试lambda-------
    int lambdaExternalEData = 3;
    auto tempLambda = [&](int one, int two){
        lambdaExternalEData = lambdaExternalEData + one + two;
        return lambdaExternalEData + 4;
    };
    auto retrunValue = tempLambda(1, 2);
    retrunValue = 0;
    //------------------------
    
    //测试后定义函数，前置声明--------------
    retrunValue = testFunctionReturnType(1, 2);
    //编译不过，返回值类型不明确的函数不能前置声明testFunctionReturnTypeEx(1, 2);
    //编译的过，因为是前置定义
    retrunValue = testFunctionReturnTypeExEx(1, 2);
    //编译的过，因为函数右面用->指定了类型，所有不是不明确类型
    retrunValue = testFunctionReturnTypeExExEx(1, 2);
    //------------------------
    
    NSLog(@"end");
}

int testFunctionReturnType(int one, float two){
    return one + two;
}

//testFunctionReturnTypeExExEx这种写法跟testFunctionReturnType等价
auto testFunctionReturnTypeExExEx(int one, float two)->int{
    return one + two;
}

auto testFunctionReturnTypeEx(int one, float two){
    return one + two;
}


#endif /* testCPPEleven_hpp */
