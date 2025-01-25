# ohContainerBuilder
Necessary commands to build openhome in a container



## Create building folder, create the container image and execute the container
Tested in wsl2 with docker desktop installed

Create a folder and cd in it

```bash
mkdir work
cd work
git clone https://github.com/openhome/openssl
git clone https://github.com/openhome/ohdevtools
git clone https://github.com/openhome/ohPipeline
git clone https://github.com/openhome/ohNet
git clone https://github.com/openhome/ohNetGenerated
git clone https://github.com/jchassin/ohPlayer
git clone https://github.com/openhome/ohWafHelpers
cd ..

patch work/ohPipeline/wscript < patches/wscript.patch

docker buildx build --load -t my-openhome:1.0
docker run -it -v ./work:/work --rm my-openhome:1.0 bash
```

## Build oh
---
```bash
### Inside the container bash
export openhome_folder=/work
export target=Linux-x64
```
### build ohNet
```bash
cd ohNet ; make GenAll uset4=yes ; make ; cd ..
```
### build openssl
```bash
cd openssl
python ./create_lib.py --platform ${target} --configure --clean --build
```

# build ohMediaPlayer
```bash
cd ../ohPipeline
mkdir -p "dependencies/${target}"
mkdir -p "dependencies/AnyPlatform"
ln -s "../ohWafHelpers" "dependencies/AnyPlatform/."
./waf configure --dest-platform=${target} --ohnet=../ohNet --ssl=../openssl/build/${target} --cross=
./waf build
./waf bundle
```

# build ohNetGenerated > not working
```bash
cd ../ohNetGenerated ; mkdir -p dependencies/${target}
cp ../ohNet/Build/Bundles/ohNet-${target}-Release.tar.gz ./dependencies/${target}/.
cd dependencies/${target} ; tar -xzf ohNet-${target}-Release.tar.gz ; cd ../..
make GenAll uset4=yes
make


