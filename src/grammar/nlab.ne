# Core ==================================

_ -> " "
link[X] -> "<a href=\"#\">" $X "</a>"
strong[X] -> "<strong>" $X "</strong>"
ml[X] -> $X | link[$X]
maybe[X] -> $X | null

scareQuote[X] -> "\"" $X "\""

# Math ==================================

mathfrak[X] -> "\\mathfrak{" $X "}"
mathcal[X] -> "\\mathcal{" $X "}"
mathscr[X] -> "\\mathscr{" $X "}"
mathbf[X] -> "\\mathbf{" $X "}"

paren[X] -> "\\left(" $X "\\right)"
bracket[X] -> "\\left[" $X "\\right]"
group[X] -> paren[$X] | bracket[$X]
maybeGroup[X] -> $X | group[$X]

mLower -> "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "m" | "n" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" | "\\ell"
mUpper -> "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z"
mAnyChar -> mLower | mUpper
mAnyCharF -> mathfrak[mAnyChar] | mathcal[mAnyChar] | mathscr[mAnyChar] | mathbf[mAnyChar]

mBinOp -> "+" | "-" | "\\cdot" | "\\bullet" | "\\vee" | "\\wedge" | "\\backslash" | "\\circ"
mArrow -> "\\leftarrow" | "\\rightarrow" | "\\leftrightarrow" | "\\Leftarrow" | "\\Rightarrow" | "\\Leftrightarrow"

tex[X] -> "\\(" $X "\\)"
dtex[X] -> "\\[" $X "\\]"

mCategoryish -> mUpper | mathcal[mUpper] | mathbf[mUpper]
mFunctorish -> mCategoryish _ mArrow _ mCategoryish

mSmallExpr ->
  "{" mSmallExpr "}_{"  mSmallExpr "}"
| "{" mSmallExpr "}^{" mSmallExpr "}"
| group[mSmallExpr]
| mSmallExpr _ mBinOp _ mSmallExpr
| mCategoryish
| mFunctorish
| mAnyCharF

mBigOp -> "\\sum" | "\\prod" | "\\coprod" | "\\int" | "\\bigcap" | "\\bigcup" | "\\bigsqcup" | "\\bigvee" | "\\bigwedge" | "\\bigodot" | "\\bigotimes" | "\\bigoplus"
mBigOpFull -> mBigOp "_{" mLower maybe[":" _ mFunctorish] "}" maybe["^{" mAnyCharF "}"]

mDisplayMath ->
  mBigOpFull _ mSmallExpr
| mBigOpFull _ mSmallExpr _ mBinOp _ mBigOpFull _ mSmallExpr
| group[mBigOpFull _ mSmallExpr] _ "^{" mSmallExpr "}"
| mAnyChar _ group[mBigOpFull _ mSmallExpr]

mDisplayMathStatement ->
  mDisplayMath _ "=" _ mDisplayMath

# Main ==================================

@include "src/grammar/noun-literals.ne"
@include "src/grammar/adjective-literals.ne"

description ->
  ml[adverb] _ description
| ml[adj]
| tex[mSmallExpr] "-" adj

nounPhrase ->
  maybe[description] _ ml[noun] _ maybe[tex[mSmallExpr]]
| "lift" _ tex[mSmallExpr] _ "of a" _ maybe[description _] nounPhrase _ tex[mSmallExpr] maybe[_ "through a" _ nounPhrase]

nounPhrases ->
  maybe[description] _ ml[nouns]
| ml[adj] _ ml[nouns]
| maybe[description] _ ml[nouns] _ "over the" _ ml[noun] _ "of" _ ml[nouns]
| maybe[description] _ ml[nouns] _ "arising from" _ ml[adj] _ ml[nouns]

connective -> "generally" | "moreover" | "therefore" | "it follows that" | "similarly" | "sometimes" | "historically" | "note that" | "as such" | "trivially" | "in a sense" | "certainly" | "conversely" | "informally" | "usually"

iffy ->
  "in the case that"
| "when"
| "for situations where"
| "provided that"
| "if"

plainAlgebraicStructure -> "group" | "ring" | "field" | maybe["free" _] "module" | "vector space"
algebraicStructure -> plainAlgebraicStructure | plainAlgebraicStructure "oid"

vagueWord ->
  "canonical"
| "standard"
| "structure-preserving"
| "visible"
| algebraicStructure "-like"

easyWord -> "obvious" | "trivial" | "evident" | "straightforward" | "definitional" | "elementary"

qualification ->
  dtex[mDisplayMath]
| "all" _ nounPhrases _ "commute"
| "the" _ easyWord _ "diagram commutes"
| "all the" _ easyWord _ "diagrams commute"
| nounPhrases _ "are" _ scareQuote[vagueWord] _ "from" _ tex[mUpper] "'s" _ "point of view"
| "the appropriate" _ nounPhrases _ "are considered"
| tex[mSmallExpr] _ "is" _ description
| "the" _ description _ "object factors through" _ tex[mSmallExpr]


statement ->
  "a" _ nounPhrase _ maybe["satisfying" _ dtex[mDisplayMathStatement]] "is always" _ description maybe[_ iffy _ qualification]
| "a" _ nounPhrase _ "satisfies the" _ description _ "property" maybe[_ iffy _ qualification]
| "a" _ nounPhrase _ "embeds" _ adverb _ "into all" _ description _ nounPhrases
| "a" _ nounPhrase _ "is" _ description _ iffy _ qualification
| "all" _ nounPhrases _ "are" _ description maybe[_ "in the sense that" _ dtex[mDisplayMathStatement]]
| "the notion of a" _ nounPhrase _ "is an approximate solution to the problem of finding" _ nounPhrases _ "that satisfy" _ dtex[mDisplayMathStatement] maybe["with respect to" _ ml[nounPhrases]]
| "the analogous definition makes sense in the context of" _ nounPhrases
| "provided" _ qualification _ "," _ statement
| nounPhrases _ "may be computed using" _ nounPhrases _ "or" _ nounPhrases maybe[_ "by observing that" dtex[mDisplayMathStatement]]

defn -> strong["Definition"] ": " defnBody
defnBody ->
  "A" _ strong[nounPhrase] _ "is a" _ nounPhrase _ "along with a" _ nounPhrase _ "that satisfies certain properties" maybe[":" _ dtex[mDisplayMathStatement]]
| "A" _ strong[nounPhrase] _ "is a generalization of the notion of a" _ nounPhrase _ "into the context of" _ nounPhrases
| "In the context of" _ nounPhrases "," _ nounPhrases _ "are simply" _ nounPhrases _ "over" _ nounPhrases
| "A" _ nounPhrase _ "is called" _ strong[adj] _ iffy _ qualification
| nounPhrases _ "are said to be" _ strong[adj] _ iffy _ qualification
| "Given" _ tex[mSmallExpr] _ "and" _ tex[mSmallExpr] _ "," _ "a" _ nounPhrase _ "is" _ strong[adj] _ iffy _ qualification

conditional ->
  "if" _ statement "," _ "then" _ statement
| "in the case that" _ statement "," _ statement
| "when" _ statement "," _ "it is said that" _ statement
| "in" _ vagueWord _ nounPhrases "," _ statement

sentence -> connective "," _ conditional "." _
openingSentence -> conditional "." _
listItem -> statement
title -> maybe[adverb] _ adj _ noun
