target('diverse')
do
    _config_project({
        project_kind = 'static',
        rtti = true,
        enable_exception = true
    })
    add_includedirs('source', 'diverse_base/source', {
        public = true
    })
    add_files('diverse_base/source/**.cpp')
    set_pcxxheader('source/pch.h')
    on_load(function(target)
        if (target:is_plat('windows')) then
            target:add('defines', 'DS_PLATFORM_WINDOWS', {
                public = true
            })
        end
        target:add('defines', 'DS_USE_GLFW_WINDOWS', 'DS_RENDER_API_VULKAN', 'DS_VOLK', 'IMGUI_DISABLE_STB_RECT_PACK_IMPLEMENTATION', 'USE_VMA_ALLOCATOR', {
            public = true
        })
        -- recursively iterate all files
        for i, filepath in ipairs(os.files(path.join(os.scriptdir(), 'source/**.cpp'))) do
            local paths = path.split(filepath)
            local contains_platform
            for i, v in ipairs(paths) do
                if v == 'platform' then
                    contains_platform = true
                    break
                end
            end
            if contains_platform then
                if (paths[#paths - 1] == 'macos' and (not target:is_plat('macosx'))) or
                    (paths[#paths - 1] == 'unix' and (not target:is_plat('linux'))) or
                    (paths[#paths - 1] == 'windows' and (not target:is_plat('windows'))) then
                    goto CONTINUE
                end
            end
            target:add('files', filepath)
            ::CONTINUE::
        end
    end)
    add_deps('external')
end
