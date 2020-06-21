#！/bin/bash
git add .
git commit -m "$1"
git push -u origin hexo
npx hexo clean && npx hexo g -d
git pull
