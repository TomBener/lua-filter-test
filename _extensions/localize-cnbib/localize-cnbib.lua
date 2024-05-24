-- Function to check if a string contains Chinese characters
function contains_chinese(text)
    if not text then return false end
    return text:find("[\228-\233][\128-\191][\128-\191]") ~= nil
end

-- Function to extract digits from a string
function extract_digits(text)
    return text:match("%d+")
end

-- Function to process citations
function process_cite(el)
    local new_inlines = {}
    local i = 1

    while i <= #el.content do
        local current = el.content[i]
        if current.t == "Str" and contains_chinese(current.text) and current.text:sub(-2) == "et" and
            i + 2 <= #el.content and el.content[i + 1].t == "Space" and el.content[i + 2].t == "Str" then
            local modified_text
            if el.content[i + 2].text == "al." then
                modified_text = current.text:sub(1, -3) .. "等"
            elseif el.content[i + 2].text == "al.," then
                modified_text = current.text:sub(1, -3) .. "等,"
            end
            if modified_text then
                table.insert(new_inlines, pandoc.Str(modified_text))
                i = i + 3 -- Skip the next Space and 'al.' or 'al.,'
            else
                table.insert(new_inlines, current)
                i = i + 1
            end
        else
            table.insert(new_inlines, current)
            i = i + 1
        end
    end

    el.content = new_inlines
    return el
end

-- Function to process `et al.` in bibliography entries
function process_paragraph(para)
    local new_inlines = {}
    local i = 1

    while i <= #para.content do
        if i <= #para.content - 2 and para.content[i].t == "Str" and para.content[i].text == "et" and
            para.content[i + 1].t == "Space" and para.content[i + 2].t == "Str" and para.content[i + 2].text == "al.," then
            -- Only replace if Chinese characters are present
            if i > 2 and para.content[i - 2].t == "Str" and contains_chinese(para.content[i - 2].text) then
                table.insert(new_inlines, pandoc.Str("等,"))
                i = i + 3 -- Skip the next two elements
            else
                table.insert(new_inlines, para.content[i])
                i = i + 1
            end
        else
            table.insert(new_inlines, para.content[i])
            i = i + 1
        end
    end

    para.content = new_inlines
    return para
end

-- Function to process Div elements
function process_div(el)
    if el.classes:includes("csl-entry") then
        for _, block in ipairs(el.content) do
            if block.t == "Para" then
                process_paragraph(block)
                process_para(block)
            end
        end
    end
    return el
end

-- Function to process localization in bibliography entries
function process_para(elem)
    for i = 1, #elem.content do
        local v = elem.content[i]
        local prev_str = elem.content[i - 2]

        if v and v.t == "Str" and prev_str and prev_str.t == "Str" and contains_chinese(prev_str.text) then
            if v.text:find("tran.") then
                elem.content[i] = pandoc.Str("译.")
            elseif v.text == "eds." then
                elem.content[i] = pandoc.Str("编.")
            end
        end

        if v and v.t == "Str" and v.text:lower() == "vol." and i < #elem.content - 2 then
            local prev_str = elem.content[i - 2]
            if prev_str and prev_str.t == "Str" and contains_chinese(prev_str.text) then
                local next_str = elem.content[i + 2]
                if next_str and next_str.t == "Str" then
                    local vol_num, identifier = next_str.text:match("([^%[]+)%[(.+)%]")
                    if vol_num and identifier then
                        elem.content[i] = pandoc.Str("第" .. vol_num .. "卷[" .. identifier .. "].")
                        table.remove(elem.content, i + 2)
                        table.remove(elem.content, i + 1)
                    end
                end
            end
        elseif v and v.t == "Str" and v.text == "ed." then
            if i > 2 and elem.content[i - 2] and elem.content[i - 2].t == "Str" then
                local prev_str = elem.content[i - 2]
                if contains_chinese(prev_str.text) and elem.content[i - 2].text:match(",$") then
                    elem.content[i] = pandoc.Str("编.")
                else
                    local ed_text = elem.content[i - 2] and elem.content[i - 2].text
                    local ed_num = extract_digits(ed_text)
                    local prev_str = elem.content[i - 4]
                    if ed_num and contains_chinese(prev_str.text) then
                        elem.content[i - 2] = pandoc.Str("第" .. ed_num .. "版.")
                        table.remove(elem.content, i)
                        table.remove(elem.content, i - 1)
                    end
                end
            end
        end
    end
    return elem
end

return {
    {
        Cite = process_cite,
        Link = process_cite,
        Div = process_div
    }
}
