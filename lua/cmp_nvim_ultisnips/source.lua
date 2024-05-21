local cmp = require("cmp")
local cmpu_snippets = require("cmp_nvim_ultisnips.snippets")

local source = {}
function source.new(config)
  local self = setmetatable({}, { __index = source })
  self.config = config
  self.expandable_only = config.show_snippets == "expandable"
  if config.filetype_source == "treesitter" then
    if require("cmp_nvim_ultisnips.treesitter").is_available() then
      vim.fn["cmp_nvim_ultisnips#setup_treesitter_autocmds"]()
    end
  end
  return self
end

function source:get_keyword_pattern()
  return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)"
end

function source:get_debug_name()
  return "ultisnips"
end

function source.complete(self, _, callback)
  local items = {}

  -- Get all UltiSnips snippets for the current filetype
  local snippets = vim.fn["UltiSnips#SnippetsInCurrentScope"]()

  -- Iterate through each snippet and format it for nvim-cmp
  for trigger, snippet in pairs(snippets) do
    table.insert(items, {
      label = trigger,
      insertText = trigger,
      kind = cmp.lsp.CompletionItemKind.Snippet,
      documentation = {
        kind = cmp.lsp.MarkupKind.Markdown,
        value = snippet,
      },
    })
  end

  -- Invoke the callback with the completion items
  callback({ items = items, isIncomplete = false })
end

function source.resolve(self, completion_item, callback)
  callback(completion_item)
end

function source:execute(completion_item, callback)
  vim.call("UltiSnips#ExpandSnippet")
  callback(completion_item)
end

function source:is_available()
  -- If UltiSnips is installed then this variable should be defined
  return vim.g.UltiSnipsExpandTrigger ~= nil
end

function source:clear_snippet_caches()
  cmpu_snippets.clear_caches()
end

return source
