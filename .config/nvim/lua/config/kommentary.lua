-- Configure kommentary
require('kommentary.config').use_extended_mappings()
require('kommentary.config').configure_language('default', { prefer_single_line_comments = true })
require('kommentary.config').configure_language('vue', {
    pre_comment_hook = function ()
        require('ts_context_commentstring.internal').update_commentstring()
    end,
})
