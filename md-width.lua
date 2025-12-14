local red = "\27[31m"
local reset = "\27[0m"

function Pandoc(doc)
  local width = 72
  if doc.meta and doc.meta.width then
    width = tonumber(tostring(doc.meta.width)) or 72
  end

  local violations = 0
  for _, block in ipairs(doc.blocks) do
    if block.attributes and block.attributes['data-pos'] then
      local start_line = string.match(block.attributes['data-pos'], '@([0-9]+):')
      if start_line then
        start_line = tonumber(start_line)
        local block_doc = pandoc.Pandoc({ block })
        local txt = pandoc.write(block_doc, "plain", { wrap_text = "none" })
        local lines = {}
        for line in txt:gmatch("([^\n]*)\n?") do
          table.insert(lines, line)
        end

        for i, line in ipairs(lines) do
          local len = #line
          if len > width then
            local head = line:sub(1, width)
            local tail = line:sub(width + 1)
            io.write(string.format(
              "%s%4d%s | %s%s%s\n",
              red, start_line + i - 1, reset,
              head, red, tail .. reset
            ))
            violations = violations + 1
          end
        end
      end
    end
  end

  os.exit(violations > 0 and 1 or 0)
end
