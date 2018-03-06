#!/bin/bash
bundle exec jekyll serve &
pid=$!
sleep 3
firefox -new-window http://127.0.0.1:4000/
wait $pid
