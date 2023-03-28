root_dir := $(shell pwd)/
if_dir := $(strip $(root_dir))$(strip src/lib/)
top_dir := $(strip $(root_dir))$(strip src/top/)

export lib_PATH := /home/a.apolyhin/HCMOS8D/DDK/CORELIB8DHS_3.1.a/liberty/wc_1.20V_85C/CORELIB8DHS.lib
export lef_PATH := /home/a.apolyhin/HCMOS8D/PDK/PDK_v2.3/lef/DK_hcmos8d.techlef /home/a.apolyhin/HCMOS8D/DDK/CORELIB8DHS_3.1.a/lef/CORELIB8DHS.lef

rtl_src_loc := prj/src.list
rtl_tb_loc := prj/tb.list
rtl_top_loc := prj/top.list
rtl_if_loc := prj/if.list
bld_dir := $(shell pwd)/sim
syn_dir := $(shell pwd)/syn
src_dir := $(strip $(root_dir))$(strip src/ip/)

rtl_src_ip_dirs := $(addprefix $(strip $(shell pwd)),$(shell cat $(strip $(root_dir))$(strip $(rtl_src_loc))))

rtl_src_list := $(foreach dir, $(rtl_src_ip_dirs), $(addprefix $(strip $(dir)),$(strip $(rtl_src_loc))))
rtl_src_files := $(foreach file, $(rtl_src_list), $(addprefix $(strip $(src_dir)),$(strip $(shell cat $(file)))))
rtl_tb_list := $(foreach dir, $(rtl_src_ip_dirs), $(addprefix $(strip $(dir)),$(strip $(rtl_tb_loc))))
rtl_tb_files := $(foreach file, $(rtl_tb_files), $(addprefix $(strip $(src_dir)),$(strip $(shell cat $(file)))))

rtl_if_files := $(addprefix $(strip $(if_dir)),$(shell cat $(strip $(root_dir))$(strip $(rtl_if_loc))))
rtl_top_files := $(addprefix $(strip $(top_dir)),$(shell cat $(strip $(root_dir))$(strip $(rtl_top_loc))))
rtl_top_tb_files := $(addprefix $(strip $(root_dir)),$(shell cat $(strip $(root_dir))$(strip $(rtl_tb_loc))))

rtl_inc_dir := $(foreach dir, $(rtl_src_ip_dirs), $(strip $(dir))$(strip src/includes/))
rtl_inc_top_dir := $(strip $(root_dir))$(strip src/top/)
rtl_inc_top_tb_dir := $(strip $(root_dir))$(strip tb/)
rtl_inc_tb_dir := $(foreach dir, $(rtl_src_ip_dirs), $(strip $(dir))$(strip tb/))

sv_list := $(rtl_if_files) $(rtl_src_files) $(rtl_tb_files) $(rtl_top_files) $(rtl_top_tb_files)
export syn_list := $(rtl_if_files) $(rtl_src_files) $(rtl_top_files)

xrun_options += +access+rwc
xrun_options += +gui
xrun_options += +xm64bit
xrun_options += -timescale 100ps/1ps
xrun_options += -l log.log
xrun_options += -linedebug
xrun_options += $(foreach dir, $(rtl_inc_dir), $(strip +incdir+)$(strip $(dir)))
xrun_options += $(foreach dir, $(rtl_inc_tb_dir), $(strip +incdir+)$(strip $(dir)))
xrun_options += +incdir+$(rtl_inc_top_dir)
xrun_options += +incdir+$(rtl_inc_top_tb_dir)
xrun_options += -sv

debug_make:
	$(rtl_src_files)

build:
	mkdir -p $(bld_dir)
	cd $(bld_dir) && \
		module purge && \
		module load cadence/XCELIUMMAIN/19.03.009 && \
		xrun $(xrun_options) $(sv_list)

syn_build:
	mkdir -p $(syn_dir)
	cd $(syn_dir) && \
		module purge && \
		module load cadence/GENUS/19.14.000 && \
		genus -legacy_ui -files syn_script.tcl