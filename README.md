#  Sample

Debian packages are available at: $(REPOURL), and can be included to `apt` list
with:
```
echo deb [trusted=yes] ${REPOURL} ./ > /etc/apt/repos.list
apt update
...
```
