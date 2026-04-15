--[[
    Horizon Suite - Focus Anchor Helpers

    Alignment-aware anchor primitives used by the Focus tracker.

    Concepts
    --------
    The Focus tracker has a user-facing "text alignment" option (left | right).
    Rather than branch on alignment at every SetPoint call site, renderer code
    expresses anchors in terms of four alignment-agnostic roles:

      * inner-start : the edge where content begins
                      (left edge in left-mode, right edge in right-mode)
      * inner-end   : the opposite edge
      * outer-start : just outside the entry on the inner-start side
                      (where icons sit)
      * flow-below  : inner-start of child at inner-start-bottom of prev

    Each helper accepts positive offsets that grow *inward* from the
    inner-start edge (so callers never see negative numbers for left/right
    swapping). The helper negates them when the alignment is "right".

    Adding a new Focus UI element?
    -------------------------------
    Use the helpers instead of raw SetPoint/SetJustifyH. This keeps the
    element alignment-aware for free. If an element has no natural
    alignment role (e.g. always centred), use a raw SetPoint — but that
    should be rare.
]]

local addon = _G._HorizonSuite_Loading or _G.HorizonSuiteBeta or _G.HorizonSuite

--- True when the Focus text alignment option is set to "right".
--- Cheap to call repeatedly; reads a single DB key.
--- @return boolean
function addon.IsFocusRightAligned()
    return addon.GetFocusTextAlignment and addon.GetFocusTextAlignment() == "right"
end

--- Alignment-aware corner name.
--- @param vert string "TOP" | "BOTTOM"
--- @return string e.g. "TOPLEFT" in left-mode, "TOPRIGHT" in right-mode
local function InnerCorner(vert)
    return vert .. (addon.IsFocusRightAligned() and "RIGHT" or "LEFT")
end

--- Alignment-aware corner name for the *opposite* side from InnerCorner.
--- @param vert string "TOP" | "BOTTOM"
--- @return string
local function OuterCorner(vert)
    return vert .. (addon.IsFocusRightAligned() and "LEFT" or "RIGHT")
end

--- Signed X offset: positive value is interpreted as "inward from the
--- inner-start edge". Negates automatically in right-mode.
--- @param x number|nil
--- @return number
local function InnerX(x)
    local v = x or 0
    return addon.IsFocusRightAligned() and -v or v
end

-- ---------------------------------------------------------------------------
-- Public helpers
-- ---------------------------------------------------------------------------

--- Anchor `child`'s inner-start-TOP corner to `parent`'s inner-start-TOP
--- corner, offset by xOff inward and yOff vertically. Clears previous points.
--- Example: title text TOPLEFT/TOPRIGHT flush with entry TOPLEFT/TOPRIGHT.
--- @param child any Region with SetPoint/ClearAllPoints
--- @param parent any
--- @param xOff number|nil Positive grows inward from the inner-start edge
--- @param yOff number|nil
function addon.AnchorInnerStart(child, parent, xOff, yOff)
    child:ClearAllPoints()
    local corner = InnerCorner("TOP")
    child:SetPoint(corner, parent, corner, InnerX(xOff), yOff or 0)
end

--- Anchor `child`'s inner-start-TOP to `prev`'s inner-start-BOTTOM (i.e.
--- `child` flows below `prev` at the same inner edge). Clears previous points.
--- Example: next objective below previous objective.
--- @param child any
--- @param prev any
--- @param xOff number|nil Positive grows inward from the inner-start edge
--- @param yOff number|nil (usually negative; spacing below prev)
function addon.AnchorBelowInnerStart(child, prev, xOff, yOff)
    child:ClearAllPoints()
    child:SetPoint(InnerCorner("TOP"), prev, InnerCorner("BOTTOM"), InnerX(xOff), yOff or 0)
end

--- Anchor `child`'s inner-start-TOP to `prev`'s inner-start-TOP (same edge,
--- same vertical; used when stacking from within an element rather than
--- below it, e.g. objective text anchoring inside an affix row).
--- Clears previous points.
--- @param child any
--- @param prev any
--- @param xOff number|nil Positive grows inward
--- @param yOff number|nil
function addon.AnchorAtInnerStart(child, prev, xOff, yOff)
    child:ClearAllPoints()
    local corner = InnerCorner("TOP")
    child:SetPoint(corner, prev, corner, InnerX(xOff), yOff or 0)
end

--- Anchor `child`'s inner-start-TOP to `prev`'s inner-start-BOTTOM *only*
--- (no horizontal offset negation needed). Thin wrapper kept for parity
--- with AnchorBelowInnerStart when callers want to pass zero offsets.
--- @param child any
--- @param prev any
function addon.AnchorDirectlyBelow(child, prev)
    child:ClearAllPoints()
    child:SetPoint(InnerCorner("TOP"), prev, InnerCorner("BOTTOM"), 0, 0)
end

--- Anchor `icon` just *outside* `parent`'s inner-start edge (where content
--- flows from) with `gap` px between icon and entry edge.
--- Left-mode: icon.TOPRIGHT → entry.TOPLEFT -gap (icon sits left of entry).
--- Right-mode: icon.TOPLEFT → entry.TOPRIGHT +gap (icon sits right of entry).
--- Clears previous points.
--- @param icon any
--- @param parent any
--- @param gap number|nil Positive = distance outside entry
--- @param yOff number|nil
function addon.AnchorOuterFromInnerStart(icon, parent, gap, yOff)
    icon:ClearAllPoints()
    local g = gap or 0
    if addon.IsFocusRightAligned() then
        icon:SetPoint("TOPLEFT", parent, "TOPRIGHT", g, yOff or 0)
    else
        icon:SetPoint("TOPRIGHT", parent, "TOPLEFT", -g, yOff or 0)
    end
end

--- Anchor a small element (e.g. completion tick) on the *outer* side of
--- `text`'s visible edge. Because SetJustifyH pushes visible text toward
--- the inner-start edge's opposite (right-justified in right-mode), the
--- tick sits to the left of visible text in left-mode and the right of
--- visible text in right-mode.
--- @param tick any
--- @param text any The FontString the tick annotates
--- @param gap number|nil Pixel gap between tick and visible text
function addon.AnchorTickOuter(tick, text, gap)
    tick:ClearAllPoints()
    local g = gap or 0
    if addon.IsFocusRightAligned() then
        tick:SetPoint("LEFT", text, "RIGHT", g, 0)
    else
        tick:SetPoint("RIGHT", text, "LEFT", -g, 0)
    end
end

--- Anchor a progress-bar fill texture so it grows from the inner-start
--- edge of `bg`. Caller sets `fill:SetWidth(fillW)` to control progress.
--- In left-mode the fill pins to TOPLEFT/BOTTOMLEFT of bg; in right-mode
--- it pins to TOPRIGHT/BOTTOMRIGHT so the "full" edge matches the anchor
--- and the bar drains from the opposite side.
--- @param fill any
--- @param bg any
function addon.AnchorBarFill(fill, bg)
    fill:ClearAllPoints()
    if addon.IsFocusRightAligned() then
        fill:SetPoint("TOPRIGHT", bg, "TOPRIGHT", 0, 0)
        fill:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 0, 0)
    else
        fill:SetPoint("TOPLEFT", bg, "TOPLEFT", 0, 0)
        fill:SetPoint("BOTTOMLEFT", bg, "BOTTOMLEFT", 0, 0)
    end
end

--- Set a FontString's horizontal justification to match current alignment.
--- @param fs any FontString
function addon.ApplyAlignedJustify(fs)
    if fs and fs.SetJustifyH then
        fs:SetJustifyH(addon.IsFocusRightAligned() and "RIGHT" or "LEFT")
    end
end

--- Expose corner helpers for rare call sites that need explicit corner
--- strings (e.g. multi-point anchor spanning both inner and outer edges).
--- Prefer the higher-level helpers above; these are an escape hatch.
addon.FocusInnerCorner = InnerCorner
addon.FocusOuterCorner = OuterCorner
addon.FocusInnerX      = InnerX
