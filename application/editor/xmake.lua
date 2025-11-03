target('editor')
do
    _config_project({
        project_kind = 'binary'
    })
    add_files('**.cpp')
    add_deps('external')
end
target_end()
