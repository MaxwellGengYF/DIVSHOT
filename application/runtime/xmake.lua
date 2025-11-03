target('runtime')
do
    _config_project({
        project_kind = 'binary'
    })
    add_files('**.cpp')
    add_deps('diverse')
end
target_end()
