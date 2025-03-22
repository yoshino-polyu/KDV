def compare_functions_time(func1_ms, func2_us):
    # 将 function2 的耗时从微秒转换成毫秒
    func2_ms = func2_us / 1000.0

    # 计算 ratio，表示 function1 是 function2 的多少倍
    if func2_ms != 0:
        ratio = func1_ms / func2_ms
    else:
        ratio = float('inf')  # 如果 function2 耗时为 0，则倍数无限大
    return func1_ms, func2_ms, ratio

if __name__ == "__main__":
    try:
        # 获取用户输入
        func1_time = float(input("请输入 function1 的耗时 (毫秒): "))
        func2_time = float(input("请输入 function2 的耗时 (微秒): "))
    except ValueError:
        print("请输入有效的数字！")
        exit(1)

    # 调用函数比较耗时
    f1_ms, f2_ms, ratio = compare_functions_time(func1_time, func2_time)

    print("function1 耗时: {:.3f} ms".format(f1_ms))
    print("function2 耗时: {:.3f} ms".format(f2_ms))
    print("function1 是 function2 的 {:.2f} 倍耗时".format(ratio))