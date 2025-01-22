# ohContainerBuilder
Necessary commands to build openhome in a container



# Create building folder, create the container image and execute the container
Tested in wsl2 with docker desktop installed
Create a folder and cd in it


mkdir work
cd work
git clone https://github.com/openhome/openssl
git clone https://github.com/openhome/ohdevtools
git clone https://github.com/openhome/ohPipeline
git clone https://github.com/openhome/ohNet
git clone https://github.com/jchassin/ohNetGenerated
git clone https://github.com/jchassin/ohPlayer
git clone https://github.com/openhome/ohWafHelpers
cd ..

docker buildx build --load -t my-openhome:1.0
docker run -it -v ./work:/work --rm my-openhome:1.0 bash

# Build oh
# Inside the container bash
export openhome_folder=/work
export target=Linux-x64

# build ohNet
cd ohNet ; make GenAll uset4=yes ; make ; cd ..

# open ssl
cd openssl
python ./create_lib.py --platform ${target} --configure --clean --build

