-- Which byte sequence draws which glyph code.
--
-- Sequences are matched longest-first, so a multi-byte character and a
-- multi-character ligature both work: "ch" can be one glyph even though
-- "c" is also mapped.  Codes here must land inside a page declared in
-- lang/font.lua.
return {
  ["~"] = 0x100,
  ["ª"] = 0x101,
  ["º"] = 0x102,
  ["À"] = 0x103,
  ["Á"] = 0x104,
  ["Â"] = 0x105,
  ["Ã"] = 0x106,
  ["Ç"] = 0x107,
  ["É"] = 0x108,
  ["Ê"] = 0x109,
  ["Í"] = 0x10A,
  ["Ó"] = 0x10B,
  ["Ô"] = 0x10C,
  ["Õ"] = 0x10D,
  ["Ú"] = 0x10E,
  ["à"] = 0x10F,
  ["á"] = 0x110,
  ["â"] = 0x111,
  ["ã"] = 0x112,
  ["ç"] = 0x113,
  ["ê"] = 0x114,
  ["í"] = 0x115,
  ["ó"] = 0x116,
  ["ô"] = 0x117,
  ["õ"] = 0x118,
  ["ú"] = 0x119,
}
