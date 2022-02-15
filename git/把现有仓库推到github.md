1、先在GitHub添加一个仓库，比如https://github.com/salior/AppleBLE.git

2、在原有仓库用git remote add origin https://github.com/salior/AppleBLE.git 增加一个远程仓库

3、先git pull一下，这样就可以将原有的GitHub的main分支拉下来。拉的时候可能提示要输GitHub用户名和密码，目前已不支持密码方式，需要输入GitHub的token，之前创建过一个：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,当时创建给apple使用的，这里也记一下，输入密码的时候输入这个就可以pull了。

4、pull下来之后，本地就有了两个分支，一个是github的main分支，一个是本地的master分支，我们checkout到main分支，然后把master分支的merge到main就可以了。用的命令是 git merge master --allow-unrelated-histories ，后面这个参数是由于原有两个分支是无关系的，不加参数会提示fatal: refusing to merge unrelated histories。

5、merge之后，就push一下提交到GitHub就行了
