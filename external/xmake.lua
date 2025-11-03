target('cereal')
do
    _config_project({
        project_kind = 'headeronly'
    })
    add_includedirs('cereal/include', {
        public = true
    })
end
target_end()

target('cli11')
do
    _config_project({
        project_kind = 'static',
        enable_exception = true
    })
    add_includedirs('CLI11/include', {
        public = true
    })
    add_files('CLI11/src/*.cpp')
end
target_end()

target('freetype')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('freetype/include', {
        public = true
    })
    add_defines('FT2_BUILD_LIBRARY')
    on_load(function(target)
        local files = {'autofit/autofit.c', 'base/ftbase.c', 'base/ftbbox.c', 'base/ftbitmap.c', 'base/ftdebug.c',
                       'base/ftfstype.c', 'base/ftgasp.c', 'base/ftglyph.c', 'base/ftgxval.c', 'base/ftinit.c',
                       'base/ftlcdfil.c', 'base/ftmm.c', 'base/ftotval.c', 'base/ftpatent.c', 'base/ftpfr.c',
                       'base/ftstroke.c', 'base/ftsynth.c', 'base/ftsystem.c', 'base/fttype1.c', 'base/ftwinfnt.c',
                       'bdf/bdf.c', 'cache/ftcache.c', 'cff/cff.c', 'cid/type1cid.c', 'gzip/ftgzip.c', 'lzw/ftlzw.c',
                       'pcf/pcf.c', 'pfr/pfr.c', 'psaux/psaux.c', 'pshinter/pshinter.c', 'psnames/psmodule.c',
                       'raster/raster.c', 'sfnt/sfnt.c', 'smooth/smooth.c', 'truetype/truetype.c', 'type1/type1.c',
                       'type42/type42.c', 'winfonts/winfnt.c'}
        for i, v in ipairs(files) do
            target:add('files', path.join(os.scriptdir(), 'freetype/src', v))
        end
    end)
end
target_end()

target('glad')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('glad/include', {
        public = true
    })
    add_files('glad/src/*.c')
end
target_end()

target('glfw')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('glfw/include', {
        public = true
    })
    on_load(function(target)
        local function add_files_all(...)
            for i, v in ipairs({...}) do
                target:add('files', path.normalize(path.join(os.scriptdir(), 'glfw/src', v)))
            end
        end
        add_files_all('context.c', 'init.c', 'input.c', 'monitor.c', 'vulkan.c', 'window.c')
        if target:is_plat('windows') then
            target:add('defines', '_GLFW_WIN32')
            add_files_all('win32_init.c', 'win32_joystick.c', 'win32_monitor.c', 'win32_time.c', 'win32_window.c',
                'win32_thread.c', 'wgl_context.c', 'egl_context.c', 'osmesa_context.c')
        elseif target:is_plat('linux') then
            add_files_all('egl_context.c', 'glx_context.c', 'linux_joystick.c', 'posix_time.c', 'x11_init.c',
                'x11_monitor.c', 'x11_window.c', 'xkb_unicode.c', 'posix_thread.c', 'osmesa_context.c')
            if has_config('div_enable_wayland') then
                target:add('defines', '_GLFW_WAYLAND')
            else
                target:add('defines', '_GLFW_X11')
            end
        elseif target:is_plat('macosx') then
            add_files_all('cocoa_init.m', 'cocoa_joystick.m', 'cocoa_monitor.m', 'cocoa_window.m', 'cocoa_time.c',
                'nsgl_context.m', 'posix_thread.c', 'egl_context.c', 'osmesa_context.c')
            target:add('defines', '_GLFW_COCOA')
        else
            target:add('defines', '_GLFW_OSMESA')
        end
    end)
end
target_end()

target('glm')
do
    _config_project({
        project_kind = 'headeronly'
    })
    add_defines('GLM_FORCE_SWIZZLE', {
        public = true
    })
    add_includedirs('glm', {
        public = true
    })
end
target_end()

target('lua')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('lua/src', {
        public = true
    })
    add_files('lua/src/*.c')
end
target_end()

target('imgui')
do
    _config_project({
        project_kind = 'static'
    })
    add_deps('glfw')
    on_load(function(target)
        local function rela(p)
            return path.normalize(path.join(os.scriptdir(), 'imgui', p))
        end
        target:add('headerfiles', rela('*.h'), rela('backends/*.h'))
        target:add('files', rela('*.cpp'), rela('backends/imgui_impl_glfw.cpp'))
        target:add('includedirs', rela('.'), rela('backends'), {
            public = true
        })
        if target:is_plat('windows') then
            -- need shared library?

            -- target:add('defines', 'IMGUI_API=__declspec(dllexport)');
            -- target:add('defines', 'IMGUI_API=__declspec(dllimport)', {
            --     interface = true
            -- });
        elseif target:is_plat('linux') then
            target:add('syslinks', 'X11', {
                public = true
            })
        end
    end)
end
target_end()

target('meshoptimizer')
do
    _config_project({
        project_kind = 'static',
        enable_exception = true
    })
    add_files('ModelLoaders/meshoptimizer/src/**.cpp', 'ModelLoaders/meshoptimizer/gltf/**.cpp')
    add_includedirs('ModelLoaders/meshoptimizer//src', {
        public = true
    })
end
target_end()

target('msdf-atlas-gen')
do
    _config_project({
        project_kind = 'static'
    })
    add_files('msdf-atlas-gen/msdfgen/**.cpp')
    add_includedirs('msdf-atlas-gen/msdf-atlas-gen', 'msdf-atlas-gen/msdfgen', 'msdf-atlas-gen/msdfgen/include', {
        public = true
    })
    add_deps('freetype')
end
target_end()

target('ozz')
do
    _config_project({
        project_kind = 'static',
        enable_exception = true
    })
    add_includedirs('ozz-animation/include', 'ozz-animation/src', {
        public = true
    })
    on_load(function(target)
        local function rela(p)
            return path.normalize(path.join(os.scriptdir(), 'ozz-animation', p))
        end
        target:add('files', rela('src/base/**.cc'), rela('src/animation/runtime/**.cc'),
            rela('src/animation/offline/*.cc'), rela('src/animation/offline/tools/*.cc'), rela('src/options/*.cc'),
            rela('extern/jsoncpp/jsoncpp.cpp'))
        target:add('includedirs', rela('extern/jsoncpp'))
    end)
end
target_end()

target('pkg')
do
    set_kind('headeronly')
    add_includedirs('pkg/include', {
        public = true
    })
    on_load(function(target)
        target:add('linkdirs', path.join(os.scriptdir(), 'pkg/liblink'), {
            public = true
        })
        target:add('links', 'zlib', {
            public = true
        })
        target:add('links', 'zlib', 'mesh_utils', {
            public = true
        })
    end)
    after_build(function(target)
        os.cp(path.join(os.scriptdir(), 'pkg/liblink/mesh_utils.dll'), path.join(target:targetdir(), 'mesh_utils.dll'),
            {
                copy_if_different = true
            })
        os.cp(path.join(os.scriptdir(), 'pkg/liblink/zlib1.dll'), path.join(target:targetdir(), 'zlib1.dll'), {
            copy_if_different = true
        })
    end)
end

target('pugixml')
do
    _config_project({
        project_kind = 'static',
        enable_exception = true
    })
    add_files('pugixml/src/**.cpp')
    add_includedirs('pugixml/src', {
        public = true
    })
end
target_end()

target('spdlog')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('spdlog/include', {
        public = true
    })
    on_load(function(target)
        local function rela(p)
            return path.join(os.scriptdir(), 'spdlog', p)
        end
        if has_config('spdlog_only_fmt') then
            target:add('defines', 'FMT_USE_CONSTEVAL=0', 'FMT_USE_CONSTEXPR=1', 'FMT_UNICODE=0', 'FMT_EXCEPTIONS=0', {
                public = true
            })
            target:add('headerfiles', rela('include/spdlog/fmt/**.h'))
            target:add('files', rela('src/bundled_fmtlib_format.cpp'))
        else
            target:add('defines', 'SPDLOG_NO_EXCEPTIONS', 'SPDLOG_NO_THREAD_ID', 'SPDLOG_DISABLE_DEFAULT_LOGGER',
                'FMT_UNICODE=0', 'FMT_USE_CONSTEVAL=0', 'FMT_USE_CONSTEXPR=1', 'FMT_EXCEPTIONS=0', {
                    public = true
                })
            target:add('headerfiles', rela('include/**.h'))
            target:add('files', rela('src/*.cpp'))
            if is_plat('windows') then
                target:add('defines', 'NOMINMAX', 'UNICODE')
            end
        end
        target:add('defines', 'SPDLOG_COMPILED_LIB', {
            public = true
        })
    end)
end
target_end()

target('spz')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('spz/include', {
        public = true
    })
    add_files('spz/src/**.cc')
    add_deps('pkg')
    on_load(function(target)
        if target:is_plat('windows') then
            target:add('links', path.join(os.scriptdir(), 'spz/liblink/win/spz'))
        end
    end)
end
target_end()

target('stb')
do
    set_kind('headeronly')
    add_includedirs('stb', {
        public = true
    })
end
target_end()

target('tinyexr')
do
    _config_project({
        project_kind = 'static'
    })
    add_includedirs('tinyexr', 'tinyexr/deps/ZFP/inc', {
        public = true
    })
    add_files('tinyexr/tinyexr.cc', 'tinyexr/deps/ZFP/src/zfp.c')
end
target_end()

target('tinyply')
do
    _config_project({
        project_kind = 'static',
        enable_exception = true
    })
    add_files('tinyply/tinyply.cpp')
    add_includedirs('tinyply', {
        public = true
    })
end
target_end()

target('tomasakeninemoeller')
do
    set_kind('headeronly')
    add_includedirs('tomasakeninemoeller/include', {
        public = true
    })
end
target_end()

target('webgpu')
do
    set_kind('headeronly')
    add_includedirs('webgpu/include', {
        public = true
    })
end
target_end()

target('volk')
do
    _config_project({
        project_kind = 'static'
    })
    add_defines('VK_NO_PROTOTYPES', {
        public = true
    })
    add_files('vulkan/volk/volk.c')
    add_includedirs('.', 'vulkan/volk', {
        public = true
    })
    on_load(function(target)
        if target:is_plat('linux') then
            target:add('defines', 'VK_USE_PLATFORM_XLIB_KHR', {
                public = true
            })
        end
    end)
end
target_end()

target('xatlas')
do
    _config_project({
        project_kind = 'static'
    })

    add_files('xatlas/src/*.cpp')
    add_includedirs('xatlas/src', {
        public = true
    })
end
target_end()

target('external')
do
    set_kind('phony')
    add_includedirs('.', {
        public = true
    })
    add_deps('cereal', 'cli11', 'glm', 'glad', 'glfw', 'freetype', 'imgui', 'lua', 'meshoptimizer', 'msdf-atlas-gen',
        'ozz', 'pkg', 'pugixml', 'spdlog', 'spz', 'stb', 'tinyexr', 'tinyply', 'tomasakeninemoeller',
        'volk', 'webgpu', 'xatlas')
end
target_end()
