cp d.sh ../public_temp/
cp CNAME ../public_temp/
cp README ../public_temp/
rm -rf *
mv ../public_temp/* .
git add *
git commit -am 'deploy'
git push origin master
