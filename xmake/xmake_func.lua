option("_div_script_path")
set_showmenu(false)
set_default(false)
after_check(function(option)
    option:set_value(os.scriptdir())
end)
option_end()

option("_div_check_env")
set_showmenu(false)
set_default(false)
after_check(function(option)
    if not is_arch("x64", "x86_64", "arm64") then
        option:set_value(false)
        utils.error("Illegal environment. Please check your compiler, architecture or platform.")
        return
    end
    if not (is_mode("debug") or is_mode("release") or is_mode("releasedbg")) then
        option:set_value(false)
        utils.error("Illegal mode. set mode to 'release', 'debug' or 'releasedbg'.")
        return
    end
    option:set_value(true)
end)
option_end()

rule("div_basic_settings")
on_config(function(target)
    if target:is_plat("linux") then
        -- Linux should use -stdlib=libc++
        -- https://github.com/LuisaGroup/LuisaCompute/issues/58
        if target:has_tool("cxx", "clang", "clangxx") then
            target:add("cxflags", "-stdlib=libc++", {
                force = true
            })
            target:add("syslinks", "c++")
        end
    end
    -- disable LTO
    -- if cc == "cl" then
    --     target:add("cxflags", "-GL")
    -- elseif cc == "clang" or cc == "clangxx" then
    --     target:add("cxflags", "-flto=thin")
    -- elseif cc == "gcc" or cc == "gxx" then
    --     target:add("cxflags", "-flto")
    -- end
    -- local _, ld = target:tool("ld")
    -- if ld == "link" then
    --     target:add("ldflags", "-LTCG")
    --     target:add("shflags", "-LTCG")
    -- elseif ld == "clang" or ld == "clangxx" then
    --     target:add("ldflags", "-flto=thin")
    --     target:add("shflags", "-flto=thin")
    -- elseif ld == "gcc" or ld == "gxx" then
    --     target:add("ldflags", "-flto")
    --     target:add("shflags", "-flto")
    -- end
end)
on_load(function(target)
    local _get_or = function(name, default_value)
        local v = target:extraconf("rules", "div_basic_settings", name)
        if v == nil then
            return default_value
        end
        return v
    end
    local toolchain = _get_or("toolchain", get_config("div_toolchain"))
    if toolchain then
        target:set("toolchains", toolchain)
    end
    local project_kind = _get_or("project_kind", nil)
    if project_kind then
        target:set("kind", project_kind)
    end
    if target:is_plat("linux") then
        if project_kind == "static" or project_kind == "object" then
            target:add("cxflags", "-fPIC")
        end
    end
    if target:is_plat("macosx") then
        target:add("cxflags", "-no-pie")
        target:add("cxflags", "-Wno-invalid-specialization", {
            tools = {"clang"}
        })
    end
    -- fma support
    if target:is_arch("x64", "x86_64") then
        target:add("cxflags", "-mfma", {
            tools = {"clang", "gcc"}
        })
    end
    local c_standard = _get_or("c_standard", nil)
    local cxx_standard = _get_or("cxx_standard", nil)
    if type(c_standard) == "string" and type(cxx_standard) == "string" then
        target:set("languages", c_standard, cxx_standard, {
            public = true
        })
    else
        target:set("languages", "clatest", "cxx20", {
            public = true
        })
    end

    local enable_exception = _get_or("enable_exception", nil)
    if enable_exception then
        target:set("exceptions", "cxx")
    else
        target:set("exceptions", "no-cxx")
    end

    local win_runtime = get_config("div_win_runtime")
    if is_mode("debug") then
        if not win_runtime then
            win_runtime = "MDd"
        end
        target:set("optimize", _get_or("optimize", "none"))
        target:add("cxflags", "/GS", "/Gd", {
            tools = {"clang_cl", "cl"},
            public = true
        })
    elseif is_mode("releasedbg") then
        if not win_runtime then
            win_runtime = "MDd"
        end
        target:set("optimize", _get_or("optimize", "none"))
        target:add("cxflags", "/GS-", "/Gd", {
            tools = {"clang_cl", "cl"},
            public = true
        })
    else
        if not win_runtime then
            win_runtime = "MD"
        end
        target:set("optimize", _get_or("optimize", "aggressive"))
        target:add("cxflags", "/GS-", "/Gd", {
            tools = {"clang_cl", "cl"},
            public = true
        })
    end
    target:set("warnings", _get_or("warnings", "none"))
    target:set("runtimes", _get_or("runtime", win_runtime), {
        public = true
    })
    target:set("fpmodels", _get_or("fpmodels", "fast"))
    target:add("cxflags", "/Zc:preprocessor", {
        tools = "cl",
        public = true
    });
    if _get_or("use_simd", has_config("div_enable_simd")) then
        if is_arch("arm64") then
            target:add("vectorexts", "neon", {
                public = true
            })
        else
            target:add("vectorexts", "avx", "avx2", {
                public = true
            })
        end
    end
    local use_rtti = _get_or("rtti", false)
    if _get_or("no_rtti", not (use_rtti or has_config("div_use_rtti"))) then
        target:add("cxflags", "/GR-", {
            tools = {"clang_cl", "cl"}
        })
        target:add("cxflags", "-fno-rtti", "-fno-rtti-data", {
            tools = {"clang"}
        })
        target:add("cxflags", "-fno-rtti", {
            tools = {"gcc"}
        })
    else
        target:add("cxflags", "/GR", {
            tools = {"clang_cl", "cl"}
        })
    end
end)
rule_end()

target("div-check-winsdk")
set_kind("phony")
on_config(function(target)
    if not target:is_plat("windows") then
        return
    end
    local toolchain_settings = target:toolchain("msvc")
    if not toolchain_settings then
        toolchain_settings = target:toolchain("clang-cl")
    end
    if not toolchain_settings then
        toolchain_settings = target:toolchain("llvm")
    end
    if not toolchain_settings then
        return
    end
    local sdk_version = toolchain_settings:runenvs().WindowsSDKVersion
    local legal_sdk = false
    if sdk_version then
        import("core.base.semver")
        local ver = semver.match(sdk_version)
        if ver then
            if ver:major() > 10 then
                legal_sdk = true
            elseif ver:major() == 10 then
                if ver:patch() >= 22000 then
                    legal_sdk = true
                end
            end
        end
        if not legal_sdk then
            raise("Illegal windows SDK version, requires 10.0.22000.0 or later")
        end
    end
end)
target_end()
rule("build_cargo")
set_extensions(".toml")
on_buildcmd_file(function(target, batchcmds, sourcefile, opt)
    local lib = import("lib")
    local sb = lib.StringBuilder("cargo build -q ")
    -- if backend_off then
    sb:add("--no-default-features ")
    -- end
    sb:add("--manifest-path ")
    sb:add(sourcefile):add(' ')
    local features = target:get('features')
    if features then
        sb:add("--features ")
        sb:add(features):add(' ')
    end
    if not is_mode("debug") then
        sb:add("--release ")
    end
    local cargo_cmd = sb:to_string()
    batchcmds:show(cargo_cmd)
    batchcmds:vrun(cargo_cmd)
    sb:dispose()
end)
rule_end()

-- Support:

-- add_rules('div_install_sdk', {
--     sdk_dir = xxx
--     libnames = {{
--         name = yyy,
--         extract_dir = xxx                 -- extract to default dir or target dir
--         copy_dir = ""                    -- no copy or copy to target dir
--         plat_spec = true                 -- name will be transformed to yyyy-linux-x64.zip
--     }}
-- })

-- add_rules('div_install_sdk', {
--     libnames = xxx
--     
-- })

-- and

-- add_rules('div_install_sdk', {
--     sdk_dir = xxx
--     libnames = {
--         name = yyy
--     }
-- })
rule('div_install_sdk')
on_prepare(function(target)
    import("find_sdk")
    find_sdk.on_install_sdk(target, 'div_install_sdk')
end)
rule_end()

rule("div_run_target")
on_run(function(target)
    import("core.base.option")
    local name = target:extraconf("rules", "div_run_target", "name")
    if not name then
        name = target:name()
    end
    local arguments = option.get("arguments")
    local tar_dir = path.absolute(target:targetdir())
    os.execv(path.join(tar_dir, name), arguments, {
        curdir = tar_dir
    })
end)
rule_end()

-- In-case of submod, when there is override rules, do not overload
if _config_rules == nil then
    _config_rules = {"div_basic_settings"}
end
if _disable_unity_build == nil then
    local unity_build = get_config("div_enable_unity_build")
    if unity_build ~= nil then
        _disable_unity_build = not unity_build
    end
end
if not _config_project then
    function _config_project(config)
        local batch_size = config["batch_size"]
        if type(batch_size) == "number" and batch_size > 1 and (not _disable_unity_build) then
            add_rules("c.unity_build", {
                batchsize = batch_size
            })
            add_rules("c++.unity_build", {
                batchsize = batch_size
            })
        end
        if type(_config_rules) == "table" then
            add_rules(_config_rules, config)
        end
    end
end
