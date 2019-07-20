#！/bin/bash
git add .
git commit -m "$1"
git push -u origin hexo
hexo clean && hexo g -d

