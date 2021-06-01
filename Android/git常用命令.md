# git的常用命令
```
git status -uno 不显示未跟踪文件 
git log --pretty=oneline 单独显示修改log注释 
git show id 显示个修改内容 
git show id --stat 
git log --name-status 显示修改的文件列表，状态 
git reset HEAD -name 撤销错add的文件 //不起作用 
 
git log -p id file 查看某次某文件的修改 
 
git log --author=chenyi 	查看某作者的修改 

git reset --soft commit-id 撤销commit，暂存区和工作区不变 
git reset --mixed commit-id 撤销commit和add，工作区不变 
git reset --hard commit-id 恢复到某版本号状态，暂存区和工作区都变化 
git reset --hard HEAD^ 恢复到上一版本 HEAD^^ 上上版本 
 
如果要后悔恢复，可以用git reflog看操作记录，再用git reset --hard commit-id恢复到后悔的点。 
 
如何撤销一个合并 
只要在命令行界面中键入 “git merge --abort” 命令，你的合并操作就会被安全的撤销。 
 
//与远程冲突的话，直接同步服务器的记录 
git reset --hard FETCH_HEAD 
 
分支相关： 
git branch //查看分支 
 
git checkout -b dev :相当于 git branch dev  &&  git checkout dev 
在分支修改完毕后， 
git checkout master 
git merge dev  //如果有冲突就解决冲突，然后add 和commit。 
成功之后可以del分支 
git branch -d dev 
 
可以直接使用 -f 选项让分支指向另一个提交。例如: 
git branch -f master HEAD~3 
上面的命令会将 master 分支强制指向 HEAD 的第 3 级父提交。 
 
log查找 
git log --grep=1629  //记录内容 
git log --author=chenyi //上传者 
 
//加入审核系统之后： 
修改提交的 author 可以用 git commit --amend --author="yi.kck.chen <yi.kck.chen@faurecia.com> 
有提示有冲突的话 执行 git pull  --rebase 

补丁评审没有通过，需要重新修改上传，在提交阶段，应该使用命令git commit --amend --no-edit 
 
//看远程仓库的地址 
git remote -v 

//rebase 
1、原来在branch1,切换到maser，执行git rebase branch1，则branch1的修改会排到master上面。 
2、git rebase -i 将提交重新排序，然后把我们想要修改的提交记录挪到最前。例子，git rebase -i HEAD~3，这里会显示一个界面让你调整要提交的记录，要调整的顺序等操作 
 
//revert 
现在有修改记录C1，C2，如果要回退到C1，则可以用git revert C1,然后提交。 
 
//修改提交 
git commit --amend，在当前的HEAD提交里，添加修改和说明 
 
//添加标签，tag,主要用于标记一个重要的节点 
例子：git tag v0 C1 , 到时候，用git checkout v0,可以回到当时的节点状态 
 
//c211分支的操作 
1、查看远程的分支 
git branch -r 
  gerrit/ChangAn-C211-HAL 
  gerrit/master 
  origin/ChangAn-C211-HAL 
  origin/HEAD -> origin/master 
  origin/master 
2、拉211的分支 
git checkout -b c211 origin/ChangAn-C211-HAL 
3、更新代码后，提交 
git review -c ChangAn-C211-HAL 
 
  
 
//打patch的命令 
git diff --stat //看文件的差异 
git show id --stat //看某修改的文件差异 
git format-patch --root id --author=yyyy  //将作者yyy的修改，从root(仓库最初状态)到id的全部修改打成patch文件 
//想要打出0163bed3bf59ae74c36cc5138b4c24f1556d8304和它之前的一次提交的patch，则： 
git format-patch 0163bed3bf59ae74c36cc5138b4c24f1556d8304 -2 
//检查patch是否可用，没显示文字，就说明可用，且无冲突； 
git apply --check ~/patch/patch/0001-add-11111.patch
```
