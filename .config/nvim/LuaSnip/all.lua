return {
  require("luasnip").snippet(
    {trig = "cmake_"},
    { t("cmake_minimum_required(VERSION "), i(1), t(")") }
  )
}
