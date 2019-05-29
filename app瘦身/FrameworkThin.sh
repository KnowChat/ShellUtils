#thin function
thinFramework() {
    inputFilePath=$1
    fileName=$2

    mkdir arm64
    mkdir armv7

    lipo $inputFilePath -thin arm64 -output ./arm64/$fileName
    lipo $inputFilePath -thin armv7 -output ./armv7/$fileName

    lipo -create ./arm64/$fileName ./armv7/$fileName -output $inputFilePath
    info=$(lipo -info $inputFilePath)
    echo ">>>>>>thin success:\n$info\n<<<<<<"

    rm -rf arm64
    rm -rf armv7
}

#判断是否是需要瘦身的文件
judgeFramework() {
    #check framework
    pathName=$(cd `dirname $1`; pwd)
    allName=$(basename $1)
    fileName=${allName%.*}
    extension=${allName##*.}

    #判断是否是framework文件
    if [ $extension == "framework" ]
    then
        #check lipo -info
        cd $pathName
        inputFilePath="./$allName/$fileName"
        info=$(lipo -info $inputFilePath)
        echo "................................."
        echo $info
        if [ "$operation" == "-c" ]
        then
            return 1
        else
            if [[ $info =~ "i386" || $info =~ "x86_64" ]]
            then
                thinFramework $inputFilePath $fileName
            fi
        fi
    return 1
    fi
    return 0
}

#检索路径下所有文件
read_dir_son() {
    for file in `ls $1`
    do
        read_dir "$1/$file"
    done
}

#检索路径文件
read_dir() {
    if [ -d "$1" ]
    then
        judgeFramework "$1"
        if [ "$?" == "0" ]
        then
            read_dir_son "$1"
        fi
    fi
}

#介绍
printIndroduction() {
    echo "Framework瘦身工具"
    echo "Platform: Linux"
    echo "Author: Tyler 2019-5-29"
    echo ""
    echo "用法 -- sh FrameworkThin.sh <framework_path> [operation]"
    echo "参数说明"
    echo "<framework_path>:"
    echo "  可以传framework文件路径或者framework文件所在文件夹路径"
    echo "  当framework_path=文件夹路径时，该文件夹下所有framework会受影响"
    echo ""
    echo "[operation]: (可选参数)"
    echo "  不填默认是进行瘦身"
    echo "  '-c':只检查支持的cpu架构，不进行瘦身"
    echo ""
}

#main
printIndroduction
operation="$2"
read_dir "$1"
