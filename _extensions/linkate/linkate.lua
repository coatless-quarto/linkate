local collected_links = {}
local seen_links = {}

-- Add a link to our collection (avoiding duplicates)
local function add_link(link_elem)
  local link_key = pandoc.utils.stringify(link_elem.content) .. "|" .. link_elem.target
  
  if not seen_links[link_key] then
    seen_links[link_key] = true
    table.insert(collected_links, link_elem:clone())
  end
end

-- Collect links during the first pass
local function collect_links(el)
  if el.t == "Link" then
    add_link(el)
  end
  return nil  -- Don't modify the element, just collect
end

-- Add the Links section at the end
local function add_links_section(doc)
  if #collected_links == 0 then
    return doc  -- No links found, return unchanged
  end
  
  -- Create the Links section
  local links_header = pandoc.Header(1, "Links")
  local links_list = {}
  
  -- Convert collected links to list items
  for _, link in ipairs(collected_links) do
    local list_item = pandoc.Plain({link})
    table.insert(links_list, list_item)
  end
  
  local bullet_list = pandoc.BulletList(links_list)
  
  -- Add the Links section to the document
  table.insert(doc.blocks, links_header)
  table.insert(doc.blocks, bullet_list)
  
  return doc
end

-- Return the filter functions
return {
  {
    Link = collect_links  -- First pass: collect all links
  },
  {
    Pandoc = add_links_section  -- Second pass: add links section
  }
}