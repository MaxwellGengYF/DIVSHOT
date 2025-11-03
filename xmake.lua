set_xmakever('3.0.4')
add_rules('mode.release', 'mode.debug', 'mode.releasedbg')
set_policy('build.ccache', not is_plat('windows'))
set_policy('check.auto_ignore_flags', false)

if (os.host() == "windows") then
    add_defines("UNICODE", "_UNICODE", "NOMINMAX", "_WINDOWS")
    add_defines("_GAMING_DESKTOP")
    add_defines("_CRT_SECURE_NO_WARNINGS")
    add_defines("_ENABLE_EXTENDED_ALIGNED_STORAGE")
    add_defines("_DISABLE_CONSTEXPR_MUTEX_CONSTRUCTOR") -- for preventing std::mutex crash when lock
    if (is_mode("release")) then
        set_runtimes("MD")
    elseif (is_mode("asan")) then
        add_defines("_DISABLE_VECTOR_ANNOTATION")
        -- else
        --     set_runtimes("MDd")
    end
end

option('div_enable_wayland', {
    default = false
})

includes('xmake/xmake_func.lua', 'external', 'diverse')