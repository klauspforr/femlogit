*! version 1.0.0 11Nov2013 femlogit example 1
clear all
set more off
set linesize 79
set scheme sj

sjlog using "femlogit1", replace
use femlogitid
list in 1/11
sjlog close, replace
