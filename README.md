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

# temporary : when all is built, rebuild ohNet.net.dll with mcs as not working with ohNetGenerated with dotnet
cd ohNet
mcs /nologo /optimize+ /debug:pdbonly /t:library /optimize+ /debug:pdbonly  /warnaserror+        /out:Build/Obj/Posix/Release/ohNet.net.dll         OpenHome/Net/Bindings/Cs/ControlPoint/CpDevice.cs         OpenHome/Net/Bindings/Cs/ControlPoint/CpDeviceUpnp.cs         OpenHome/Net/Bindings/Cs/ControlPoint/CpProxy.cs         OpenHome/Net/Bindings/Cs/ControlPoint/CpService.cs         OpenHome/Net/Bindings/Cs/Device/DvDevice.cs         OpenHome/Net/Bindings/Cs/Device/DvProvider.cs         OpenHome/Net/Bindings/Cs/Device/DvProviderErrors.cs         OpenHome/Net/Bindings/Cs/Device/DvServerUpnp.cs         OpenHome/Net/Bindings/Cs/Service.cs         OpenHome/Net/Bindings/Cs/OhNet.cs         OpenHome/Net/Bindings/Cs/SubnetList.cs         OpenHome/Net/Bindings/Cs/ControlPoint/CpDeviceDv.cs
python bundle_binaries.py --system Linux --architecture x64 --configuration Release

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
ln -s "../../../ohWafHelpers" "dependencies/AnyPlatform/."
./waf configure --dest-platform=${target} --ohnet=../ohNet --ssl=../openssl/build/${target} --cross=
./waf build
./waf bundle
```

# build ohNetGenerated 
```bash
cd ../ohNetGenerated ; mkdir -p dependencies/${target}
cp ../ohNet/Build/Bundles/ohNet-${target}-Release.tar.gz ./dependencies/${target}/.
tar -xzf dependencies/${target}/ohNet-${target}-Release.tar.gz -C dependencies/${target}/.
make GenAll uset4=yes
make
```

# build ohMediaPlayer
```bash
cd ohPlayer
mkdir -p "dependencies/AnyPlatform"
ln -s "../../../ohWafHelpers" "dependencies/AnyPlatform/."
mkdir -p "dependencies/${target}"
cd dependencies/${target}
# put openssl
cp "../openssl/build/openssl-development-${target}-Release.tar.bz2" dependencies/${target}/.
tar -xf dependencies/${target}/openssl-development-${target}-Release.tar.bz2 -C dependencies/${target}/.
# Install ohNet
cp ../ohNet/Build/Bundles/ohNet-${target}-Release.tar.gz ./dependencies/${target}/.
tar -xzf dependencies/${target}/ohNet-${target}-Release.tar.gz -C dependencies/${target}/.
# Install ohNetGenerated
cp ../ohNetGenerated/Build/Bundles/ohNetGenerated-${target}-Release.tar.gz ./dependencies/${target}/.
tar -xzf dependencies/${target}/ohNetGenerated-${target}-Release.tar.gz -C ./dependencies/${target}/. 
# install ohMediaPlayer
cp -Rf "../ohPipeline/build/ohMediaPlayer.tar.gz" "./dependencies/${target}/."
tar -xzf ./dependencies/${target}/ohMediaPlayer.tar.gz -C ./dependencies/${target}/.
cd linux ; DISABLE_GTK=1 make ubuntu



