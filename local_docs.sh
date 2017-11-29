#!/bin/bash
set -ex
#for type in stylesheets, images, fonts, javascripts, overview, design, implementation; do 
for file in $(grep -Rl "/grim/stylesheets" ./docs); do
	sed -i "s/\/grim\/stylesheets/\/stylesheets/" $file
done
for file in $(grep -Rl "/grim/images" ./docs); do
	sed -i "s/\/grim\/images/\/images/" $file
done
for file in $(grep -Rl "/grim/fonts" ./docs); do
	sed -i "s/\/grim\/fonts/\/fonts/" $file
done
for file in $(grep -Rl "/grim/javascripts" ./docs); do
	sed -i "s/\/grim\/javascripts/\/javascripts/" $file
done
for file in $(grep -Rl "/grim/overview" ./docs); do
	sed -i "s/\/grim\/overview/\/overview/" $file
done
for file in $(grep -Rl "/grim/design" ./docs); do
	sed -i "s/\/grim\/design/\/design/" $file
done
for file in $(grep -Rl "/grim/implementation" ./docs); do
	sed -i "s/\/grim\/implementation/\/implementation/" $file
done

sudo /usr/local/bin/quark -d ~/grim/docs -p 80 &
surf localhost:80 &
