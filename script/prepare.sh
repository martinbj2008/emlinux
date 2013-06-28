#!/bin/bash
set -x

. $1

linux_prepare() {
	cp $SRC_ROOT/linux.config  $DST_ROOT/.config
	touch $DST_ROOT/romfs_cpio.desc
}

busybox_prepare() {
	sed s:CONFIG_PREFIX=\"\":CONFIG_PREFIX=\"$ROMFS_ROOT\":g $SRC_ROOT/busybox.config>$DST_ROOT/.config
}

iproute2_prepare() {
	cd $DST_ROOT && ./configure
}

lkm_prepare() {
	echo "Nothging todo for lkm"
}

git_repo_prepare() {
	repo_name=$1
}

for app in $APPS ; do	

	echo "Prepare $app ..."
	DST_ROOT=$BUILD_ROOT/$app
	if [ -d $DST_ROOT ] ; then
		echo "Dir has been created !"
		echo -e "Skip $app\n"
		continue;
	fi

	##Create git repo 
	git init $DST_ROOT;
	cd $DST_ROOT;

	####add local repo to accelerate git repo.
	LOCAL_REPO=$LOCAL_GIT_ROOT/$app
	[ -d $LOCAL_REPO ] &&  git remote add localtmp $LOCAL_REPO && git fetch localtmp

	#### formal source on github
	REPO_URL=$GIT_ROOT/$app.git
	git remote add github $REPO_URL && git fetch  github
	git checkout -b github github/master

	cd -
	##Create git repo (fin)

	files=$app.mk
	SRC_ROOT=$CFG_ROOT/$app

	${app}_prepare || exit
	for i in $files; do
		cp $SRC_ROOT/$i $DST_ROOT/
	done

	echo "$app Ready!"
	echo 
done
